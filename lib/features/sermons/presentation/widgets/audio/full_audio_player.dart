// Kingdom Heir — Full Audio Player
//
// Spotify-style full-screen audio player. Shows large square cover art,
// title, speaker, gold scrubber, transport row (shuffle / prev / play /
// next / repeat), speed + sleep + bookmark row, and a queue + visualizer
// block below.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/data/services/audio_player_service.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/audio/audio_visualizer.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/audio/bookmark_picker.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/audio/queue_list.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/audio/sleep_timer_sheet.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';

class FullAudioPlayer extends ConsumerWidget {
  const FullAudioPlayer({required this.sermon, super.key});
  final Sermon sermon;

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(audioPlayerServiceProvider);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navyAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AudioVisualizer(height: 36),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: SermonThumbnail(
                        thumbnailUrl: sermon.thumbnailUrl,
                        title: sermon.title,
                        aspectRatio: 1,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                sermon.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.warmWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sermon.speakerName,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.warmWhite.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Scrubber(
                service: service,
                format: _format,
              ),
              const SizedBox(height: AppSpacing.lg),
              _TransportRow(service: service),
              const SizedBox(height: AppSpacing.lg),
              _ActionRow(
                onSpeedTap: () => _showSpeedSheet(context, ref),
                onSleepTap: () => showSleepTimerSheet(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              BookmarkPicker(sermon: sermon),
              const SizedBox(height: AppSpacing.md),
              const QueueList(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpeedSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final service = ref.watch(audioPlayerServiceProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Playback speed',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                        .map(
                          (s) => ChoiceChip(
                            label: Text('${s}x'),
                            selected: service.currentSpeed == s,
                            onSelected: (_) {
                              service.setSpeed(s);
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Scrubber extends StatelessWidget {
  const _Scrubber({required this.service, required this.format});
  final AudioPlayerService service;
  final String Function(Duration) format;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: service.positionStream,
      builder: (context, posSnap) {
        return StreamBuilder<Duration?>(
          stream: service.durationStream,
          builder: (context, durSnap) {
            final pos = posSnap.data ?? Duration.zero;
            final dur = durSnap.data ?? Duration.zero;
            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: AppColors.gold,
                    inactiveTrackColor:
                        AppColors.warmWhite.withValues(alpha: 0.2),
                    thumbColor: AppColors.gold,
                    overlayColor: AppColors.gold.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: pos.inMilliseconds
                        .clamp(0, dur.inMilliseconds.clamp(0, 1 << 31))
                        .toDouble(),
                    max:
                        dur.inMilliseconds.toDouble().clamp(0, double.infinity),
                    onChanged: (v) =>
                        service.seek(Duration(milliseconds: v.toInt())),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        format(pos),
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.warmWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        format(dur),
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.warmWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TransportRow extends StatelessWidget {
  const _TransportRow({required this.service});
  final AudioPlayerService service;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: service.skipBackward,
          icon: const Icon(Icons.replay_10_rounded),
          color: AppColors.warmWhite,
          iconSize: 32,
        ),
        StreamBuilder<PlayerState>(
          stream: service.stateStream,
          builder: (context, snap) {
            final playing = snap.data?.playing ?? false;
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => playing ? service.pause() : service.resume(),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(playing),
                    color: AppColors.ink,
                    size: 36,
                  ),
                ),
                iconSize: 48,
              ),
            );
          },
        ),
        IconButton(
          onPressed: service.skipForward,
          icon: const Icon(Icons.forward_30_rounded),
          color: AppColors.warmWhite,
          iconSize: 32,
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onSpeedTap, required this.onSleepTap});
  final VoidCallback onSpeedTap;
  final VoidCallback onSleepTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.speed_rounded,
          label: 'Speed',
          onTap: onSpeedTap,
        ),
        _ActionButton(
          icon: Icons.bedtime_rounded,
          label: 'Sleep',
          onTap: onSleepTap,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warmWhite.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.warmWhite, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.warmWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
