import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kingdom_heir/core/config/env.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';

/// YouVersion Platform REST API client.
///
/// Base URL:   https://api.youversion.com/v1
/// Auth header: X-YVP-App-Key: <key>
///
/// All methods throw a [BibleApiException] on network, auth, or parse errors.
/// No mock/fallback data is ever returned — callers display error states.
class BibleApiService {
  BibleApiService() : _apiKey = Env.youVersionKey;

  final String _apiKey;

  static const _baseUrl = 'https://api.youversion.com/v1';
  static const _timeout = Duration(seconds: 15);

  // Default English YouVersion Bible ID (KJV = 1, NIV = 111, ESV = 59)
  // This is used only as a fallback; the user's chosen version overrides it.
  static const int defaultVersionId = 1; // KJV

  Map<String, String> get _headers => {
        'X-YVP-App-Key': _apiKey,
        'Accept':        'application/json',
      };

  // ── Helper ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw BibleApiException(
          'Authentication failed. Check your YouVersion API key.',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode == 404) {
        throw BibleApiException(
          'Content not found: $path',
          statusCode: 404,
        );
      }
      if (response.statusCode == 429) {
        throw const BibleApiException(
          'Rate limit reached. Please wait a moment and try again.',
          statusCode: 429,
        );
      }
      if (response.statusCode != 200) {
        throw BibleApiException(
          'API error ${response.statusCode} for $path',
          statusCode: response.statusCode,
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw const BibleApiException(
        'Request timed out. Please check your internet connection.',
      );
    } on BibleApiException {
      rethrow;
    } catch (e) {
      throw BibleApiException('Network error: $e');
    }
  }

  // ── Versions ────────────────────────────────────────────────────────────────

  /// Returns available Bible versions filtered to English by default.
  Future<List<BibleVersion>> getBibleVersions({String language = 'eng'}) async {
    // YouVersion: GET /bibles?language_tag=eng
    final json = await _get('/bibles?language_tag=$language');
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => BibleVersion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Books ────────────────────────────────────────────────────────────────────

  /// Returns the 66 books for the given Bible [versionId].
  Future<List<BibleBook>> getBooks(int versionId) async {
    final json = await _get('/bibles/$versionId/books');
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Chapters ────────────────────────────────────────────────────────────────

  /// Returns chapter list for the given book USFM code (e.g. "GEN", "JHN").
  Future<List<BibleChapter>> getChapters(int versionId, String bookUsfm) async {
    final json =
        await _get('/bibles/$versionId/books/$bookUsfm/chapters');
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
    final json = await _get('/bibles/$versionId/passages/$chapterId');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return BibleChapterContent.fromJson(data);
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

    // 1. Try to resolve to a USFM reference
    final usfm = _resolveQueryToUsfm(q);
    if (usfm == null) return const [];

    try {
      final content = await getChapterContent(versionId, usfm);
      // Parse verses from HTML content and return as search results
      final verses = _extractVerseSummaries(content.content, usfm);
      return verses;
    } catch (_) {
      return const [];
    }
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
      final bookName  = human.group(1)?.trim() ?? '';
      final chapter   = human.group(2);
      final verse     = human.group(3);
      final bookUsfm  = _bookNameToUsfm(bookName);
      if (bookUsfm == null) return null;
      if (chapter == null) return '$bookUsfm.1'; // Open to chapter 1
      if (verse   == null) return '$bookUsfm.$chapter';
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
        ref:       _usfmToHuman(chapterId),
        text:      text.length > 200 ? '${text.substring(0, 200)}…' : text,
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
    'genesis': 'GEN',        'gen': 'GEN',
    'exodus': 'EXO',         'exo': 'EXO',
    'leviticus': 'LEV',      'lev': 'LEV',
    'numbers': 'NUM',        'num': 'NUM',
    'deuteronomy': 'DEU',    'deu': 'DEU', 'deut': 'DEU',
    'joshua': 'JOS',         'jos': 'JOS', 'josh': 'JOS',
    'judges': 'JDG',         'jdg': 'JDG', 'judg': 'JDG',
    'ruth': 'RUT',           'rut': 'RUT',
    '1 samuel': '1SA',       '1sa': '1SA', '1 sam': '1SA',
    '2 samuel': '2SA',       '2sa': '2SA', '2 sam': '2SA',
    '1 kings': '1KI',        '1ki': '1KI',
    '2 kings': '2KI',        '2ki': '2KI',
    '1 chronicles': '1CH',   '1ch': '1CH', '1 chron': '1CH',
    '2 chronicles': '2CH',   '2ch': '2CH', '2 chron': '2CH',
    'ezra': 'EZR',           'ezr': 'EZR',
    'nehemiah': 'NEH',       'neh': 'NEH',
    'esther': 'EST',         'est': 'EST',
    'job': 'JOB',
    'psalm': 'PSA',          'psa': 'PSA', 'psalms': 'PSA', 'ps': 'PSA',
    'proverbs': 'PRO',       'pro': 'PRO', 'prov': 'PRO',
    'ecclesiastes': 'ECC',   'ecc': 'ECC', 'eccl': 'ECC',
    'song of solomon': 'SNG','sng': 'SNG', 'song of songs': 'SNG',
    'isaiah': 'ISA',         'isa': 'ISA',
    'jeremiah': 'JER',       'jer': 'JER',
    'lamentations': 'LAM',   'lam': 'LAM',
    'ezekiel': 'EZK',        'ezk': 'EZK', 'ezek': 'EZK',
    'daniel': 'DAN',         'dan': 'DAN',
    'hosea': 'HOS',          'hos': 'HOS',
    'joel': 'JOL',           'jol': 'JOL',
    'amos': 'AMO',           'amo': 'AMO',
    'obadiah': 'OBA',        'oba': 'OBA',
    'jonah': 'JON',          'jon': 'JON',
    'micah': 'MIC',          'mic': 'MIC',
    'nahum': 'NAM',          'nam': 'NAM',
    'habakkuk': 'HAB',       'hab': 'HAB',
    'zephaniah': 'ZEP',      'zep': 'ZEP', 'zeph': 'ZEP',
    'haggai': 'HAG',         'hag': 'HAG',
    'zechariah': 'ZEC',      'zec': 'ZEC', 'zech': 'ZEC',
    'malachi': 'MAL',        'mal': 'MAL',
    'matthew': 'MAT',        'mat': 'MAT', 'matt': 'MAT',
    'mark': 'MRK',           'mrk': 'MRK', 'mar': 'MRK',
    'luke': 'LUK',           'luk': 'LUK',
    'john': 'JHN',           'jhn': 'JHN', 'jn': 'JHN',
    'acts': 'ACT',           'act': 'ACT',
    'romans': 'ROM',         'rom': 'ROM',
    '1 corinthians': '1CO',  '1co': '1CO', '1 cor': '1CO',
    '2 corinthians': '2CO',  '2co': '2CO', '2 cor': '2CO',
    'galatians': 'GAL',      'gal': 'GAL',
    'ephesians': 'EPH',      'eph': 'EPH',
    'philippians': 'PHP',    'php': 'PHP', 'phil': 'PHP',
    'colossians': 'COL',     'col': 'COL',
    '1 thessalonians': '1TH','1th': '1TH', '1 thess': '1TH',
    '2 thessalonians': '2TH','2th': '2TH', '2 thess': '2TH',
    '1 timothy': '1TI',      '1ti': '1TI', '1 tim': '1TI',
    '2 timothy': '2TI',      '2ti': '2TI', '2 tim': '2TI',
    'titus': 'TIT',          'tit': 'TIT',
    'philemon': 'PHM',       'phm': 'PHM',
    'hebrews': 'HEB',        'heb': 'HEB',
    'james': 'JAS',          'jas': 'JAS',
    '1 peter': '1PE',        '1pe': '1PE', '1 pet': '1PE',
    '2 peter': '2PE',        '2pe': '2PE', '2 pet': '2PE',
    '1 john': '1JN',         '1jn': '1JN',
    '2 john': '2JN',         '2jn': '2JN',
    '3 john': '3JN',         '3jn': '3JN',
    'jude': 'JUD',           'jud': 'JUD',
    'revelation': 'REV',     'rev': 'REV', 'revelations': 'REV',
  };

  // USFM → human book name (for display)
  static const Map<String, String> _usfmBookNames = {
    'GEN': 'Genesis',        'EXO': 'Exodus',       'LEV': 'Leviticus',
    'NUM': 'Numbers',        'DEU': 'Deuteronomy',  'JOS': 'Joshua',
    'JDG': 'Judges',         'RUT': 'Ruth',         '1SA': '1 Samuel',
    '2SA': '2 Samuel',       '1KI': '1 Kings',      '2KI': '2 Kings',
    '1CH': '1 Chronicles',   '2CH': '2 Chronicles', 'EZR': 'Ezra',
    'NEH': 'Nehemiah',       'EST': 'Esther',       'JOB': 'Job',
    'PSA': 'Psalms',         'PRO': 'Proverbs',     'ECC': 'Ecclesiastes',
    'SNG': 'Song of Solomon','ISA': 'Isaiah',       'JER': 'Jeremiah',
    'LAM': 'Lamentations',   'EZK': 'Ezekiel',      'DAN': 'Daniel',
    'HOS': 'Hosea',          'JOL': 'Joel',         'AMO': 'Amos',
    'OBA': 'Obadiah',        'JON': 'Jonah',        'MIC': 'Micah',
    'NAM': 'Nahum',          'HAB': 'Habakkuk',     'ZEP': 'Zephaniah',
    'HAG': 'Haggai',         'ZEC': 'Zechariah',    'MAL': 'Malachi',
    'MAT': 'Matthew',        'MRK': 'Mark',         'LUK': 'Luke',
    'JHN': 'John',           'ACT': 'Acts',         'ROM': 'Romans',
    '1CO': '1 Corinthians',  '2CO': '2 Corinthians','GAL': 'Galatians',
    'EPH': 'Ephesians',      'PHP': 'Philippians',  'COL': 'Colossians',
    '1TH': '1 Thessalonians','2TH': '2 Thessalonians','1TI': '1 Timothy',
    '2TI': '2 Timothy',      'TIT': 'Titus',        'PHM': 'Philemon',
    'HEB': 'Hebrews',        'JAS': 'James',        '1PE': '1 Peter',
    '2PE': '2 Peter',        '1JN': '1 John',       '2JN': '2 John',
    '3JN': '3 John',         'JUD': 'Jude',         'REV': 'Revelation',
  };
}

/// Typed exception for all Bible API errors.
class BibleApiException implements Exception {
  const BibleApiException(this.message, {this.statusCode});
  final String message;
  final int?   statusCode;

  @override
  String toString() => statusCode != null
      ? 'BibleApiException($statusCode): $message'
      : 'BibleApiException: $message';
}
