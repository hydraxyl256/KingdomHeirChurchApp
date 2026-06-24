// Kingdom Heir — More (Kingdom Center) Providers
//
// Each section of the More screen has its own FutureProvider so they
// load in parallel and a slow/failing section does not block the rest.
// Favorites are a stateful NotifierProvider backed by SharedPreferences
// so user-pinned features persist across launches.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart'
    show currentUserProvider;
import 'package:kingdom_heir/features/more/data/more_repository.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

final moreRepositoryProvider =
    Provider<MoreRepository>((ref) => MoreRepository());

// ─────────────────────────────────────────────────────────────────────────────
// Per-section FutureProviders
// ─────────────────────────────────────────────────────────────────────────────

final moreProfileProvider = FutureProvider<MoreProfileHero>((ref) async {
  // The profile hero is composed from auth-derived fields plus the
  // repository's "member since" computation. We pull currentUserProvider
  // here so this section re-renders when auth changes.
  final user = ref.watch(currentUserProvider);
  return ref.read(moreRepositoryProvider).fetchProfile(
        displayName: user?.displayName ?? 'Kingdom Member',
        email: user?.email ?? '',
        roleLabel: user?.role?.displayName ?? 'Member',
        streakDays: 17,
        avatarUrl: user?.avatarUrl,
        memberSince: user?.createdAt,
      );
});

final moreFavoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, FavoriteFeatures>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<FavoriteFeatures> {
  static const _prefsKey = 'more_favorites_v1';

  @override
  Future<FavoriteFeatures> build() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getStringList(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return ref.read(moreRepositoryProvider).fetchFavorites();
    }
    final parsed = <MoreFeature>[];
    for (final s in raw) {
      for (final f in MoreFeature.values) {
        if (f.name == s) {
          parsed.add(f);
          break;
        }
      }
    }
    return FavoriteFeatures(parsed.isEmpty ? const [] : parsed);
  }

  Future<void> toggle(MoreFeature f) async {
    final current = state.value ?? const FavoriteFeatures([]);
    final next = current.ids.contains(f)
        ? current.ids.where((e) => e != f).toList()
        : <MoreFeature>[f, ...current.ids];
    state = AsyncData(FavoriteFeatures(next));
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(
      _prefsKey,
      next.map((e) => e.name).toList(),
    );
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null) return;
    final list = [...current.ids];
    if (oldIndex < 0 || oldIndex >= list.length) return;
    final item = list.removeAt(oldIndex);
    final idx = newIndex > oldIndex ? newIndex - 1 : newIndex;
    list.insert(idx.clamp(0, list.length), item);
    state = AsyncData(FavoriteFeatures(list));
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(
      _prefsKey,
      list.map((e) => e.name).toList(),
    );
  }
}

final moreRecentsProvider = FutureProvider<List<RecentItem>>((ref) {
  return ref.read(moreRepositoryProvider).fetchRecents();
});

final moreGivingProvider = FutureProvider<MoreGivingSummary>((ref) {
  return ref.read(moreRepositoryProvider).fetchGiving();
});

final moreFamilyEventsProvider = FutureProvider<FamilyEvents>((ref) {
  return ref.read(moreRepositoryProvider).fetchFamilyEvents();
});

// ─────────────────────────────────────────────────────────────────────────────
// Aggregate provider — coordinates initial load / error.
// ─────────────────────────────────────────────────────────────────────────────

final moreDataProvider = FutureProvider<MoreData>((ref) async {
  final profile = await ref.watch(moreProfileProvider.future);
  final favs = await ref.watch(moreFavoritesProvider.future);
  final recents = await ref.watch(moreRecentsProvider.future);
  final giving = await ref.watch(moreGivingProvider.future);
  final family = await ref.watch(moreFamilyEventsProvider.future);
  return MoreData(
    profile: profile,
    favorites: favs,
    recents: recents,
    giving: giving,
    familyEvents: family,
  );
});
