// Kingdom Heir — Activity Dot
//
// Small pulsing dot to indicate "this group has activity in the last
// 24h". Used inline on My Groups cards and group rows.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';

class ActivityDot extends StatefulWidget {
  const ActivityDot({
    super.key,
    this.color = AppColors.gold,
    this.size = 8,
    this.pulse = true,
  });

  final Color color;
  final double size;
  final bool pulse;

  @override
  State<ActivityDot> createState() => _ActivityDotState();
}

class _ActivityDotState extends State<ActivityDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return _Dot(color: widget.color, size: widget.size, opacity: 1);
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => _Dot(
        color: widget.color,
        size: widget.size,
        opacity: 0.5 + 0.5 * _ctrl.value,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size, required this.opacity});
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity * 0.4),
            blurRadius: size * 0.8,
            spreadRadius: size * 0.3,
          ),
        ],
      ),
    );
  }
}
