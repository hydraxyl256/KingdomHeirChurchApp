// Kingdom Heir — Download Tile
//
// A single row in the Downloads screen. Shows thumbnail, title, speaker,
// file size, downloaded date, and play/remove actions.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_download.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';

class DownloadTile extends StatelessWidget {
  const DownloadTile({
    required this.download,
    required this.sermon,
    required this.onRemove,
    super.key,
  });

  final SermonDownload download;
  final Sermon? sermon;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs,),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: sermon == null
              ? null
              : () => context.push('/home/sermons/${sermon!.id}/audio'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                SizedBox(
                  width: 88,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: SermonThumbnail(
                        thumbnailUrl: sermon?.thumbnailUrl,
                        title: sermon?.title ?? 'Sermon',
                        aspectRatio: 1,
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
                        sermon?.title ?? 'Sermon',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sermon?.speakerName ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.headphones_rounded,
                                size: 12,
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                download.humanSize,
                                style: AppTypography.textTheme.labelSmall?.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: AppSpacing.sm - 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat.MMMd().format(download.downloadedAt),
                                style: AppTypography.textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: sermon == null
                      ? null
                      : () => context.push('/home/sermons/${sermon!.id}/audio'),
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  color: AppColors.gold,
                  iconSize: 36,
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.04, end: 0);
  }
}
