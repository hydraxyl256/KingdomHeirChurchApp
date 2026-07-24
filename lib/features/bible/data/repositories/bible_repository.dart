import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/error/error_handler.dart';
import 'package:kingdom_heir/core/error/failure.dart';
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
    } catch (e, st) {
      return _handleFailure(e, st, 'Failed to load Bible versions');
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
    } catch (e, st) {
      return _handleFailure(e, st, 'Failed to load books');
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
    } catch (e, st) {
      return _handleFailure(e, st, 'Failed to load chapters');
    }
  }

  // ── Chapter Content ───────────────────────────────────────────────────────────

  @override
  Future<Either<String, BibleChapterContent>> getChapterContent(
    int versionId,
    String chapterId,
  ) async {
    try {
      BibleChapterContent content;
      final cached = localCache.getCachedContent(versionId, chapterId);
      if (cached != null) {
        content = cached;
      } else {
        content = await apiService.getChapterContent(versionId, chapterId);
        await localCache.cacheContent(versionId, chapterId, content);
      }

      // ── Prefetch Next Chapter ────────────────────────────────────────────────
      // Fire and forget: if there's a next chapter, fetch and cache it in the background
      final nextChapterId = content.nextChapterId;
      if (nextChapterId != null && localCache.getCachedContent(versionId, nextChapterId) == null) {
        // ignore: unawaited_futures
        Future.microtask(() async {
          try {
            final nextContent = await apiService.getChapterContent(versionId, nextChapterId);
            await localCache.cacheContent(versionId, nextChapterId, nextContent);
          } catch (_) {
            // Ignore prefetch failures
          }
        });
      }

      return right(content);
    } catch (e, st) {
      return _handleFailure(e, st, 'Failed to load chapter content');
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
    } catch (e, st) {
      return _handleFailure(e, st, 'Search failed');
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

  // ── Failure handling ────────────────────────────────────────────────────────

  /// Maps any thrown error to a `left(failure.message)` and forwards
  /// the raw exception to Sentry / Crashlytics via [ErrorHandler].
  ///
  /// **Never** interpolates `$e` into the left side — that is what
  /// previously leaked `BibleApiException(403): …` to the user. The
  /// UI only ever sees the friendly message from [Failure.toString].
  static Either<String, T> _handleFailure<T>(
    Object error,
    StackTrace stack,
    String contextLabel,
  ) {
    // Forward to Sentry + Crashlytics so observability sees the
    // *real* reason (status code, technicalDetails, stack). The UI
    // does not.
    ErrorHandler.handle(error, stack);

    // Pick a user-friendly Failure. The map is order-sensitive: the
    // Bible-specific exception comes first so we keep its curated
    // message instead of the generic `Object.toString`.
    final failure = _mapError(error);
    return left(failure.message);
  }

  static Failure _mapError(Object error) {
    if (error is BibleApiException) {
      switch (error.kind) {
        case BibleApiErrorKind.auth:
          return const AuthFailure(
            message: 'Unable to load this chapter. Please try again shortly.',
          );
        case BibleApiErrorKind.notFound:
          return ServerFailure(
            message:
                'This chapter is not available in the selected Bible version.',
            code: error.statusCode,
          );
        case BibleApiErrorKind.network:
          return NetworkFailure(message: error.message);
        case BibleApiErrorKind.unknown:
          return ServerFailure(
            message: 'Unable to load this chapter. Please try again shortly.',
            code: error.statusCode,
          );
      }
    }
    return const UnknownFailure(
      message: 'Unable to load this chapter. Please try again shortly.',
    );
  }
}
