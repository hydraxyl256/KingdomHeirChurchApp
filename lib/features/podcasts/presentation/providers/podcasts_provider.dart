import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/features/podcasts/data/repositories/podcast_repository.dart';
import 'package:kingdom_heir/features/podcasts/data/services/audio_player_service.dart';
import 'package:kingdom_heir/features/podcasts/data/services/podcast_local_cache.dart';
import 'package:kingdom_heir/features/podcasts/data/services/podcast_supabase_service.dart';
import 'package:kingdom_heir/features/podcasts/domain/entities/podcast_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Services & Repositories
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  return PodcastRepositoryImpl(
    supabaseService: PodcastSupabaseService(Supabase.instance.client),
    localCache: PodcastLocalCache(ref.watch(sharedPreferencesProvider)),
  );
});

// Data Providers
final podcastSeriesProvider = FutureProvider<List<PodcastSeries>>((ref) async {
  final repo = ref.watch(podcastRepositoryProvider);
  final result = await repo.getSeries();
  return result.fold((l) => throw Exception(l), (r) => r);
});

final allEpisodesProvider = FutureProvider<List<PodcastEpisode>>((ref) async {
  final repo = ref.watch(podcastRepositoryProvider);
  final result = await repo.getAllEpisodes();
  return result.fold((l) => throw Exception(l), (r) => r);
});

// Player State
final currentEpisodeProvider = StateProvider<PodcastEpisode?>((ref) => null);
final currentSeriesProvider = StateProvider<PodcastSeries?>((ref) => null);

// Position Syncing Logic
final positionStreamProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerServiceProvider).player.positionStream;
});
