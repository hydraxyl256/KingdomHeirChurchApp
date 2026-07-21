import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/podcasts/data/services/podcast_local_cache.dart';
import 'package:kingdom_heir/features/podcasts/data/services/podcast_supabase_service.dart';
import 'package:kingdom_heir/features/podcasts/domain/entities/podcast_models.dart';

abstract class PodcastRepository {
  Future<Either<String, List<PodcastSeries>>> getSeries();
  Future<Either<String, List<PodcastEpisode>>> getEpisodes(String seriesId);
  Future<Either<String, List<PodcastEpisode>>> getAllEpisodes();
  Future<Either<String, void>> toggleSubscription(String seriesId);
  Future<Either<String, List<PodcastSubscription>>> getSubscriptions();
  Future<Either<String, void>> savePlaybackPosition(
    String episodeId,
    int positionSeconds,
  );
  Future<Either<String, PlaybackPosition?>> getPlaybackPosition(
    String episodeId,
  );
}

class PodcastRepositoryImpl implements PodcastRepository {
  PodcastRepositoryImpl({
    required this.supabaseService,
    required this.localCache,
  });

  final PodcastSupabaseService supabaseService;
  final PodcastLocalCache localCache;

  @override
  Future<Either<String, List<PodcastSeries>>> getSeries() async {
    try {
      final cached = localCache.getCachedSeries();
      if (cached != null && cached.isNotEmpty) {
        unawaited(
          supabaseService.getSeries().then(
                (res) => res.fold(
                  (l) => null,
                  localCache.cacheSeries,
                ),
              ),
        );
        return right(cached);
      }

      final result = await supabaseService.getSeries();
      return result.fold(
        left,
        (list) {
          localCache.cacheSeries(list);
          return right(list);
        },
      );
    } catch (e) {
      return left('Failed to get podcast series: $e');
    }
  }

  @override
  Future<Either<String, List<PodcastEpisode>>> getEpisodes(
    String seriesId,
  ) async {
    try {
      final cached = localCache.getCachedEpisodes(seriesId);
      if (cached != null && cached.isNotEmpty) {
        unawaited(
          supabaseService.getEpisodes(seriesId).then(
                (res) => res.fold(
                  (l) => null,
                  (list) => localCache.cacheEpisodes(seriesId, list),
                ),
              ),
        );
        return right(cached);
      }

      final result = await supabaseService.getEpisodes(seriesId);
      return result.fold(
        left,
        (list) {
          localCache.cacheEpisodes(seriesId, list);
          return right(list);
        },
      );
    } catch (e) {
      return left('Failed to get podcast episodes: $e');
    }
  }

  @override
  Future<Either<String, List<PodcastEpisode>>> getAllEpisodes() async {
    try {
      final result = await supabaseService.getAllEpisodes();
      return result;
    } catch (e) {
      return left('Failed to get all episodes: $e');
    }
  }

  @override
  Future<Either<String, void>> toggleSubscription(String seriesId) =>
      supabaseService.toggleSubscription(seriesId);

  @override
  Future<Either<String, List<PodcastSubscription>>> getSubscriptions() =>
      supabaseService.getSubscriptions();

  @override
  Future<Either<String, void>> savePlaybackPosition(
    String episodeId,
    int positionSeconds,
  ) =>
      supabaseService.savePlaybackPosition(episodeId, positionSeconds);

  @override
  Future<Either<String, PlaybackPosition?>> getPlaybackPosition(
    String episodeId,
  ) =>
      supabaseService.getPlaybackPosition(episodeId);
}
