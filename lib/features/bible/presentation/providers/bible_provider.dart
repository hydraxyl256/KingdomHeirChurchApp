import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart'; // assuming sharedPreferencesProvider is here
import 'package:kingdom_heir/features/bible/data/repositories/bible_repository.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_api_service.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_local_cache.dart';
import 'package:kingdom_heir/features/bible/data/services/bible_supabase_service.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Use KJV by default.
final bibleVersionProvider =
    StateProvider<String>((ref) => 'de4e12af7f28f599-01');

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepositoryImpl(
    apiService: BibleApiService(),
    localCache: BibleLocalCache(ref.watch(sharedPreferencesProvider)),
    supabaseService: BibleSupabaseService(Supabase.instance.client),
  );
});

final bibleBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  final versionId = ref.watch(bibleVersionProvider);
  final repo = ref.watch(bibleRepositoryProvider);
  final result = await repo.getBooks(versionId);
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

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

final bibleNavigationProvider =
    StateProvider<BibleNavigationState>((ref) => BibleNavigationState());

final bibleChaptersProvider =
    FutureProvider.family<List<BibleChapter>, String>((ref, bookId) async {
  final versionId = ref.watch(bibleVersionProvider);
  final repo = ref.watch(bibleRepositoryProvider);
  final result = await repo.getChapters(versionId, bookId);
  return result.fold(
    (l) => throw Exception(l),
    (r) {
      // Filter out 'intro' chapter
      return r.where((c) => c.number != 'intro').toList();
    },
  );
});

final bibleContentProvider = FutureProvider<BibleChapterContent>((ref) async {
  final versionId = ref.watch(bibleVersionProvider);
  final nav = ref.watch(bibleNavigationProvider);
  final repo = ref.watch(bibleRepositoryProvider);
  final result = await repo.getChapterContent(versionId, nav.chapterId);
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

final bibleSearchProvider =
    FutureProvider.family<List<Map<String, String>>, String>(
        (ref, query) async {
  if (query.isEmpty) return [];
  final versionId = ref.watch(bibleVersionProvider);
  final repo = ref.watch(bibleRepositoryProvider);
  final result = await repo.search(versionId, query);
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});
