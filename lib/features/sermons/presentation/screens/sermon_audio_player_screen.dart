// Kingdom Heir — Sermon Audio Player Screen
//
// Spotify-style full-screen audio player. Auto-plays the sermon via the
// AudioPlayerService. Records progress on dispose.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_continue_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/audio/full_audio_player.dart';

class SermonAudioPlayerScreen extends ConsumerStatefulWidget {
  const SermonAudioPlayerScreen({required this.sermonId, super.key});
  final String sermonId;

  @override
  ConsumerState<SermonAudioPlayerScreen> createState() =>
      _SermonAudioPlayerScreenState();
}

class _SermonAudioPlayerScreenState
    extends ConsumerState<SermonAudioPlayerScreen> {
  final int _lastPosition = 0;
  bool _started = false;

  @override
  void dispose() {
    if (_started && _lastPosition > 0) {
      ref.read(continueWatchingListProvider.notifier).recordProgress(
            sermonId: widget.sermonId,
            positionSeconds: _lastPosition,
            isCompleted: false,
          );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sermonAsync = ref.watch(sermonDetailProvider(widget.sermonId));
    return Scaffold(
      backgroundColor: const Color(0xFF0B1530),
      body: sermonAsync.when(
        data: (sermon) {
          if (sermon == null) {
            return AppErrorWidget(
              message: 'Sermon not found',
              onRetry: () =>
                  ref.invalidate(sermonDetailProvider(widget.sermonId)),
            );
          }
          if (!_started && sermon.hasAudio) {
            _started = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(audioPlayerServiceProvider).playSermon(sermon);
            });
          }
          return FullAudioPlayer(sermon: sermon);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
