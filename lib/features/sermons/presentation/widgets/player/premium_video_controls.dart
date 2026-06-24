// Kingdom Heir — Premium Video Controls
//
// Wraps a Chewie / YouTube player with custom overlay controls:
// fade-in 250 ms on tap, double-tap left/right to skip 10 s, gold
// scrubber, top-right control row (PiP / Captions / Speed / Cast / More).
//
// The video surface itself is rendered by the screen — this widget is
// the control overlay. The screen passes the surface via [child].

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/data/services/audio_player_service.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/player/playback_speed_picker.dart';

class PremiumVideoControls extends ConsumerStatefulWidget {
  const PremiumVideoControls({
    required this.child,
    required this.title,
    super.key,
    this.onBack,
  });

  final Widget child;
  final String title;
  final VoidCallback? onBack;

  @override
  ConsumerState<PremiumVideoControls> createState() =>
      _PremiumVideoControlsState();
}

class _PremiumVideoControlsState extends ConsumerState<PremiumVideoControls> {
  bool _showControls = true;

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(audioPlayerServiceProvider);
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      onDoubleTapDown: (details) {
        final width = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < width / 2) {
          service.skipBackward();
          HapticFeedback.selectionClick();
        } else {
          service.skipForward();
          HapticFeedback.selectionClick();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          if (_showControls)
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(
                    title: widget.title,
                    onBack: widget.onBack,
                  ),
                  const Spacer(),
                  _CenterPlayPause(service: service),
                  const SizedBox(height: AppSpacing.lg),
                  _BottomScrubber(
                    service: service,
                    format: _format,
                    onSpeedTap: () => showPlaybackSpeedPicker(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.warmWhite,
            ),
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.warmWhite,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Picture-in-picture',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Picture-in-picture — coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.picture_in_picture_alt_rounded,
              color: AppColors.warmWhite,
            ),
          ),
          IconButton(
            tooltip: 'Captions',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Captions — coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.closed_caption_rounded,
              color: AppColors.warmWhite,
            ),
          ),
          IconButton(
            tooltip: 'Speed',
            onPressed: () => showPlaybackSpeedPicker(context),
            icon: const Icon(
              Icons.speed_rounded,
              color: AppColors.warmWhite,
            ),
          ),
          IconButton(
            tooltip: 'Cast',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cast — coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.cast_rounded,
              color: AppColors.warmWhite,
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.surfaceContainerLight,
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.warmWhite,
            ),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$value — coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Quality', child: Text('Quality')),
              PopupMenuItem(
                value: 'Sleep timer',
                child: Text('Sleep timer'),
              ),
              PopupMenuItem(
                value: 'Report a problem',
                child: Text('Report a problem'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CenterPlayPause extends StatelessWidget {
  const _CenterPlayPause({required this.service});
  final AudioPlayerService service;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<PlayerState>(
        stream: service.stateStream,
        builder: (context, snap) {
          final playing = snap.data?.playing ?? false;
          return Material(
            color: AppColors.gold,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => playing ? service.pause() : service.resume(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(playing),
                    color: AppColors.ink,
                    size: 48,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomScrubber extends StatelessWidget {
  const _BottomScrubber({
    required this.service,
    required this.format,
    required this.onSpeedTap,
  });
  final AudioPlayerService service;
  final String Function(Duration) format;
  final VoidCallback onSpeedTap;

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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: AppColors.gold,
                      inactiveTrackColor:
                          AppColors.warmWhite.withValues(alpha: 0.3),
                      thumbColor: AppColors.gold,
                      overlayColor: AppColors.gold.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: pos.inMilliseconds
                          .clamp(0, dur.inMilliseconds.clamp(0, 1 << 31))
                          .toDouble(),
                      max: dur.inMilliseconds
                          .toDouble()
                          .clamp(0, double.infinity),
                      onChanged: (v) =>
                          service.seek(Duration(milliseconds: v.toInt())),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
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
              ),
            );
          },
        );
      },
    );
  }
}
