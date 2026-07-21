// Kingdom Heir — Series Episode Tile
//
// One row in the Series screen's episode list. Shows episode number,
// thumbnail, title, date, duration, watched indicator, and a play CTA.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';

class SeriesEpisodeTile extends StatelessWidget {
  const SeriesEpisodeTile({
    required this.episodeNumber,
    required this.sermon,
    required this.isWatched,
    super.key,
  });

  final int episodeNumber;
  final Sermon sermon;
  final bool isWatched;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/home/sermons/${sermon.id}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isWatched
                              ? AppColors.gold
                              : AppColors.surfaceContainerHighLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isWatched
                                ? AppColors.gold
                                : AppColors.dividerLight,
                          ),
                        ),
                        child: Icon(
                          isWatched
                              ? Icons.check_rounded
                              : Icons.play_arrow_rounded,
                          color: isWatched ? AppColors.ink : AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'EP $episodeNumber',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 110,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: SermonThumbnail(
                        thumbnailUrl: sermon.thumbnailUrl,
                        title: sermon.title,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        '${DateFormat.MMMd().format(sermon.publishedAt)} · ${sermon.durationLabel}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
