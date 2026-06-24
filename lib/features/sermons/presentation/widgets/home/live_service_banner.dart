// Kingdom Heir — Live Service Banner (Sermon Home)
//
// Gold banner with pulsing red dot — rendered above the Continue
// Watching row when an active live stream is available.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/live_pulse_dot.dart';

class LiveServiceBanner extends StatelessWidget {
  const LiveServiceBanner({
    required this.sermon,
    required this.onWatch,
    super.key,
  });

  final Sermon sermon;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onWatch,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              gradient: const LinearGradient(
                colors: [AppColors.goldDark, AppColors.gold],
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const LivePulseDot(size: 12),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LIVE NOW',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sermon.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Watch the service',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.ink.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.play_circle_filled_rounded,
                  color: AppColors.ink,
                  size: 36,
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1, end: 0),
    );
  }
}
