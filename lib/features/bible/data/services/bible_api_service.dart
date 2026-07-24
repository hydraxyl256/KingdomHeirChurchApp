import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:kingdom_heir/core/config/env.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_version_config.dart';

/// YouVersion Platform REST API client.
///
/// Base URL:   https://api.youversion.com/v1
/// Auth header: X-YVP-App-Key: <key>
///
/// All methods throw a [BibleApiException] on network, auth, or parse errors.
/// No mock/fallback data is ever returned — callers display error states.
class BibleApiService {
  BibleApiService()
      : _apiKey = Env.youVersionKey,
        _client = null,
        _preferredVersionIds = null,
        _fallbackVersionId = null;

  /// Test-only constructor. Lets unit tests inject a stub [http.Client]
  /// and a known API key without going through [Env].
  @visibleForTesting
  BibleApiService.withClient({
    required http.Client client,
    String apiKey = 'test-key',
    List<int>? preferredVersionIds,
    int? fallbackVersionId,
  })  : _apiKey = apiKey,
        _client = client,
        _preferredVersionIds = preferredVersionIds,
        _fallbackVersionId = fallbackVersionId;

  final String _apiKey;
  final http.Client? _client;
  final List<int>? _preferredVersionIds;
  final int? _fallbackVersionId;

  static const _baseUrl = 'https://api.youversion.com/v1';
  static const _timeout = Duration(seconds: 10);
  static const int _maxRetries = 3;

  /// Test-only override for the exponential backoff between retries.
  /// Production uses [_defaultBackoff]. Set to `(_) async {}` in
  /// tests to keep the suite fast.
  @visibleForTesting
  static Future<void> Function(int attempt) backoff = _defaultBackoff;

  static Future<void> _defaultBackoff(int attempt) async {
    // Exponential backoff: 1s, 2s, 4s, 8s … jittered lightly to
    // avoid synchronised retry storms from a fleet of clients.
    final baseDelayMs = math.pow(2, attempt - 1) * 1000;
    final jitterMs = math.Random().nextInt(250);
    await Future<void>.delayed(
      Duration(milliseconds: baseDelayMs.toInt() + jitterMs),
    );
  }

  http.Client get _http => _client ?? http.Client();

  /// Default licensed version. The app never relies on provider-global ID 1.
  static int get defaultVersionId => BibleVersionConfig.fallbackVersionId();

  int _normalizedVersionId(int requestedVersionId) {
    return BibleVersionConfig.normalizeVersionId(
      requestedVersionId,
      overrides: _preferredVersionIds,
      fallbackOverride: _fallbackVersionId,
    );
  }

  Map<String, String> get _headers => {
        'X-YVP-App-Key': _apiKey,
        'Accept': 'application/json',
      };

  // ── Helper ──────────────────────────────────────────────────────────────────

  /// Status codes that justify an exponential-backoff retry.
  ///
  /// We deliberately retry ONLY transient server-side failures
  /// (429 rate-limit, 500/502/503/504). 401/403 mean the key is
  /// rejected — retrying is pointless and burns rate-limit budget.
  /// 404 means the path is wrong — also pointless to retry.
  /// 4xx other than the above are client errors that won't fix
  /// themselves.
  static const Set<int> _retryableStatusCodes = {429, 500, 502, 503, 504};

  /// True when the given HTTP status is eligible for one more attempt.
  @visibleForTesting
  static bool isRetryableStatusCode(int statusCode) =>
      _retryableStatusCodes.contains(statusCode);

  Future<Map<String, dynamic>> _get(String path) async {
    if (_apiKey.trim().isEmpty) {
      throw const BibleApiException.auth(
        'Bible service configuration is unavailable. Please try again later.',
        statusCode: 401,
      );
    }
    final uri = Uri.parse('$_baseUrl$path');
    var attempt = 0;

    while (true) {
      attempt++;
      final sw = Stopwatch()..start();
      try {
        final response = await _http.get(uri, headers: _headers).timeout(_timeout);
        sw.stop();

        developer.log(
          'GET $path',
          name: 'BibleApi',
          error: 'Status: ${response.statusCode} | Time: ${sw.elapsedMilliseconds}ms | Attempt: $attempt',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }

        // Non-2xx — decide whether to retry. 401/403/404 are terminal;
        // 429/500/502/503/504 are retryable up to _maxRetries.
        if (!isRetryableStatusCode(response.statusCode)) {
          throw _terminalExceptionFor(response.statusCode, path);
        }

        if (attempt > _maxRetries) {
          throw _terminalExceptionFor(response.statusCode, path);
        }
      } on SocketException {
        if (attempt > _maxRetries) {
          throw const BibleApiException.network(
            'No internet connection. Please check your network and try again.',
          );
        }
      } on TimeoutException {
        if (attempt > _maxRetries) {
          throw const BibleApiException.network(
            'Connection is taking longer than expected. Tap Retry.',
          );
        }
      } on BibleApiException {
        rethrow;
      } catch (e) {
        if (attempt > _maxRetries) {
          throw BibleApiException.network('Network error: $e');
        }
      }

      // Exponential backoff (overridable for tests).
      await backoff(attempt);
    }
  }

  /// Maps a non-retryable status code to the right [BibleApiException]
  /// flavour. 401/403 → [BibleApiException.auth]; 404 → [BibleApiException.notFound];
  /// everything else → generic.
  ///
  /// Exposed as `static` so the unit tests in
  /// `bible_api_retry_policy_test.dart` can assert on the kind
  /// each status code produces without re-running the full HTTP
  /// stack.
  static BibleApiException _terminalExceptionFor(int statusCode, String path) {
    switch (statusCode) {
      case 401:
      case 403:
        return const BibleApiException.auth(
          'This chapter could not be opened. Please try again shortly.',
          statusCode: 403,
        );
      case 404:
        return BibleApiException.notFound('Content not found: $path', statusCode: 404);
      case 429:
        return const BibleApiException(
          'Too many requests. Please wait a moment and try again.',
          statusCode: 429,
        );
      default:
        return BibleApiException(
          'The Scripture service is unavailable right now. Please try again shortly.',
          statusCode: statusCode,
        );
    }
  }

  // ── Versions ────────────────────────────────────────────────────────────────

  /// Returns available Bible versions filtered to English by default.
  Future<List<BibleVersion>> getBibleVersions({String language = 'eng'}) async {
    // YouVersion: GET /bibles?language_ranges[]=eng
    final json = await _get('/bibles?language_ranges[]=$language');
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => BibleVersion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Books ────────────────────────────────────────────────────────────────────

  /// Returns the 66 books for the given Bible [versionId].
  Future<List<BibleBook>> getBooks(int versionId) async {
    final json = await _get('/bibles/${_normalizedVersionId(versionId)}/books');
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Chapters ────────────────────────────────────────────────────────────────

  /// Returns chapter list for the given book USFM code (e.g. "GEN", "JHN").
  Future<List<BibleChapter>> getChapters(int versionId, String bookUsfm) async {
    final json = await _get(
      '/bibles/${_normalizedVersionId(versionId)}/books/$bookUsfm/chapters',
    );
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => BibleChapter.fromJson(e as Map<String, dynamic>))
        // Filter out intro/front-matter entries (YouVersion sometimes returns "intro")
        .where((c) => int.tryParse(c.number) != null)
        .toList();
  }

  // ── Chapter Content ──────────────────────────────────────────────────────────

  /// Fetches the full chapter content (HTML + navigation metadata).
  ///
  /// [chapterId] is in USFM dot-notation e.g. "JHN.3" or "GEN.1".
  Future<BibleChapterContent> getChapterContent(
    int versionId,
    String chapterId,
  ) async {
    // YouVersion passages endpoint:
    // GET /bibles/{version_id}/passages/{passage_id}
    // where passage_id for a chapter is e.g. "JHN.3" (fetches entire chapter)
    BibleApiException? lastAuthorizationError;
    for (final candidate in BibleVersionConfig.orderedCandidates(
      versionId,
      overrides: _preferredVersionIds,
      fallbackOverride: _fallbackVersionId,
    )) {
      try {
        final json = await _get('/bibles/$candidate/passages/$chapterId');
        final data = json['data'] as Map<String, dynamic>? ?? json;
        return BibleChapterContent.fromJson(data);
      } on BibleApiException catch (error) {
        if (error.kind != BibleApiErrorKind.auth) rethrow;
        lastAuthorizationError = error;
      }
    }
    throw lastAuthorizationError ?? const BibleApiException.auth(
      'This chapter could not be opened. Please try again shortly.',
      statusCode: 403,
    );
  }

  // ── Search ───────────────────────────────────────────────────────────────────

  /// YouVersion has no public keyword search endpoint.
  ///
  /// This method implements a **smart reference resolver**:
  ///   • If [query] matches a USFM reference (e.g. "JHN.3.16", "ROM.8"),
  ///     it fetches the passage directly.
  ///   • If [query] matches a human reference (e.g. "John 3:16", "Romans 8"),
  ///     it resolves to the appropriate USFM and fetches it.
  ///   • Otherwise returns an empty list (caller shows "no results" state).
  Future<List<BibleSearchResult>> search(int versionId, String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    // 1. Check if query matches book names locally
    final books = _matchBooks(q);
    if (books.isNotEmpty) return books;

    // 2. Try to resolve to a USFM reference
    final usfm = _resolveQueryToUsfm(q);
    if (usfm == null) {
      // Return empty list if no book or reference matched.
      // The UI will show a premium fallback message.
      return const [];
    }

    try {
      final content = await getChapterContent(versionId, usfm);
      // Parse verses from HTML content and return as search results
      final verses = _extractVerseSummaries(content.content, usfm);
      return verses;
    } catch (_) {
      return const [];
    }
  }

  // ── Search Book Matcher ──────────────────────────────────────────────────
  static List<BibleSearchResult> _matchBooks(String query) {
    final lower = query.toLowerCase().trim();
    final results = <BibleSearchResult>[];

    for (final entry in _usfmBookNames.entries) {
      // Exact or partial match (e.g. "John" -> John, 1 John, 2 John)
      if (entry.value.toLowerCase().contains(lower)) {
        // "3 John" shouldn't match "3" unless the user types "3 john".
        // A simple contain is okay, but if query is short and numeric it's bad.
        // Let's only match if query is > 2 chars or starts with query.
        if (lower.length > 2 || entry.value.toLowerCase().startsWith(lower)) {
          results.add(
            BibleSearchResult(
              ref: entry.value,
              text: 'Book of the Bible',
              chapterId: '${entry.key}.1',
            ),
          );
        }
      }
    }
    return results;
  }

  // ── Internal Helpers ────────────────────────────────────────────────────────

  /// Maps human-readable and USFM references to a canonical USFM string
  /// that the YouVersion passages endpoint accepts.
  ///
  /// Examples:
  ///   "John 3:16"  → "JHN.3.16"
  ///   "Romans 8"   → "ROM.8"
  ///   "Psalm 23"   → "PSA.23"
  ///   "JHN.3.16"   → "JHN.3.16" (pass-through)
  ///   "Genesis"    → "GEN.1"     (first chapter of book)
  static String? _resolveQueryToUsfm(String query) {
    final q = query.trim();

    // Already in USFM dot-notation (e.g. "JHN.3.16")
    if (RegExp(r'^[A-Z1-3]{2,3}\.\d+(\.\d+)?$').hasMatch(q)) {
      return q;
    }

    // Human reference: "Book Chapter:Verse" or "Book Chapter"
    // e.g. "John 3:16", "Romans 8", "1 Corinthians 13:4"
    final human = RegExp(
      r'^((?:\d\s+)?[A-Za-z]+(?:\s+of\s+[A-Za-z]+)?)\s*(\d+)?(?::(\d+))?$',
    ).firstMatch(q);

    if (human != null) {
      final bookName = human.group(1)?.trim() ?? '';
      final chapter = human.group(2);
      final verse = human.group(3);
      final bookUsfm = _bookNameToUsfm(bookName);
      if (bookUsfm == null) return null;
      if (chapter == null) return '$bookUsfm.1'; // Open to chapter 1
      if (verse == null) return '$bookUsfm.$chapter';
      return '$bookUsfm.$chapter.$verse';
    }

    return null;
  }

  /// Extracts plain-text verse summaries from YouVersion HTML for search results.
  static List<BibleSearchResult> _extractVerseSummaries(
    String html,
    String chapterId,
  ) {
    if (html.trim().isEmpty) return const [];
    // Strip all HTML tags
    final text = html
        .replaceAll(RegExp('<[^>]+>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (text.isEmpty) return const [];

    // Return the chapter as a single search result
    return [
      BibleSearchResult(
        ref: _usfmToHuman(chapterId),
        text: text.length > 200 ? '${text.substring(0, 200)}…' : text,
        chapterId: chapterId.contains('.')
            ? chapterId.split('.').take(2).join('.')
            : chapterId,
      ),
    ];
  }

  /// Converts e.g. "JHN.3.16" → "John 3:16", "ROM.8" → "Romans 8"
  static String _usfmToHuman(String usfm) {
    final parts = usfm.split('.');
    if (parts.isEmpty) return usfm;
    final bookName = _usfmBookNames[parts[0]] ?? parts[0];
    if (parts.length == 1) return bookName;
    if (parts.length == 2) return '$bookName ${parts[1]}';
    return '$bookName ${parts[1]}:${parts[2]}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Book name → USFM lookup table (66 canonical books)
  // ─────────────────────────────────────────────────────────────────────────

  static String? _bookNameToUsfm(String name) {
    final lower = name.toLowerCase().trim();
    return _nameToUsfm[lower] ??
        _nameToUsfm.entries
            .where((e) => e.key.startsWith(lower) || lower.startsWith(e.key))
            .map((e) => e.value)
            .firstOrNull;
  }

  static const Map<String, String> _nameToUsfm = {
    'genesis': 'GEN',
    'gen': 'GEN',
    'exodus': 'EXO',
    'exo': 'EXO',
    'leviticus': 'LEV',
    'lev': 'LEV',
    'numbers': 'NUM',
    'num': 'NUM',
    'deuteronomy': 'DEU',
    'deu': 'DEU',
    'deut': 'DEU',
    'joshua': 'JOS',
    'jos': 'JOS',
    'josh': 'JOS',
    'judges': 'JDG',
    'jdg': 'JDG',
    'judg': 'JDG',
    'ruth': 'RUT',
    'rut': 'RUT',
    '1 samuel': '1SA',
    '1sa': '1SA',
    '1 sam': '1SA',
    '2 samuel': '2SA',
    '2sa': '2SA',
    '2 sam': '2SA',
    '1 kings': '1KI',
    '1ki': '1KI',
    '2 kings': '2KI',
    '2ki': '2KI',
    '1 chronicles': '1CH',
    '1ch': '1CH',
    '1 chron': '1CH',
    '2 chronicles': '2CH',
    '2ch': '2CH',
    '2 chron': '2CH',
    'ezra': 'EZR',
    'ezr': 'EZR',
    'nehemiah': 'NEH',
    'neh': 'NEH',
    'esther': 'EST',
    'est': 'EST',
    'job': 'JOB',
    'psalm': 'PSA',
    'psa': 'PSA',
    'psalms': 'PSA',
    'ps': 'PSA',
    'proverbs': 'PRO',
    'pro': 'PRO',
    'prov': 'PRO',
    'ecclesiastes': 'ECC',
    'ecc': 'ECC',
    'eccl': 'ECC',
    'song of solomon': 'SNG',
    'sng': 'SNG',
    'song of songs': 'SNG',
    'isaiah': 'ISA',
    'isa': 'ISA',
    'jeremiah': 'JER',
    'jer': 'JER',
    'lamentations': 'LAM',
    'lam': 'LAM',
    'ezekiel': 'EZK',
    'ezk': 'EZK',
    'ezek': 'EZK',
    'daniel': 'DAN',
    'dan': 'DAN',
    'hosea': 'HOS',
    'hos': 'HOS',
    'joel': 'JOL',
    'jol': 'JOL',
    'amos': 'AMO',
    'amo': 'AMO',
    'obadiah': 'OBA',
    'oba': 'OBA',
    'jonah': 'JON',
    'jon': 'JON',
    'micah': 'MIC',
    'mic': 'MIC',
    'nahum': 'NAM',
    'nam': 'NAM',
    'habakkuk': 'HAB',
    'hab': 'HAB',
    'zephaniah': 'ZEP',
    'zep': 'ZEP',
    'zeph': 'ZEP',
    'haggai': 'HAG',
    'hag': 'HAG',
    'zechariah': 'ZEC',
    'zec': 'ZEC',
    'zech': 'ZEC',
    'malachi': 'MAL',
    'mal': 'MAL',
    'matthew': 'MAT',
    'mat': 'MAT',
    'matt': 'MAT',
    'mark': 'MRK',
    'mrk': 'MRK',
    'mar': 'MRK',
    'luke': 'LUK',
    'luk': 'LUK',
    'john': 'JHN',
    'jhn': 'JHN',
    'jn': 'JHN',
    'acts': 'ACT',
    'act': 'ACT',
    'romans': 'ROM',
    'rom': 'ROM',
    '1 corinthians': '1CO',
    '1co': '1CO',
    '1 cor': '1CO',
    '2 corinthians': '2CO',
    '2co': '2CO',
    '2 cor': '2CO',
    'galatians': 'GAL',
    'gal': 'GAL',
    'ephesians': 'EPH',
    'eph': 'EPH',
    'philippians': 'PHP',
    'php': 'PHP',
    'phil': 'PHP',
    'colossians': 'COL',
    'col': 'COL',
    '1 thessalonians': '1TH',
    '1th': '1TH',
    '1 thess': '1TH',
    '2 thessalonians': '2TH',
    '2th': '2TH',
    '2 thess': '2TH',
    '1 timothy': '1TI',
    '1ti': '1TI',
    '1 tim': '1TI',
    '2 timothy': '2TI',
    '2ti': '2TI',
    '2 tim': '2TI',
    'titus': 'TIT',
    'tit': 'TIT',
    'philemon': 'PHM',
    'phm': 'PHM',
    'hebrews': 'HEB',
    'heb': 'HEB',
    'james': 'JAS',
    'jas': 'JAS',
    '1 peter': '1PE',
    '1pe': '1PE',
    '1 pet': '1PE',
    '2 peter': '2PE',
    '2pe': '2PE',
    '2 pet': '2PE',
    '1 john': '1JN',
    '1jn': '1JN',
    '2 john': '2JN',
    '2jn': '2JN',
    '3 john': '3JN',
    '3jn': '3JN',
    'jude': 'JUD',
    'jud': 'JUD',
    'revelation': 'REV',
    'rev': 'REV',
    'revelations': 'REV',
  };

  // USFM → human book name (for display)
  static const Map<String, String> _usfmBookNames = {
    'GEN': 'Genesis',
    'EXO': 'Exodus',
    'LEV': 'Leviticus',
    'NUM': 'Numbers',
    'DEU': 'Deuteronomy',
    'JOS': 'Joshua',
    'JDG': 'Judges',
    'RUT': 'Ruth',
    '1SA': '1 Samuel',
    '2SA': '2 Samuel',
    '1KI': '1 Kings',
    '2KI': '2 Kings',
    '1CH': '1 Chronicles',
    '2CH': '2 Chronicles',
    'EZR': 'Ezra',
    'NEH': 'Nehemiah',
    'EST': 'Esther',
    'JOB': 'Job',
    'PSA': 'Psalms',
    'PRO': 'Proverbs',
    'ECC': 'Ecclesiastes',
    'SNG': 'Song of Solomon',
    'ISA': 'Isaiah',
    'JER': 'Jeremiah',
    'LAM': 'Lamentations',
    'EZK': 'Ezekiel',
    'DAN': 'Daniel',
    'HOS': 'Hosea',
    'JOL': 'Joel',
    'AMO': 'Amos',
    'OBA': 'Obadiah',
    'JON': 'Jonah',
    'MIC': 'Micah',
    'NAM': 'Nahum',
    'HAB': 'Habakkuk',
    'ZEP': 'Zephaniah',
    'HAG': 'Haggai',
    'ZEC': 'Zechariah',
    'MAL': 'Malachi',
    'MAT': 'Matthew',
    'MRK': 'Mark',
    'LUK': 'Luke',
    'JHN': 'John',
    'ACT': 'Acts',
    'ROM': 'Romans',
    '1CO': '1 Corinthians',
    '2CO': '2 Corinthians',
    'GAL': 'Galatians',
    'EPH': 'Ephesians',
    'PHP': 'Philippians',
    'COL': 'Colossians',
    '1TH': '1 Thessalonians',
    '2TH': '2 Thessalonians',
    '1TI': '1 Timothy',
    '2TI': '2 Timothy',
    'TIT': 'Titus',
    'PHM': 'Philemon',
    'HEB': 'Hebrews',
    'JAS': 'James',
    '1PE': '1 Peter',
    '2PE': '2 Peter',
    '1JN': '1 John',
    '2JN': '2 John',
    '3JN': '3 John',
    'JUD': 'Jude',
    'REV': 'Revelation',
  };
}

/// Typed exception for all Bible API errors.
///
/// The [message] is always a **user-safe** sentence — it is what
/// surfaces in the UI. Technical detail (status code, raw
/// `http.Response.body`, exception chain) belongs in the
/// [technicalDetails] getter, which the repository forwards to
/// the `ErrorHandler` (Sentry / Crashlytics) but never to the user.
class BibleApiException implements Exception {
  const BibleApiException(this.message, {this.statusCode})
      : kind = BibleApiErrorKind.unknown;

  /// 401/403 — the API key is rejected or out of scope.
  const BibleApiException.auth(this.message, {required this.statusCode})
      : kind = BibleApiErrorKind.auth;

  /// 404 — the requested passage does not exist for this version.
  const BibleApiException.notFound(this.message, {required this.statusCode})
      : kind = BibleApiErrorKind.notFound;

  /// SocketException / TimeoutException — the device is offline or
  /// the request is too slow.
  const BibleApiException.network(this.message, {this.statusCode})
      : kind = BibleApiErrorKind.network;

  final String message;
  final int? statusCode;
  final BibleApiErrorKind kind;

  /// Anything the UI must NOT show. The repository forwards this
  /// string to Sentry / Crashlytics via `ErrorHandler.handle` and
  /// never to the screen.
  @visibleForTesting
  String get technicalDetails {
    final code = statusCode == null ? '—' : statusCode.toString();
    return 'BibleApiException[$kind, $code]: $message';
  }

  @override
  String toString() => message;
}

enum BibleApiErrorKind { auth, notFound, network, unknown }
