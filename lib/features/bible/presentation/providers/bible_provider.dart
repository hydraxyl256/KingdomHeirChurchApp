import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/features/bible/data/repositories/bible_repository.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_api_service.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_local_cache.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_supabase_service.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure providers
// ─────────────────────────────────────────────────────────────────────────────

final bibleLocalCacheProvider = Provider<BibleLocalCache>((ref) {
  return BibleLocalCache(ref.watch(sharedPreferencesProvider));
});

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepositoryImpl(
    apiService:      BibleApiService(),
    localCache:      ref.watch(bibleLocalCacheProvider),
    supabaseService: BibleSupabaseService(Supabase.instance.client),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Bible Versions (YouVersion numeric IDs)
// ─────────────────────────────────────────────────────────────────────────────

final bibleVersionsProvider =
    FutureProvider<List<BibleVersion>>((ref) async {
  final repo   = ref.watch(bibleRepositoryProvider);
  final result = await repo.getVersions();
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Active Bible version — persisted across sessions
// ─────────────────────────────────────────────────────────────────────────────

/// KJV = 1 on YouVersion Platform
const _defaultVersionId = 1;

class BibleVersionNotifier extends StateNotifier<int> {
  BibleVersionNotifier(this._cache)
      : super(_cache.getLastVersion() ?? _defaultVersionId);

  final BibleLocalCache _cache;

  Future<void> setVersion(int id) async {
    state = id;
    await _cache.saveLastVersion(id);
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
  final repo      = ref.watch(bibleRepositoryProvider);
  final result    = await repo.getBooks(versionId);
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
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
      bookId:    bookId    ?? this.bookId,
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
        bookId:    pos.bookId,
        chapterId: pos.chapterId,
      );
    }
    return BibleNavigationState();
  }

  Future<void> navigate({required String bookId, required String chapterId}) async {
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
  final repo      = ref.watch(bibleRepositoryProvider);
  final result    = await repo.getChapters(versionId, bookId);
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Current chapter content
// ─────────────────────────────────────────────────────────────────────────────

final bibleContentProvider =
    FutureProvider<BibleChapterContent>((ref) async {
  final versionId = ref.watch(bibleVersionProvider);
  final nav       = ref.watch(bibleNavigationProvider);
  final repo      = ref.watch(bibleRepositoryProvider);
  final result    = await repo.getChapterContent(versionId, nav.chapterId);
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Search — reference-based (YouVersion has no keyword search)
// ─────────────────────────────────────────────────────────────────────────────

final bibleSearchProvider =
    FutureProvider.family<List<BibleSearchResult>, String>(
        (ref, query) async {
  if (query.trim().isEmpty) return const [];
  final versionId = ref.watch(bibleVersionProvider);
  final repo      = ref.watch(bibleRepositoryProvider);
  final result    = await repo.search(versionId, query);
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
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
