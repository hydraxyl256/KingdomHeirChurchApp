import 'dart:convert';
import 'package:kingdom_heir/features/podcasts/domain/entities/podcast_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PodcastLocalCache {
  PodcastLocalCache(this._prefs);
  final SharedPreferences _prefs;

  static const _seriesKey = 'podcast_series';
  static const _episodesKeyPrefix = 'podcast_episodes_';

  Future<void> cacheSeries(List<PodcastSeries> series) async {
    final list = series.map((s) => s.toJson()).toList();
    await _prefs.setString(_seriesKey, jsonEncode(list));
  }

  List<PodcastSeries>? getCachedSeries() {
    final str = _prefs.getString(_seriesKey);
    if (str == null) return null;
    final list = jsonDecode(str) as List<dynamic>;
    return list
        .map((e) => PodcastSeries.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cacheEpisodes(
    String seriesId,
    List<PodcastEpisode> episodes,
  ) async {
    final list = episodes.map((e) => e.toJson()).toList();
    await _prefs.setString('$_episodesKeyPrefix$seriesId', jsonEncode(list));
  }

  List<PodcastEpisode>? getCachedEpisodes(String seriesId) {
    final str = _prefs.getString('$_episodesKeyPrefix$seriesId');
    if (str == null) return null;
    final list = jsonDecode(str) as List<dynamic>;
    return list
        .map((e) => PodcastEpisode.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
