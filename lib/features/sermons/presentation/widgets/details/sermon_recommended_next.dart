// Kingdom Heir — Sermon Recommended Next (Details)
//
// "Up next in [series]" or "Because you watched this" — a horizontal
// rail of related sermons. Falls back to trending when no series match.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';

class SermonRecommendedNext extends StatelessWidget {
  const SermonRecommendedNext({
    required this.recommendations,
    super.key,
    this.seriesName,
  });

  final List<Sermon> recommendations;
  final String? seriesName;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final title =
        seriesName == null ? 'You might also like' : 'Up next in $seriesName';
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Text(
              title,
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) =>
                  _RecommendationCard(sermon: recommendations[i])
                      .animate(delay: Duration(milliseconds: 60 * i))
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.08, end: 0),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.sermon});
  final Sermon sermon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/home/sermons/${sermon.id}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: SermonThumbnail(
                    thumbnailUrl: sermon.thumbnailUrl,
                    title: sermon.title,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                sermon.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sermon.speakerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
