// Kingdom Heir — Audio Visualizer
//
// 5-bar custom painter driven by the player's position stream. Each bar's
// height is a deterministic function of position + bar index so the
// visualizer "breathes" without depending on a real audio analyser.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

class AudioVisualizer extends ConsumerStatefulWidget {
  const AudioVisualizer({super.key, this.height = 56});
  final double height;

  @override
  ConsumerState<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends ConsumerState<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(audioPlayerServiceProvider);
    return StreamBuilder<Duration>(
      stream: service.positionStream,
      builder: (context, snap) {
        _position = snap.data ?? _position;
        return StreamBuilder<PlayerState>(
          stream: service.stateStream,
          builder: (context, stateSnap) {
            final playing = stateSnap.data?.playing ?? false;
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                size: Size.fromHeight(widget.height),
                painter: _VisualizerPainter(
                  seed: _position.inMilliseconds,
                  animation: _controller.value,
                  active: playing,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  _VisualizerPainter({
    required this.seed,
    required this.animation,
    required this.active,
  });

  final int seed;
  final double animation;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 5;
    final barWidth = size.width / (barCount * 2);
    final gap = (size.width - barWidth * barCount) / (barCount + 1);
    final paint = Paint()
      ..color = active ? AppColors.gold : AppColors.gold.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < barCount; i++) {
      final phase = (animation * 2 * math.pi) + (i * 0.7);
      final amp = active ? (0.4 + 0.6 * ((math.sin(phase) + 1) / 2)) : 0.2;
      final h = size.height * amp;
      final x = gap + i * (barWidth + gap);
      final y = (size.height - h) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, h),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter old) =>
      old.seed != seed || old.animation != animation || old.active != active;
}
