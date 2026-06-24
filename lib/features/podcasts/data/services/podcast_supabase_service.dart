import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/podcasts/domain/entities/podcast_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class PodcastSupabaseService {
  PodcastSupabaseService(this._client);
  final supabase.SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  Future<Either<String, List<PodcastSeries>>> getSeries() async {
    try {
      final data = await _client
          .from('podcast_series')
          .select()
          .eq('status', 'published')
          .order('created_at', ascending: false);
      return right((data as List<dynamic>)
          .map((e) => PodcastSeries.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<PodcastEpisode>>> getEpisodes(
      String seriesId,) async {
    try {
      final data = await _client
          .from('podcast_episodes')
          .select()
          .eq('series_id', seriesId)
          .eq('status', 'published')
          .order('published_at', ascending: false);
      return right((data as List<dynamic>)
          .map((e) => PodcastEpisode.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<PodcastEpisode>>> getAllEpisodes() async {
    try {
      final data = await _client
          .from('podcast_episodes')
          .select()
          .eq('status', 'published')
          .order('published_at', ascending: false);
      return right((data as List<dynamic>)
          .map((e) => PodcastEpisode.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> toggleSubscription(String seriesId) async {
    try {
      final existing = await _client
          .from('podcast_subscriptions')
          .select()
          .eq('user_id', _userId)
          .eq('series_id', seriesId)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from('podcast_subscriptions')
            .delete()
            .eq('id', existing['id'] as String);
      } else {
        await _client.from('podcast_subscriptions').insert({
          'user_id': _userId,
          'series_id': seriesId,
        });
      }
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<PodcastSubscription>>> getSubscriptions() async {
    try {
      final data = await _client
          .from('podcast_subscriptions')
          .select()
          .eq('user_id', _userId);
      return right((data as List<dynamic>)
          .map((e) => PodcastSubscription.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> savePlaybackPosition(
      String episodeId, int positionSeconds,) async {
    try {
      await _client.from('podcast_playback_positions').upsert({
        'user_id': _userId,
        'episode_id': episodeId,
        'position_seconds': positionSeconds,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, PlaybackPosition?>> getPlaybackPosition(
      String episodeId,) async {
    try {
      final data = await _client
          .from('podcast_playback_positions')
          .select()
          .eq('user_id', _userId)
          .eq('episode_id', episodeId)
          .maybeSingle();
      if (data == null) return right(null);
      return right(PlaybackPosition.fromJson(data));
    } catch (e) {
      return left(e.toString());
    }
  }
}
