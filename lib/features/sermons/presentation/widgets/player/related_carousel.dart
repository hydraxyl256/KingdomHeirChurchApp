// Kingdom Heir — Related Carousel (Player)
//
// Horizontal rail of related sermons shown below the video player. Tap
// → swap the player's source to that sermon. Reuses the same card shape
// as the home recommendations rail.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';

class RelatedCarousel extends StatelessWidget {
  const RelatedCarousel({required this.sermons, super.key});
  final List<Sermon> sermons;

  @override
  Widget build(BuildContext context) {
    if (sermons.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Text(
            'You might also like',
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
            itemCount: sermons.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) => _RelatedCard(sermon: sermons[i])
                .animate(delay: Duration(milliseconds: 60 * i))
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.08, end: 0),
          ),
        ),
      ],
    );
  }
}

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.sermon});
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
