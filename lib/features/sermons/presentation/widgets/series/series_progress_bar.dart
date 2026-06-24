// Kingdom Heir — Series Progress Bar
//
// Animated progress indicator showing the user's completion ratio for
// the series. Includes the "X of Y messages watched" label.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_series.dart';

class SeriesProgressBar extends StatelessWidget {
  const SeriesProgressBar({required this.series, super.key});
  final SermonSeries series;

  @override
  Widget build(BuildContext context) {
    final pct = (series.progress * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md,),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your progress',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '$pct%',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${series.completedCount} of ${series.episodeCount} messages watched',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: series.progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.dividerLight,
                color: AppColors.gold,
                minHeight: 8,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
