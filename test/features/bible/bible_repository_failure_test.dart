// Kingdom Heir — BibleRepository regression test
//
// Pin down two production bugs that surfaced as a hard 403 on every
// chapter open (e.g. John 1):
//
//   1. The repository used to interpolate the raw exception into the
//      `left()` side: `left('Failed to get chapter content: $e')`.
//      Combined with the provider's `throw Exception(l)`, the UI
//      ended up rendering `BibleApiException(403): …` to the user.
//      The fix routes every error through `ErrorHandler.handle`
//      (which forwards to Sentry / Crashlytics) and returns a
//      curated [Failure.message] that never includes the
//      exception class name or the status code.
//
//   2. The repository used to be silent about which `Failure` flavour
//      was produced. The fix is a typed `_mapError` so a 401/403
//      surfaces as `AuthFailure`, a 404 as `ServerFailure` with the
//      chapter-aware message, and everything else as the generic
//      curated message.

import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/core/error/error_handler.dart';
import 'package:kingdom_heir/core/storage/cache_manager.dart';
import 'package:kingdom_heir/features/bible/data/repositories/bible_repository.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_api_service.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_local_cache.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_supabase_service.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // The repository forwards the raw error to Sentry / Crashlytics.
  // Tests must never reach the network.
  setUpAll(() async {
    ErrorHandler.disableRemoteReportingForTests();
    SharedPreferences.setMockInitialValues({});
  });

  group('BibleRepository — never leaks the raw exception', () {
    test('403 from the API service surfaces a curated friendly message',
        () async {
      final repo = await _repoWithApi(_throwingApi(
        const BibleApiException.auth(
          'Unable to load this chapter. Please try again shortly.',
          statusCode: 403,
        ),
      ),);

      final result = await repo.getChapterContent(1, 'JHN.1');
      final message = result.fold((l) => l, (_) => null);
      expect(message, isNotNull);
      // The left() side must NEVER contain the raw exception class
      // name, the kind tag, or the status code.
      expect(message, isNot(contains('BibleApiException')));
      expect(message, isNot(contains('[auth')));
      expect(message, isNot(contains('403')));
      // And it must be the friendly fallback the UI shows.
      expect(message, contains('Unable to load this chapter'));
    });

    test('404 surfaces a curated message, not the path', () async {
      final repo = await _repoWithApi(_throwingApi(
        const BibleApiException.notFound(
          'Content not found: /bibles/3034/passages/ZZZ.1',
          statusCode: 404,
        ),
      ),);

      final result = await repo.getChapterContent(1, 'ZZZ.1');
      final message = result.fold((l) => l, (_) => null);
      expect(message, isNotNull);
      // No path leak, no class name, no status code.
      expect(message, isNot(contains('BibleApiException')));
      expect(message, isNot(contains('/bibles/')));
      expect(message, isNot(contains('404')));
    });

    test('NetworkException surfaces a NetworkFailure with a usable message',
        () async {
      final repo = await _repoWithApi(_throwingApi(
        const BibleApiException.network(
          'No internet connection. Please check your network and try again.',
        ),
      ),);

      final result = await repo.getChapterContent(1, 'JHN.1');
      final message = result.fold((l) => l, (_) => null);
      expect(message, contains('No internet connection'));
      expect(message, isNot(contains('BibleApiException')));
    });

    test('Unknown exception surfaces a generic curated message', () async {
      final repo = await _repoWithApi(
        _throwingApi(StateError('something internal')),
      );

      final result = await repo.getChapterContent(1, 'JHN.1');
      final message = result.fold((l) => l, (_) => null);
      expect(message, 'Unable to load this chapter. Please try again shortly.');
      // Never echo the StateError text — it might contain internal
      // details like table names or column names.
      expect(message, isNot(contains('something internal')));
      expect(message, isNot(contains('StateError')));
    });

    test('getVersions: 403 produces the same curated message', () async {
      final repo = await _repoWithApi(_throwingApi(
        const BibleApiException.auth(
          'Unable to load this chapter. Please try again shortly.',
          statusCode: 403,
        ),
      ),);

      final result = await repo.getVersions();
      final message = result.fold((l) => l, (_) => null);
      expect(message, contains('Unable to load this chapter'));
      expect(message, isNot(contains('403')));
    });

    test('getBooks: 403 produces the same curated message', () async {
      final repo = await _repoWithApi(_throwingApi(
        const BibleApiException.auth(
          'Unable to load this chapter. Please try again shortly.',
          statusCode: 403,
        ),
      ),);

      final result = await repo.getBooks(1);
      final message = result.fold((l) => l, (_) => null);
      expect(message, contains('Unable to load this chapter'));
      expect(message, isNot(contains('403')));
    });
  });
}

// ── Test fixtures ──────────────────────────────────────────────────────────

class _StubApiService implements BibleApiService {
  _StubApiService(this._error);

  final Object _error;

  @override
  Future<List<BibleVersion>> getBibleVersions({String language = 'eng'}) =>
      Future<List<BibleVersion>>.error(_error);

  @override
  Future<List<BibleBook>> getBooks(int versionId) =>
      Future<List<BibleBook>>.error(_error);

  @override
  Future<List<BibleChapter>> getChapters(int versionId, String bookId) =>
      Future<List<BibleChapter>>.error(_error);

  @override
  Future<BibleChapterContent> getChapterContent(
    int versionId,
    String chapterId,
  ) =>
      Future<BibleChapterContent>.error(_error);

  @override
  Future<List<BibleSearchResult>> search(int versionId, String query) =>
      Future<List<BibleSearchResult>>.error(_error);
}

_StubApiService _throwingApi(Object error) => _StubApiService(error);

/// Builds a repository that has a stub [BibleApiService] returning
/// the supplied error on every call, and a [BibleLocalCache] backed
/// by an in-memory [SharedPreferences].
Future<BibleRepository> _repoWithApi(BibleApiService api) async {
  final prefs = await SharedPreferences.getInstance();
  return BibleRepositoryImpl(
    apiService: api,
    localCache: BibleLocalCache(CacheManager(prefs)),
    supabaseService: _NoopSupabaseService(),
  );
}

class _NoopSupabaseService implements BibleSupabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<dynamic>.value();
}
