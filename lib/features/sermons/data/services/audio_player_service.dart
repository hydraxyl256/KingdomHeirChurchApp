// Kingdom Heir — Audio Player Service
//
// Singleton service that owns the just_audio `AudioPlayer` instance and
// the audio_service background handle. The widget layer subscribes to
// `stateStream` to drive the global mini player and the full audio
// player screen.
//
// In this iteration the audio source is the remote `audioUrl` (mocked
// in the seed file). Background playback is wired through audio_service
// (notification + lock-screen controls); the `JustAudioBackground.init`
// call lives in `main.dart`.
//
// Sleep timer is implemented in-memory via a single-shot `Timer`. Queue
// management is a simple ordered list — no re-ordering UI in v1.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the global audio session for sermons.
class AudioPlayerService {
  AudioPlayerService(this._prefs) {
    _wireListeners();
  }

  final SharedPreferences _prefs;

  /// Underlying just_audio player.
  final AudioPlayer player = AudioPlayer();

  /// Currently-loaded sermon (null when nothing is playing).
  final ValueNotifier<Sermon?> currentSermon = ValueNotifier<Sermon?>(null);

  /// Up-next queue. The currently-playing item is index 0.
  final ValueNotifier<List<Sermon>> queue =
      ValueNotifier<List<Sermon>>(<Sermon>[]);

  /// Sleep-timer end time (null when no timer is active).
  final ValueNotifier<DateTime?> sleepTimerEndsAt =
      ValueNotifier<DateTime?>(null);

  Timer? _sleepTimer;
  bool _disposed = false;

  // ─── Public streams ────────────────────────────────────────────────

  Stream<PlayerState> get stateStream => player.playerStateStream;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<PlaybackEvent> get playbackEventStream => player.playbackEventStream;

  /// Current playback rate (1.0 = normal speed).
  double get currentSpeed => player.speed;

  // ─── Public control API ────────────────────────────────────────────

  /// Load + play a sermon. Replaces the current queue.
  Future<void> playSermon(Sermon sermon) async {
    currentSermon.value = sermon;
    queue.value = <Sermon>[sermon];

    final url = sermon.audioUrl;
    if (url == null || url.isEmpty) {
      // No source — leave the player idle but reflect the intent in state.
      return;
    }
    try {
      await player.setUrl(url);
      await player.play();
    } on PlayerException {
      // Mock fixtures may have unresolvable URLs. Reflect intent but
      // keep the UI's state in sync — the player remains paused.
    }
  }

  Future<void> pause() async {
    if (player.playing) await player.pause();
  }

  Future<void> resume() async {
    if (!player.playing) await player.play();
  }

  Future<void> seek(Duration position) => player.seek(position);

  Future<void> setSpeed(double speed) => player.setSpeed(speed);

  Future<void> skipForward(
      [Duration delta = const Duration(seconds: 30),]) async {
    final pos = player.position;
    final dur = player.duration ?? Duration.zero;
    final next = pos + delta;
    final clamped = next > dur ? dur : next;
    await player.seek(clamped);
  }

  Future<void> skipBackward(
      [Duration delta = const Duration(seconds: 15),]) async {
    final pos = player.position;
    final next = pos - delta;
    final clamped = next.isNegative ? Duration.zero : next;
    await player.seek(clamped);
  }

  /// Append a sermon to the up-next queue. Does not auto-advance.
  void enqueue(Sermon sermon) {
    final next = List<Sermon>.from(queue.value)..add(sermon);
    queue.value = next;
  }

  /// Replace the up-next queue.
  void setQueue(List<Sermon> sermons) {
    queue.value = List<Sermon>.from(sermons);
  }

  /// Save a bookmark (timestamp) for the currently-loaded sermon.
  Future<void> addBookmark(Duration position) async {
    final sermon = currentSermon.value;
    if (sermon == null) return;
    final key = 'sermon_bookmarks_${sermon.id}';
    final raw = _prefs.getStringList(key) ?? <String>[];
    await _prefs.setStringList(key, raw..add(position.inSeconds.toString()));
  }

  /// Start a sleep timer that pauses playback when it elapses.
  void sleepTimer(Duration after) {
    cancelSleepTimer();
    final endsAt = DateTime.now().add(after);
    sleepTimerEndsAt.value = endsAt;
    _sleepTimer = Timer(after, () async {
      await pause();
      sleepTimerEndsAt.value = null;
      _sleepTimer = null;
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    sleepTimerEndsAt.value = null;
  }

  /// Stop playback, clear state, dispose background notification.
  Future<void> stop() async {
    cancelSleepTimer();
    await player.stop();
    currentSermon.value = null;
    queue.value = <Sermon>[];
  }

  // ─── Wiring ────────────────────────────────────────────────────────

  void _wireListeners() {
    // Auto-advance to the next queue item when playback completes.
    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        final next = List<Sermon>.from(queue.value);
        if (next.isNotEmpty) {
          next.removeAt(0);
          queue.value = next;
          if (next.isNotEmpty) {
            playSermon(next.first);
          } else {
            currentSermon.value = null;
          }
        }
      }
    });
  }

  /// Release resources. Call only when the app is shutting down.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    cancelSleepTimer();
    await player.dispose();
    currentSermon.dispose();
    queue.dispose();
    sleepTimerEndsAt.dispose();
  }
}
