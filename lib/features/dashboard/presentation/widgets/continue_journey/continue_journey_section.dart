// Kingdom Heir — Continue Journey (SECTION 3)
//
// Horizontal rail of "pick up where you left off" cards. Each card renders:
//   • A tinted thumbnail block with a kind-specific icon
//   • Kind label (uppercase, gold)
//   • Title (titleSmall, 2 lines max)
//   • Subtitle (bodySmall)
//   • Progress bar (gold)
//
// Card width is derived from LayoutBuilder — never a fixed dp value — so the
// rail looks balanced on 320 dp phones, 360 dp phones, tablets, and desktop.
//
// An empty list shows the [DashboardEmptyState].

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/states/dashboard_empty_state.dart';

class ContinueJourneySection extends StatelessWidget {
  const ContinueJourneySection({
    required this.items,
    super.key,
    this.onSeeAll,
    this.onItemTap,
  });

  final List<ContinueItem> items;
  final VoidCallback? onSeeAll;
  final void Function(ContinueItem)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'Continue your journey',
          subtitle: 'Pick up where you left off',
          actionLabel: items.length > 3 ? 'See all' : null,
          onAction: onSeeAll,
          icon: Icons.replay_rounded,
        ),
        if (items.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: DashboardEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'Nothing to continue yet',
              body:
                  'Start a sermon, plan, or devotional — your progress will appear here.',
              actionLabel: 'Browse content',
              onAction: onSeeAll,
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final band = layoutBandFromWidth(constraints.maxWidth);
              final factor = switch (band) {
                LayoutBand.xs => 0.78,
                LayoutBand.sm => 0.72,
                LayoutBand.md => 0.62,
                LayoutBand.lg => 0.42,
                LayoutBand.xl => 0.32,
                LayoutBand.xxl => 0.26,
              };
              final cardWidth = constraints.maxWidth * factor;

              return SizedBox(
                height: 224,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: insets.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(width: insets.md),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return SizedBox(
                      width: cardWidth,
                      child: _ContinueCard(
                        item: item,
                        onTap: () => onItemTap?.call(item),
                      )
                          .animate()
                          .fadeIn(
                            duration: AppMotion.standard,
                            delay: Duration(milliseconds: 60 * i),
                            curve: AppMotion.decelerate,
                          )
                          .slideX(begin: 0.15, end: 0),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.item, this.onTap});
  final ContinueItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Thumbnail(item: item),
              Padding(
                padding: EdgeInsets.all(insets.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.kindLabel.toUpperCase(),
                      style: AppTypography.scriptureRef.copyWith(
                        color: AppColors.goldDark,
                      ),
                    ),
                    SizedBox(height: insets.xxs),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: insets.xxs),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: insets.sm),
                    _ProgressBar(progress: item.progress),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.item});
  final ContinueItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (color, icon) = _kindVisual(item.kind);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [color.withValues(alpha: 0.7), AppColors.navyMid]
                    : [color, AppColors.navyMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmWhite.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warmWhite.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(icon, color: AppColors.warmWhite, size: 18),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.ink,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _kindVisual(ContinueKind kind) => switch (kind) {
        ContinueKind.sermon => (AppColors.gold, Icons.church_rounded),
        ContinueKind.biblePlan => (AppColors.tertiary, Icons.menu_book_rounded),
        ContinueKind.devotional => (
            AppColors.success,
            Icons.auto_stories_rounded
          ),
        ContinueKind.podcast => (AppColors.navyAccent, Icons.podcasts_rounded),
      };
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: AppMotion.decelerate,
              builder: (context, value, _) {
                return Container(
                  height: 4,
                  width: constraints.maxWidth * value,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
