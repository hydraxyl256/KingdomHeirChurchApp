// Kingdom Heir — Continue Watching Row (Sermon Home)
//
// Netflix-style horizontal rail of in-progress sermons. Each card shows
// a 16:9 thumbnail, gold progress bar, remaining-time pill, title, and
// speaker. Tap → open the sermon at the saved position.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_continue_item.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';

class ContinueWatchingRow extends StatelessWidget {
  const ContinueWatchingRow({
    required this.items,
    super.key,
    this.onSeeAll,
  });

  final List<SermonContinueItem> items;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Continue watching',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                  ),
                  child: const Text('See all'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) => _ContinueCard(item: items[i])
                .animate(delay: Duration(milliseconds: 60 * i))
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, end: 0),
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.item});
  final SermonContinueItem item;

  @override
  Widget build(BuildContext context) {
    const width = 320.0;
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/home/sermons/${item.sermon.id}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SermonThumbnail(
                    thumbnailUrl: item.sermon.thumbnailUrl,
                    title: item.sermon.title,
                    borderRadius: BorderRadius.zero,
                  ),
                  // Dark gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.navy.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Remaining-time pill
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.8),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: Text(
                        item.remainingLabel,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.sermon.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.warmWhite,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.sermon.speakerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.warmWhite.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: item.progress),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Container(
                        height: 4,
                        color: AppColors.warmWhite.withValues(alpha: 0.3),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: value.clamp(0.0, 1.0),
                            child: Container(color: AppColors.gold),
                          ),
                        ),
                      ),
                    ),
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
