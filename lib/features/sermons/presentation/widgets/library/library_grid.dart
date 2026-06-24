// Kingdom Heir — Library Grid
//
// Responsive SliverGrid of sermon cards. Columns are band-driven:
// 1 col on xs, 2 on sm/md, 3 on lg, 4 on xl+. Each card shows cover,
// media-type badge, title, speaker, scripture chip, duration.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';

class LibraryGrid extends StatelessWidget {
  const LibraryGrid({required this.sermons, super.key});
  final List<Sermon> sermons;

  int _columnsFor(double maxWidth) {
    final band = layoutBandFromWidth(maxWidth);
    return switch (band) {
      LayoutBand.xs => 1,
      LayoutBand.sm => 2,
      LayoutBand.md => 2,
      LayoutBand.lg => 3,
      LayoutBand.xl => 3,
      LayoutBand.xxl => 4,
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _columnsFor(constraints.maxWidth);
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _LibraryCard(sermon: sermons[i])
                  .animate(delay: Duration(milliseconds: 30 * i))
                  .fadeIn(duration: 250.ms),
              childCount: sermons.length,
            ),
          ),
        );
      },
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.sermon});
  final Sermon sermon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/sermons/${sermon.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.dividerLight),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SermonThumbnail(
                        thumbnailUrl: sermon.thumbnailUrl,
                        title: sermon.title,
                        borderRadius: BorderRadius.zero,
                      ),
                      if (sermon.hasAudio && !sermon.hasVideo)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.navy.withValues(alpha: 0.75),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: const Icon(
                              Icons.headphones_rounded,
                              color: AppColors.warmWhite,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (sermon.primaryScripture.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        sermon.primaryScripture,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    sermon.durationLabel,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
