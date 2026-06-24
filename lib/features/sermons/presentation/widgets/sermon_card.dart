import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

/// Premium sermon card for list and grid views.
class SermonCard extends ConsumerWidget {
  const SermonCard({
    required this.sermon,
    required this.onTap,
    super.key,
    this.compact = false,
  });

  final Sermon sermon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyMid : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────────────────
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navy, AppColors.navyAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    sermon.hasVideo
                        ? Icons.play_circle_fill_rounded
                        : Icons.headphones_rounded,
                    color: AppColors.gold,
                    size: AppSpacing.iconLg,
                  ),
                ),
                // Media type badge
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: sermon.hasVideo
                          ? AppColors.error
                          : AppColors.navyAccent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      sermon.hasVideo ? 'VIDEO' : 'AUDIO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: AppSpacing.md),

            // ── Content ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sermon.title,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxxs),
                  Text(
                    sermon.speakerName,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 11,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            sermon.durationLabel,
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (sermon.scriptureReference != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              size: 11,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                sermon.scriptureReference!,
                                style: AppTypography.textTheme.labelSmall?.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Actions ────────────────────────────────────────────────
            Column(
              children: [
                // Favourite
                GestureDetector(
                  onTap: () => ref
                      .read(sermonsListProvider.notifier)
                      .toggleFavourite(sermon.id),
                  child: Icon(
                    sermon.isFavorited
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: sermon.isFavorited ? AppColors.gold : Colors.grey,
                    size: AppSpacing.iconSm,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Download
                GestureDetector(
                  onTap: () => ref
                      .read(sermonsListProvider.notifier)
                      .toggleDownload(sermon.id),
                  child: Icon(
                    sermon.isDownloaded
                        ? Icons.download_done_rounded
                        : Icons.download_outlined,
                    color:
                        sermon.isDownloaded ? AppColors.success : Colors.grey,
                    size: AppSpacing.iconSm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
