import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kingdom_heir/features/podcasts/domain/entities/podcast_models.dart';

class AudioPlayerService {
  AudioPlayerService() {
    _init();
  }

  final AudioPlayer player = AudioPlayer();
  PodcastEpisode? _currentEpisode;

  PodcastEpisode? get currentEpisode => _currentEpisode;

  void _init() {
    // Optionally setup listeners for player state here.
  }

  Future<void> loadEpisode(PodcastEpisode episode, PodcastSeries series) async {
    _currentEpisode = episode;
    final audioSource = AudioSource.uri(
      Uri.parse(episode.audioUrl),
      tag: MediaItem(
        id: episode.id,
        album: series.title,
        title: episode.title,
        artist: series.author,
        artUri: series.thumbnailUrl != null
            ? Uri.parse(series.thumbnailUrl!)
            : null,
      ),
    );
    await player.setAudioSource(audioSource);
  }

  Future<void> play() => player.play();
  Future<void> pause() => player.pause();
  Future<void> stop() => player.stop();
  Future<void> seek(Duration position) => player.seek(position);

  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;

  Future<void> dispose() async {
    await player.dispose();
  }
}
