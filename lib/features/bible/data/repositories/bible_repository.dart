import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_api_service.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_local_cache.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_supabase_service.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';

abstract class BibleRepository {
  // ── Versions ────────────────────────────────────────────────────────────────
  Future<Either<String, List<BibleVersion>>> getVersions({
    String language = 'eng',
  });

  // ── Scripture Content ────────────────────────────────────────────────────────
  Future<Either<String, List<BibleBook>>> getBooks(int versionId);
  Future<Either<String, List<BibleChapter>>> getChapters(
    int versionId,
    String bookId,
  );
  Future<Either<String, BibleChapterContent>> getChapterContent(
    int versionId,
    String chapterId,
  );
  Future<Either<String, List<BibleSearchResult>>> search(
    int versionId,
    String query,
  );

  // ── User Data ────────────────────────────────────────────────────────────────
  Future<Either<String, List<BibleBookmark>>> getBookmarks(int versionId);
  Future<Either<String, void>> addBookmark(BibleBookmark bookmark);
  Future<Either<String, void>> removeBookmark(String bookmarkId);

  Future<Either<String, List<BibleHighlight>>> getHighlights(int versionId);
  Future<Either<String, void>> addHighlight(BibleHighlight highlight);
  Future<Either<String, void>> removeHighlight(String highlightId);

  Future<Either<String, void>> updateReadingHistory(
    int versionId,
    String chapterId,
    int progressPercent,
  );
}

class BibleRepositoryImpl implements BibleRepository {
  BibleRepositoryImpl({
    required this.apiService,
    required this.localCache,
    required this.supabaseService,
  });

  final BibleApiService apiService;
  final BibleLocalCache localCache;
  final BibleSupabaseService supabaseService;

  // ── Versions ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<String, List<BibleVersion>>> getVersions({
    String language = 'eng',
  }) async {
    try {
      final versions = await apiService.getBibleVersions(language: language);
      return right(versions);
    } catch (e) {
      return left('Failed to load Bible versions: $e');
    }
  }

  // ── Books ─────────────────────────────────────────────────────────────────────

  @override
  Future<Either<String, List<BibleBook>>> getBooks(int versionId) async {
    try {
      final cached = localCache.getCachedBooks(versionId);
      if (cached != null && cached.isNotEmpty) return right(cached);

      final books = await apiService.getBooks(versionId);
      await localCache.cacheBooks(versionId, books);
      return right(books);
    } catch (e) {
      return left('Failed to get books: $e');
    }
  }

  // ── Chapters ──────────────────────────────────────────────────────────────────

  @override
  Future<Either<String, List<BibleChapter>>> getChapters(
    int versionId,
    String bookId,
  ) async {
    try {
      final cached = localCache.getCachedChapters(versionId, bookId);
      if (cached != null && cached.isNotEmpty) return right(cached);

      final chapters = await apiService.getChapters(versionId, bookId);
      await localCache.cacheChapters(versionId, bookId, chapters);
      return right(chapters);
    } catch (e) {
      return left('Failed to get chapters: $e');
    }
  }

  // ── Chapter Content ───────────────────────────────────────────────────────────

  @override
  Future<Either<String, BibleChapterContent>> getChapterContent(
    int versionId,
    String chapterId,
  ) async {
    try {
      final cached = localCache.getCachedContent(versionId, chapterId);
      if (cached != null) return right(cached);

      final content = await apiService.getChapterContent(versionId, chapterId);
      await localCache.cacheContent(versionId, chapterId, content);
      return right(content);
    } catch (e) {
      return left('Failed to get chapter content: $e');
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────────

  @override
  Future<Either<String, List<BibleSearchResult>>> search(
    int versionId,
    String query,
  ) async {
    try {
      final results = await apiService.search(versionId, query);
      return right(results);
    } catch (e) {
      return left('Search failed: $e');
    }
  }

  // ── User data — delegate to Supabase ─────────────────────────────────────────

  @override
  Future<Either<String, List<BibleBookmark>>> getBookmarks(int versionId) =>
      supabaseService.getBookmarks(versionId);

  @override
  Future<Either<String, void>> addBookmark(BibleBookmark bookmark) =>
      supabaseService.addBookmark(bookmark);

  @override
  Future<Either<String, void>> removeBookmark(String bookmarkId) =>
      supabaseService.removeBookmark(bookmarkId);

  @override
  Future<Either<String, List<BibleHighlight>>> getHighlights(
    int versionId,
  ) =>
      supabaseService.getHighlights(versionId);

  @override
  Future<Either<String, void>> addHighlight(BibleHighlight highlight) =>
      supabaseService.addHighlight(highlight);

  @override
  Future<Either<String, void>> removeHighlight(String highlightId) =>
      supabaseService.removeHighlight(highlightId);

  @override
  Future<Either<String, void>> updateReadingHistory(
    int versionId,
    String chapterId,
    int progressPercent,
  ) =>
      supabaseService.updateReadingHistory(
        versionId,
        chapterId,
        progressPercent,
      );
}
