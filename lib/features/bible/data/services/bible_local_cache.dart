import 'package:kingdom_heir/core/storage/cache_keys.dart';
import 'package:kingdom_heir/core/storage/cache_manager.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';

/// SharedPreferences-backed cache for Bible content and user state.
///
/// This cache is a PERFORMANCE layer only.  The YouVersion API is always the
/// authoritative source of scripture.  Cached content is served when available
/// to reduce latency; it never replaces a fresh API call on cold start.
class BibleLocalCache {
  BibleLocalCache(this._cacheManager);
  final CacheManager _cacheManager;

  // ── Keys ─────────────────────────────────────────────────────────────────────
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
    await _cacheManager.write(
      key: CacheKeys.bibleBooks(versionId),
      payload: jsonList,
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
  }

  List<BibleBook>? getCachedBooks(int versionId) {
    final cached = _cacheManager.read(
      key: CacheKeys.bibleBooks(versionId),
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
    if (cached == null) return null;
    try {
      final list = cached as List<dynamic>;
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
    await _cacheManager.write(
      key: CacheKeys.bibleChapters(versionId, bookId),
      payload: jsonList,
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
  }

  List<BibleChapter>? getCachedChapters(int versionId, String bookId) {
    final cached = _cacheManager.read(
      key: CacheKeys.bibleChapters(versionId, bookId),
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
    if (cached == null) return null;
    try {
      final list = cached as List<dynamic>;
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
    await _cacheManager.write(
      key: CacheKeys.bibleContent(versionId, chapterId),
      payload: map,
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
  }

  BibleChapterContent? getCachedContent(int versionId, String chapterId) {
    final cached = _cacheManager.read(
      key: CacheKeys.bibleContent(versionId, chapterId),
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
    if (cached == null) return null;
    try {
      final map = cached as Map<String, dynamic>;
      return BibleChapterContent.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // ── Last Selected Version ─────────────────────────────────────────────────────

  Future<void> saveLastVersion(int versionId) async {
    await _cacheManager.write(
      key: CacheKeys.bibleLastVersion,
      payload: versionId,
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
  }

  int? getLastVersion() {
    return _cacheManager.read(
      key: CacheKeys.bibleLastVersion,
      feature: 'bible',
      repository: 'BibleLocalCache',
    ) as int?;
  }

  // ── Last Reading Position ─────────────────────────────────────────────────────

  Future<void> saveLastPosition({
    required String bookId,
    required String chapterId,
  }) async {
    await _cacheManager.write(
      key: CacheKeys.bibleLastBook,
      payload: bookId,
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
    await _cacheManager.write(
      key: CacheKeys.bibleLastChapter,
      payload: chapterId,
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
  }

  ({String bookId, String chapterId})? getLastPosition() {
    final book = _cacheManager.read(
      key: CacheKeys.bibleLastBook,
      feature: 'bible',
      repository: 'BibleLocalCache',
    ) as String?;
    final chapter = _cacheManager.read(
      key: CacheKeys.bibleLastChapter,
      feature: 'bible',
      repository: 'BibleLocalCache',
    ) as String?;
    
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
        
    await _cacheManager.write(
      key: CacheKeys.bibleRecentSearches,
      payload: updated,
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
  }

  List<String> getRecentSearches() {
    final cached = _cacheManager.read(
      key: CacheKeys.bibleRecentSearches,
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
    if (cached == null) return const [];
    try {
      return (cached as List<dynamic>).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  Future<void> clearRecentSearches() async {
    await _cacheManager.invalidate(
      CacheKeys.bibleRecentSearches,
      feature: 'bible',
      repository: 'BibleLocalCache',
    );
  }
}
