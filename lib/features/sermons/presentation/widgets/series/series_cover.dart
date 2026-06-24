// Kingdom Heir — Series Cover (Sermon Series)
//
// Tall hero with the series gradient, title, pastor name, episode count,
// and the anchor scripture. Anchors the top of the Series screen.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_series.dart';

class SeriesCover extends StatelessWidget {
  const SeriesCover({required this.series, super.key});
  final SermonSeries series;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: series.coverGradient.first,
      iconTheme: const IconThemeData(color: AppColors.warmWhite),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: series.coverGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                72,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warmWhite.withValues(alpha: 0.25),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      'SERIES',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.warmWhite,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    series.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: AppColors.warmWhite,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    series.pastorName,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.warmWhite.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _Badge(
                        icon: Icons.menu_book_rounded,
                        label: series.scriptureAnchor,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _Badge(
                        icon: Icons.playlist_play_rounded,
                        label: '${series.episodeCount} messages',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warmWhite.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.warmWhite),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
