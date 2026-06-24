// Kingdom Heir — Global Sermon Mini Player
//
// Persistent bar rendered above the bottom nav for every shell route.
// Wired to the singleton [AudioPlayerService] so play/pause + the
// progress bar reflect the live audio session. Tap → SermonAudioPlayerScreen,
// X → stop + clear state.
//
// The legacy `currentPlayingSermonProvider` / `isSermonPlayingProvider`
// are kept as derived providers (read from the audio service) so any
// other widget that watches them still resolves.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/data/services/audio_player_service.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

/// Derived provider — legacy alias. Mirrors the audio service's
/// `currentSermon` so any external watcher stays in sync.
final currentPlayingSermonProvider = Provider<Sermon?>((ref) {
  return ref.watch(audioPlayerServiceProvider).currentSermon.value;
});

/// Derived provider — legacy alias. Mirrors the audio service's
/// play/pause state.
final isSermonPlayingProvider = Provider<bool>((ref) {
  return ref.watch(audioPlayerServiceProvider).player.playing;
});

class GlobalSermonMiniPlayer extends ConsumerWidget {
  const GlobalSermonMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(audioPlayerServiceProvider);
    final sermon = service.currentSermon.value;
    if (sermon == null) return const SizedBox.shrink();

    return _MiniPlayerBody(
      service: service,
      sermon: sermon,
      onOpen: () => context.push('${RouteNames.sermons}/${sermon.id}/audio'),
      onClose: service.stop,
    );
  }
}

class _MiniPlayerBody extends StatelessWidget {
  const _MiniPlayerBody({
    required this.service,
    required this.sermon,
    required this.onOpen,
    required this.onClose,
  });

  final AudioPlayerService service;
  final Sermon sermon;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.navyAccent,
            border: Border(
              top: BorderSide(color: AppColors.dividerDark),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Stack(
            children: [
              Row(
                children: [
                  _Thumbnail(sermon: sermon),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sermon.title,
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          sermon.speakerName,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _PlayPauseButton(service: service),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: onClose,
                  ),
                ],
              ),
              // Bottom progress bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ProgressBar(service: service),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.sermon});
  final Sermon sermon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.navyMid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        image: sermon.thumbnailUrl != null
            ? DecorationImage(
                image: NetworkImage(sermon.thumbnailUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: sermon.thumbnailUrl == null
          ? const Icon(Icons.music_note_rounded, color: AppColors.gold)
          : null,
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.service});
  final AudioPlayerService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: service.stateStream,
      builder: (context, snap) {
        final isPlaying = snap.data?.playing ?? false;
        return IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.gold,
            size: 28,
          ),
          onPressed: () async {
            if (isPlaying) {
              await service.pause();
            } else {
              await service.resume();
            }
          },
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.service});
  final AudioPlayerService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: service.positionStream,
      builder: (context, positionSnap) {
        return StreamBuilder<Duration?>(
          stream: service.durationStream,
          builder: (context, durationSnap) {
            final pos = positionSnap.data?.inMilliseconds.toDouble() ?? 0;
            final dur = durationSnap.data?.inMilliseconds.toDouble() ?? 0;
            final progress = dur == 0 ? 0.0 : (pos / dur).clamp(0.0, 1.0);
            return Container(
              height: 2,
              color: AppColors.dividerDark,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: MediaQuery.of(context).size.width * progress,
                  color: AppColors.gold,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
