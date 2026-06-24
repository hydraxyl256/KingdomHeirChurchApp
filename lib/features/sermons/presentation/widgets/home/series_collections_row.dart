// Kingdom Heir — Series Collections Row (Sermon Home)
//
// Horizontal rail of large series cover cards. Each card has a gradient
// cover, series title, pastor, episode count chip, and the user's
// progress in the series.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_series.dart';

class SeriesCollectionsRow extends StatelessWidget {
  const SeriesCollectionsRow({
    required this.series,
    super.key,
  });

  final List<SermonSeries> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: _Header(
            title: 'Series collections',
            subtitle: 'Multi-message teaching arcs',
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: series.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) => _SeriesCard(series: series[i])
                .animate(delay: Duration(milliseconds: 60 * i))
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, end: 0),
          ),
        ),
      ],
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.series});
  final SermonSeries series;

  @override
  Widget build(BuildContext context) {
    const width = 260.0;
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              context.push('/home/sermons/${series.id}/series/${series.id}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              gradient: LinearGradient(
                colors: series.coverGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warmWhite.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '${series.episodeCount} eps',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.warmWhite,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        series.scriptureAnchor,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.warmWhite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      series.pastorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.warmWhite.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (series.episodeCount > 0) ...[
                      const SizedBox(height: AppSpacing.xs),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: series.progress),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          backgroundColor:
                              AppColors.warmWhite.withValues(alpha: 0.2),
                          color: AppColors.gold,
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
