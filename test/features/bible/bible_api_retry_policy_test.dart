// Kingdom Heir — Bible API retry policy + 403 regression test
//
// Pins down two production bugs that surfaced as a hard 403 on every
// chapter open (e.g. John 1):
//
//   1. **No retry policy** — the old `_get` mixed status code handling
//      and retry logic in a single `while` loop. 401/403 were
//      "rethrown" but only after a 4-attempt walk that hammered the
//      YouVersion key on a dead credential. 500/502/503/504/429
//      were never explicitly retried — they fell through to the
//      generic `catch (e)` and re-attempted with the same 1s/2s/4s
//      backoff but without a typed failure path. The fix narrows
//      the policy to:
//
//        * 401 / 403  → no retry, throw `BibleApiException.auth`
//        * 404        → no retry, throw `BibleApiException.notFound`
//        * 429 / 500 / 502 / 503 / 504 → retry with backoff
//        * any other 4xx → no retry, throw generic
//
//   2. **The 403 is a real auth failure** — the bundled default
//      `Env.youVersionKey` has been rejected by api.youversion.com.
//      The fix: the user-facing message is curated by the
//      `BibleApiException.auth` constructor and never reveals the
//      status code; the technical details (kind, code, path) are
//      only available via `BibleApiException.technicalDetails` and
//      forwarded to Sentry / Crashlytics by the repository.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_api_service.dart';

void main() {
  // Suppress backoff in tests so the retry-suite finishes in ms, not
  // seconds. Each test verifies call count, not the wait between
  // attempts — production uses exponential backoff.
  setUpAll(() {
    BibleApiService.backoff = (_) async {};
  });

  tearDownAll(() {
    // Restore default backoff so any test that loads this file in
    // isolation still exercises the production backoff in any
    // subsequent runs.
    // ignore: invalid_use_of_visible_for_testing_member
    // (no public reset; tests can rely on test isolation).
  });

  group('BibleApiService.isRetryableStatusCode', () {
    test('401 is never retryable', () {
      expect(BibleApiService.isRetryableStatusCode(401), isFalse);
    });

    test('403 is never retryable (the production 403 path)', () {
      expect(BibleApiService.isRetryableStatusCode(403), isFalse);
    });

    test('404 is never retryable', () {
      expect(BibleApiService.isRetryableStatusCode(404), isFalse);
    });

    test('429 is retryable', () {
      expect(BibleApiService.isRetryableStatusCode(429), isTrue);
    });

    test('500 / 502 / 503 / 504 are all retryable', () {
      for (final code in [500, 502, 503, 504]) {
        expect(BibleApiService.isRetryableStatusCode(code), isTrue,
            reason: 'expected $code to be retryable',);
      }
    });

    test('other 4xx (400, 410, 418) are not retryable', () {
      for (final code in [400, 410, 418]) {
        expect(BibleApiService.isRetryableStatusCode(code), isFalse,
            reason: 'expected $code to NOT be retryable',);
      }
    });
  });

  group('BibleApiException — no raw technical leak in toString', () {
    test('toString returns the curated user-safe message only', () {
      const ex = BibleApiException.auth(
        'Unable to load this chapter. Please try again shortly.',
        statusCode: 403,
      );
      // toString is what the UI surfaces via Failure.toString → state
      // error. It must NOT contain the class name, status code, or
      // the [auth] kind tag.
      expect(ex.toString(), 'Unable to load this chapter. Please try again shortly.');
      expect(ex.toString(), isNot(contains('BibleApiException')));
      expect(ex.toString(), isNot(contains('403')));
      expect(ex.toString(), isNot(contains('[auth')));
    });

    test('technicalDetails is the Sentry / Crashlytics string', () {
      const ex = BibleApiException.auth(
        'Unable to load this chapter. Please try again shortly.',
        statusCode: 403,
      );
      // technicalDetails is forwarded to Sentry / Crashlytics by the
      // repository. It MUST contain the kind and status code so
      // dashboards can distinguish auth vs not-found vs network.
      expect(ex.technicalDetails, contains('BibleApiErrorKind.auth'));
      expect(ex.technicalDetails, contains('403'));
    });

    test('notFound kind carries the path for diagnostics', () {
      const ex = BibleApiException.notFound(
        'Content not found: /bibles/3034/passages/ZZZ.1',
        statusCode: 404,
      );
      expect(ex.kind, BibleApiErrorKind.notFound);
      expect(ex.technicalDetails, contains('BibleApiErrorKind.notFound'));
      expect(ex.technicalDetails, contains('404'));
    });

    test('network kind is for socket / timeout', () {
      const ex = BibleApiException.network(
        'No internet connection. Please check your network and try again.',
      );
      expect(ex.kind, BibleApiErrorKind.network);
      expect(ex.technicalDetails, contains('BibleApiErrorKind.network'));
    });
  });

  group('BibleApiService._get — retry behaviour', () {
    test('401: single attempt, throws auth exception, never retries', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        return http.Response('{"error":"unauthorized"}', 401);
      });
      final svc = BibleApiService.withClient(client: client);

      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(
          isA<BibleApiException>()
              .having((e) => e.kind, 'kind', BibleApiErrorKind.auth)
              .having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
      expect(calls, 1, reason: '401 must not be retried');
    });

    test('403: single attempt, throws auth exception, never retries '
        '(the production 403 path)', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        return http.Response('{"error":"forbidden"}', 403);
      });
      final svc = BibleApiService.withClient(client: client);

      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(
          isA<BibleApiException>()
              .having((e) => e.kind, 'kind', BibleApiErrorKind.auth)
              .having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
      expect(calls, 1, reason: '403 must not be retried');
    });

    test('404: single attempt, throws notFound exception, never retries',
        () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        return http.Response('not found', 404);
      });
      final svc = BibleApiService.withClient(client: client);

      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(
          isA<BibleApiException>()
              .having((e) => e.kind, 'kind', BibleApiErrorKind.notFound),
        ),
      );
      expect(calls, 1);
    });

    test('429: retries up to _maxRetries (3) then throws', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        return http.Response('rate limited', 429);
      });
      final svc = BibleApiService.withClient(client: client);

      // 4 attempts = 1 initial + 3 retries.
      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(isA<BibleApiException>()),
      );
      expect(calls, 4, reason: '429 must retry 3 times');
    }, timeout: const Timeout(Duration(seconds: 30)),);

    test('500: retries up to _maxRetries then throws', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        return http.Response('boom', 500);
      });
      final svc = BibleApiService.withClient(client: client);

      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(isA<BibleApiException>()),
      );
      expect(calls, 4);
    }, timeout: const Timeout(Duration(seconds: 30)),);

    test('502: retries up to _maxRetries then throws', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        return http.Response('bad gateway', 502);
      });
      final svc = BibleApiService.withClient(client: client);

      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(isA<BibleApiException>()),
      );
      expect(calls, 4);
    }, timeout: const Timeout(Duration(seconds: 30)),);

    test('503: retries up to _maxRetries then throws', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        return http.Response('unavailable', 503);
      });
      final svc = BibleApiService.withClient(client: client);

      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(isA<BibleApiException>()),
      );
      expect(calls, 4);
    }, timeout: const Timeout(Duration(seconds: 30)),);

    test('504: retries up to _maxRetries then throws', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        return http.Response('gateway timeout', 504);
      });
      final svc = BibleApiService.withClient(client: client);

      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(isA<BibleApiException>()),
      );
      expect(calls, 4);
    }, timeout: const Timeout(Duration(seconds: 30)),);

    test('500 then 200: succeeds after one retry', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        if (calls < 2) {
          return http.Response('boom', 500);
        }
        return http.Response(
          jsonEncode({
            'id': 'JHN.1',
            'orgId': 'JHN.1',
            'bibleId': '3034',
            'bookId': 'JHN',
            'chapterIds': ['1'],
            'reference': {
              'usfm': 'JHN.1',
              'human': 'John 1',
              'version_id': 3034,
            },
            'verseCount': 1,
            'content': '<p>In the beginning was the Word</p>',
            'next': {'usfm': 'JHN.2', 'human': 'John 2'},
            'previous': null,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final svc = BibleApiService.withClient(client: client);

      final content = await svc.getChapterContent(1, 'JHN.1');
      expect(content.id, 'JHN.1');
      expect(content.bookId, 'JHN');
      expect(content.number, '1');
      expect(content.nextChapterId, 'JHN.2');
      expect(calls, 2);
    }, timeout: const Timeout(Duration(seconds: 30)),);

    test('falls back through configured Bible version IDs when the first one is rejected', () async {
      final seenVersionIds = <int>[];
      final client = MockClient((req) async {
        final match = RegExp(r'/bibles/(\d+)').firstMatch(req.url.path);
        if (match != null) {
          final versionId = int.parse(match.group(1)!);
          seenVersionIds.add(versionId);
          if (versionId == 3034) {
            return http.Response(
              '{"error":"forbidden"}',
              403,
              headers: {'content-type': 'application/json'},
            );
          }
        }

        return http.Response(
          jsonEncode({
            'id': 'JHN.1',
            'orgId': 'JHN.1',
            'bibleId': '12',
            'bookId': 'JHN',
            'chapterIds': ['1'],
            'reference': {
              'usfm': 'JHN.1',
              'human': 'John 1',
              'version_id': 12,
            },
            'verseCount': 1,
            'content': '<p>In the beginning was the Word</p>',
            'next': {'usfm': 'JHN.2', 'human': 'John 2'},
            'previous': null,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final svc = BibleApiService.withClient(
        client: client,
        preferredVersionIds: const [3034, 12],
        fallbackVersionId: 12,
      );

      final content = await svc.getChapterContent(3034, 'JHN.1');
      expect(content.id, 'JHN.1');
      expect(seenVersionIds, [3034, 12]);
    });

    test('sends the X-YVP-App-Key header', () async {
      String? sentKey;
      final client = MockClient((req) async {
        sentKey = req.headers['X-YVP-App-Key'];
        return http.Response('{"id":"JHN.1"}', 200,
            headers: {'content-type': 'application/json'},);
      });
      final svc = BibleApiService.withClient(
        client: client,
        apiKey: 'my-prod-key',
      );

      await svc.getChapterContent(1, 'JHN.1');
      expect(sentKey, 'my-prod-key');
    });

    test('SocketException is wrapped in a network BibleApiException', () async {
      final client = MockClient((req) async {
        throw const SocketException('offline');
      });
      final svc = BibleApiService.withClient(client: client);

      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(
          isA<BibleApiException>()
              .having((e) => e.kind, 'kind', BibleApiErrorKind.network),
        ),
      );
    }, timeout: const Timeout(Duration(seconds: 30)),);

    test('TimeoutException is wrapped in a network BibleApiException',
        () async {
      final client = MockClient((req) async {
        throw TimeoutException('slow');
      });
      final svc = BibleApiService.withClient(client: client);

      await expectLater(
        svc.getChapterContent(1, 'JHN.1'),
        throwsA(
          isA<BibleApiException>()
              .having((e) => e.kind, 'kind', BibleApiErrorKind.network),
        ),
      );
    }, timeout: const Timeout(Duration(seconds: 30)),);
  });
}
