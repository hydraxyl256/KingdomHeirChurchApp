import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/localization/locale_provider.dart';
import 'package:kingdom_heir/features/sermons/data/repositories/sermons_repository_impl.dart';
import 'package:kingdom_heir/features/sermons/data/services/audio_player_service.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_continue_item.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_series.dart';
import 'package:kingdom_heir/features/sermons/domain/repositories/sermons_repository.dart';

// ─── Repository ─────────────────────────────────────────────────────

final sermonsRepositoryProvider = Provider<SermonsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SermonsRepositoryImpl(ref.watch(supabaseClientProvider), prefs);
});

// ─── Audio player service ───────────────────────────────────────────

/// Singleton [AudioPlayerService] kept alive for the app's lifetime.
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final service = AudioPlayerService(prefs);
  ref.onDispose(service.dispose);
  return service;
});

// ─── Filter model (legacy — kept for backwards compat) ──────────────

class SermonFilter {
  const SermonFilter({
    this.mediaType,
    this.speakerName,
    this.seriesName,
    this.favoritesOnly = false,
    this.downloadsOnly = false,
  });

  final SermonMediaType? mediaType;
  final String? speakerName;
  final String? seriesName;
  final bool favoritesOnly;
  final bool downloadsOnly;

  bool get isActive =>
      mediaType != null ||
      speakerName != null ||
      seriesName != null ||
      favoritesOnly ||
      downloadsOnly;

  static const empty = SermonFilter();
}

// ─── State providers (legacy) ───────────────────────────────────────

final sermonSearchQueryProvider = StateProvider<String>((ref) => '');

final sermonFilterProvider =
    StateProvider<SermonFilter>((ref) => SermonFilter.empty);

// ─── Sermon list provider (legacy AsyncNotifier) ────────────────────

final sermonsListProvider =
    AsyncNotifierProvider<SermonsNotifier, List<Sermon>>(
  SermonsNotifier.new,
);

class SermonsNotifier extends AsyncNotifier<List<Sermon>> {
  @override
  Future<List<Sermon>> build() => _loadSermons();

  Future<List<Sermon>> _loadSermons() async {
    final locale = ref.watch(localeProvider);
    final result = await ref
        .read(sermonsRepositoryProvider)
        .getSermons(languageCode: locale.languageCode);
    return result.fold(
      (l) => throw Exception(l),
      (r) => r,
    );
  }

  Future<void> toggleFavourite(String id) async {
    state = await AsyncValue.guard(() async {
      final current = state.value ?? const <Sermon>[];
      return current.map((s) {
        if (s.id == id) return s.copyWith(isFavorited: !s.isFavorited);
        return s;
      }).toList();
    });
  }

  Future<void> toggleDownload(String id) async {
    state = await AsyncValue.guard(() async {
      final current = state.value ?? const <Sermon>[];
      return current.map((s) {
        if (s.id == id) return s.copyWith(isDownloaded: !s.isDownloaded);
        return s;
      }).toList();
    });
  }
}

// ─── Derived providers (legacy) ─────────────────────────────────────

final activeLiveStreamProvider = Provider<AsyncValue<Sermon?>>((ref) {
  final raw = ref.watch(sermonsListProvider);
  return raw.whenData((sermons) {
    return sermons.where((s) => s.isLive).cast<Sermon?>().firstOrNull;
  });
});

// ─── New providers (Sermon Home bundle) ─────────────────────────────

final featuredSermonProvider = FutureProvider<Sermon?>((ref) async {
  final locale = ref.watch(localeProvider);
  final result = await ref
      .watch(sermonsRepositoryProvider)
      .getSermons(languageCode: locale.languageCode);
  return result.fold((_) => null, (list) {
    for (final s in list) {
      if (s.topics.contains('Grace') || s.viewCount > 10000) {
        return s;
      }
    }
    return list.isEmpty ? null : list.first;
  });
});

final continueWatchingPreviewProvider =
    FutureProvider<List<SermonContinueItem>>((ref) async {
  final result =
      await ref.watch(sermonsRepositoryProvider).getContinueWatching();
  return result.fold((_) => <SermonContinueItem>[], (r) => r.take(6).toList());
});

final latestSermonsProvider = FutureProvider<List<Sermon>>((ref) async {
  final result = await ref.watch(sermonsRepositoryProvider).getRecentlyAdded();
  return result.fold((_) => <Sermon>[], (r) => r);
});

final popularSermonsProvider = FutureProvider<List<Sermon>>((ref) async {
  final result = await ref.watch(sermonsRepositoryProvider).getMostViewed();
  return result.fold((_) => <Sermon>[], (r) => r);
});

final seriesCollectionsProvider =
    FutureProvider<List<SermonSeries>>((ref) async {
  final result = await ref.watch(sermonsRepositoryProvider).getSeries();
  return result.fold((_) => <SermonSeries>[], (r) => r);
});

final recommendedForYouProvider = FutureProvider<List<Sermon>>((ref) async {
  final result = await ref.watch(sermonsRepositoryProvider).getRecommended();
  return result.fold((_) => <Sermon>[], (r) => r);
});

/// Bundle: all sections for the Sermon Home screen. Loading is fan-out
/// rather than sequential so each section can render independently.
final sermonHomeDataProvider = FutureProvider<SermonHomeData>((ref) async {
  final results = await Future.wait<Object?>([
    ref.watch(featuredSermonProvider.future),
    ref.watch(continueWatchingPreviewProvider.future),
    ref.watch(latestSermonsProvider.future),
    ref.watch(popularSermonsProvider.future),
    ref.watch(seriesCollectionsProvider.future),
    ref.watch(recommendedForYouProvider.future),
    Future.value(ref.watch(activeLiveStreamProvider)),
  ]);
  return SermonHomeData(
    featured: results[0] as Sermon?,
    continueWatching: results[1]! as List<SermonContinueItem>,
    latest: results[2]! as List<Sermon>,
    popular: results[3]! as List<Sermon>,
    series: results[4]! as List<SermonSeries>,
    recommended: results[5]! as List<Sermon>,
    liveStream: (results[6]! as AsyncValue<Sermon?>).value,
  );
});

class SermonHomeData {
  const SermonHomeData({
    required this.featured,
    required this.continueWatching,
    required this.latest,
    required this.popular,
    required this.series,
    required this.recommended,
    required this.liveStream,
  });
  final Sermon? featured;
  final List<SermonContinueItem> continueWatching;
  final List<Sermon> latest;
  final List<Sermon> popular;
  final List<SermonSeries> series;
  final List<Sermon> recommended;
  final Sermon? liveStream;
}

// ─── Per-id providers (Details / Series / Audio screens) ────────────

final sermonDetailProvider =
    FutureProvider.family<Sermon?, String>((ref, id) async {
  final result = await ref.watch(sermonsRepositoryProvider).getSermonById(id);
  return result.fold((_) => null, (r) => r);
});

final sermonSeriesListProvider =
    FutureProvider.family<List<SermonSeries>, String>((ref, id) async {
  // id is the series name (encoded into the route). For a real backend
  // we'd look up by id; here we filter by title.
  final result = await ref.watch(sermonsRepositoryProvider).getSeries();
  return result.fold((_) => <SermonSeries>[], (all) {
    return all.where((s) => s.id == id).toList();
  });
});

final sermonSeriesEpisodesProvider =
    FutureProvider.family<List<Sermon>, String>((ref, seriesId) async {
  final result =
      await ref.watch(sermonsRepositoryProvider).getBySeries(seriesId);
  return result.fold((_) => <Sermon>[], (r) => r);
});
