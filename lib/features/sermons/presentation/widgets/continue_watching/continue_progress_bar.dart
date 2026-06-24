// Kingdom Heir — Continue Progress Bar
//
// Standalone animated gold progress bar. Reused on the Continue Watching
// screen and inside ContinueCard.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';

class ContinueProgressBar extends StatelessWidget {
  const ContinueProgressBar({
    required this.progress,
    super.key,
    this.height = 4,
  });

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Container(
        height: height,
        color: AppColors.warmWhite.withValues(alpha: 0.3),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value,
            child: Container(color: AppColors.gold),
          ),
        ),
      ),
    );
  }
}
