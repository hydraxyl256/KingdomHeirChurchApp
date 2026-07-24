import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/features/bible/data/repositories/bible_repository.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_api_service.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_local_cache.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_supabase_service.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_version_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure providers
// ─────────────────────────────────────────────────────────────────────────────

final bibleLocalCacheProvider = Provider<BibleLocalCache>((ref) {
  return BibleLocalCache(ref.watch(cacheManagerProvider));
});

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepositoryImpl(
    apiService: BibleApiService(),
    localCache: ref.watch(bibleLocalCacheProvider),
    supabaseService: BibleSupabaseService(Supabase.instance.client),
  );
});

/// Unwraps an `Either<String, T>` returned by the repository. The
/// right side flows through; the left side is wrapped in an
/// [AsyncError] carrying a [Failure] so the UI can render the
/// friendly message via `Failure.toString` (which returns
/// `failure.message`) without ever leaking the raw exception
/// class name / status code.
T _unwrap<T>(Either<String, T> result) {
  return result.fold(
    (String l) => throw BibleFailureException(
      // Use UnknownFailure for backward compatibility — the
      // repository already chose a curated, user-safe message.
      UnknownFailure(message: l),
    ),
    (T r) => r,
  );
}

/// Thrown by the providers so that `AsyncError.error` is a typed
/// [Failure]. The UI checks `error is BibleFailureException` and
/// surfaces `failure.message`.
class BibleFailureException implements Exception {
  const BibleFailureException(this.failure);
  final Failure failure;

  @override
  String toString() => failure.toString();
}

/// Maps the error surfaced by any `bible*Provider` to a user-safe
/// string. NEVER returns the raw exception's toString.
///
/// Every Bible UI should pipe its `AsyncValue.error` through this
/// helper before rendering — otherwise a future call-site that
/// forgets the filter will silently leak the exception class
/// name and (potentially) the status code.
///
/// The provider throws [BibleFailureException] which wraps a
/// [Failure]. Older call-sites might surface raw `Exception`
/// strings — those go through the curated fallback.
String bibleFriendlyErrorMessage(Object e) {
  if (e is BibleFailureException) {
    return e.failure.toString();
  }
  if (e is Failure) {
    return e.toString();
  }
  return 'Unable to load this content. Retry, check your '
      'connection, or report the issue if it persists.';
}

// ─────────────────────────────────────────────────────────────────────────────
// Bible Versions (YouVersion numeric IDs)
// ─────────────────────────────────────────────────────────────────────────────

final bibleVersionsProvider = FutureProvider<List<BibleVersion>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final result = await repo.getVersions();
  return _unwrap(result);
});

// ─────────────────────────────────────────────────────────────────────────────
// Active Bible version — persisted across sessions
// ─────────────────────────────────────────────────────────────────────────────

class BibleVersionNotifier extends StateNotifier<int> {
  BibleVersionNotifier(this._cache)
      : super(BibleVersionConfig.normalizeVersionId(_cache.getLastVersion()));

  final BibleLocalCache _cache;

  Future<void> setVersion(int id) async {
    final normalizedId = BibleVersionConfig.normalizeVersionId(id);
    state = normalizedId;
    await _cache.saveLastVersion(normalizedId);
  }
}

final bibleVersionProvider =
    StateNotifierProvider<BibleVersionNotifier, int>((ref) {
  return BibleVersionNotifier(ref.watch(bibleLocalCacheProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Books
// ─────────────────────────────────────────────────────────────────────────────

final bibleBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  final versionId = ref.watch(bibleVersionProvider);
  final repo = ref.watch(bibleRepositoryProvider);
  final result = await repo.getBooks(versionId);
  return _unwrap(result);
});

// ─────────────────────────────────────────────────────────────────────────────
// Navigation state — persisted across sessions
// ─────────────────────────────────────────────────────────────────────────────

class BibleNavigationState {
  BibleNavigationState({this.bookId = 'JHN', this.chapterId = 'JHN.1'});

  final String bookId;
  final String chapterId;

  BibleNavigationState copyWith({String? bookId, String? chapterId}) {
    return BibleNavigationState(
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
    );
  }
}

class BibleNavigationNotifier extends StateNotifier<BibleNavigationState> {
  BibleNavigationNotifier(this._cache) : super(_buildInitialState(_cache));

  final BibleLocalCache _cache;

  static BibleNavigationState _buildInitialState(BibleLocalCache cache) {
    final pos = cache.getLastPosition();
    if (pos != null) {
      return BibleNavigationState(
        bookId: pos.bookId,
        chapterId: pos.chapterId,
      );
    }
    return BibleNavigationState();
  }

  Future<void> navigate(
      {required String bookId, required String chapterId,}) async {
    state = BibleNavigationState(bookId: bookId, chapterId: chapterId);
    await _cache.saveLastPosition(bookId: bookId, chapterId: chapterId);
  }

  Future<void> navigateToChapter(String chapterId) async {
    final bookId = chapterId.split('.').first;
    await navigate(bookId: bookId, chapterId: chapterId);
  }
}

final bibleNavigationProvider =
    StateNotifierProvider<BibleNavigationNotifier, BibleNavigationState>(
  (ref) => BibleNavigationNotifier(ref.watch(bibleLocalCacheProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Chapters for a given book
// ─────────────────────────────────────────────────────────────────────────────

final bibleChaptersProvider =
    FutureProvider.family<List<BibleChapter>, String>((ref, bookId) async {
  final versionId = ref.watch(bibleVersionProvider);
  final repo = ref.watch(bibleRepositoryProvider);
  final result = await repo.getChapters(versionId, bookId);
  return _unwrap(result);
});

// ─────────────────────────────────────────────────────────────────────────────
// Current chapter content
// ─────────────────────────────────────────────────────────────────────────────

final bibleContentProvider = FutureProvider<BibleChapterContent>((ref) async {
  final versionId = ref.watch(bibleVersionProvider);
  final nav = ref.watch(bibleNavigationProvider);
  final repo = ref.watch(bibleRepositoryProvider);
  final result = await repo.getChapterContent(versionId, nav.chapterId);
  return _unwrap(result);
});

// ─────────────────────────────────────────────────────────────────────────────
// Search — reference-based (YouVersion has no keyword search)
// ─────────────────────────────────────────────────────────────────────────────

final bibleSearchProvider =
    FutureProvider.family<List<BibleSearchResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  final versionId = ref.watch(bibleVersionProvider);
  final repo = ref.watch(bibleRepositoryProvider);
  final result = await repo.search(versionId, query);
  return _unwrap(result);
});

// ─────────────────────────────────────────────────────────────────────────────
// Recent searches — persisted list of up to 10 query strings
// ─────────────────────────────────────────────────────────────────────────────

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier(this._cache) : super(_cache.getRecentSearches());

  final BibleLocalCache _cache;

  Future<void> add(String query) async {
    await _cache.saveRecentSearch(query);
    state = _cache.getRecentSearches();
  }

  Future<void> clear() async {
    await _cache.clearRecentSearches();
    state = const [];
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>(
  (ref) => RecentSearchesNotifier(ref.watch(bibleLocalCacheProvider)),
);
