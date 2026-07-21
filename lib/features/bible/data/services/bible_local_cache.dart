import 'dart:convert';

import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed cache for Bible content and user state.
///
/// This cache is a PERFORMANCE layer only.  The YouVersion API is always the
/// authoritative source of scripture.  Cached content is served when available
/// to reduce latency; it never replaces a fresh API call on cold start.
class BibleLocalCache {
  BibleLocalCache(this._prefs);
  final SharedPreferences _prefs;

  // ── Keys ─────────────────────────────────────────────────────────────────────
  static const _booksPrefix = 'bible_books_v2_';
  static const _chaptersPrefix = 'bible_chapters_v2_';
  static const _contentPrefix = 'bible_content_v2_';
  static const _lastVersionKey = 'bible_last_version_id';
  static const _lastBookKey = 'bible_last_book_id';
  static const _lastChapterKey = 'bible_last_chapter_id';
  static const _recentSearchesKey = 'bible_recent_searches_v1';
  static const _maxRecentSearches = 10;

  // ── Books ─────────────────────────────────────────────────────────────────────

  Future<void> cacheBooks(int versionId, List<BibleBook> books) async {
    final jsonList = books
        .map(
          (b) => {
            'id': b.id,
            'bibleId': b.bibleId,
            'abbreviation': b.abbreviation,
            'name': b.name,
            'nameLong': b.nameLong,
          },
        )
        .toList();
    await _prefs.setString('$_booksPrefix$versionId', jsonEncode(jsonList));
  }

  List<BibleBook>? getCachedBooks(int versionId) {
    final str = _prefs.getString('$_booksPrefix$versionId');
    if (str == null) return null;
    try {
      final list = jsonDecode(str) as List<dynamic>;
      return list
          .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── Chapters ──────────────────────────────────────────────────────────────────

  Future<void> cacheChapters(
    int versionId,
    String bookId,
    List<BibleChapter> chapters,
  ) async {
    final jsonList = chapters
        .map(
          (c) => {
            'id': c.id,
            'bibleId': c.bibleId,
            'bookId': c.bookId,
            'number': c.number,
            'reference': c.reference,
          },
        )
        .toList();
    await _prefs.setString(
      '$_chaptersPrefix${versionId}_$bookId',
      jsonEncode(jsonList),
    );
  }

  List<BibleChapter>? getCachedChapters(int versionId, String bookId) {
    final str = _prefs.getString('$_chaptersPrefix${versionId}_$bookId');
    if (str == null) return null;
    try {
      final list = jsonDecode(str) as List<dynamic>;
      return list
          .map((e) => BibleChapter.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── Chapter Content ───────────────────────────────────────────────────────────

  Future<void> cacheContent(
    int versionId,
    String chapterId,
    BibleChapterContent content,
  ) async {
    final map = {
      'id': content.id,
      'bibleId': content.bibleId,
      'number': content.number,
      'bookId': content.bookId,
      'reference': content.reference,
      'content': content.content,
      'nextChapterId': content.nextChapterId,
      'previousChapterId': content.previousChapterId,
    };
    await _prefs.setString(
      '$_contentPrefix${versionId}_$chapterId',
      jsonEncode(map),
    );
  }

  BibleChapterContent? getCachedContent(int versionId, String chapterId) {
    final str = _prefs.getString('$_contentPrefix${versionId}_$chapterId');
    if (str == null) return null;
    try {
      final map = jsonDecode(str) as Map<String, dynamic>;
      return BibleChapterContent.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // ── Last Selected Version ─────────────────────────────────────────────────────

  Future<void> saveLastVersion(int versionId) async {
    await _prefs.setInt(_lastVersionKey, versionId);
  }

  int? getLastVersion() => _prefs.getInt(_lastVersionKey);

  // ── Last Reading Position ─────────────────────────────────────────────────────

  Future<void> saveLastPosition({
    required String bookId,
    required String chapterId,
  }) async {
    await _prefs.setString(_lastBookKey, bookId);
    await _prefs.setString(_lastChapterKey, chapterId);
  }

  ({String bookId, String chapterId})? getLastPosition() {
    final book = _prefs.getString(_lastBookKey);
    final chapter = _prefs.getString(_lastChapterKey);
    if (book == null || chapter == null) return null;
    return (bookId: book, chapterId: chapter);
  }

  // ── Recent Searches ───────────────────────────────────────────────────────────

  Future<void> saveRecentSearch(String query) async {
    final current = getRecentSearches();
    // Deduplicate and move to front
    final updated = [query, ...current.where((s) => s != query)]
        .take(_maxRecentSearches)
        .toList();
    await _prefs.setString(_recentSearchesKey, jsonEncode(updated));
  }

  List<String> getRecentSearches() {
    final str = _prefs.getString(_recentSearchesKey);
    if (str == null) return const [];
    try {
      return (jsonDecode(str) as List<dynamic>).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(_recentSearchesKey);
  }
}
