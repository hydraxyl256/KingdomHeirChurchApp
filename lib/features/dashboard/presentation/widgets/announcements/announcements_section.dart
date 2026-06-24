// Kingdom Heir — Announcements (SECTION 10)
//
// `Wrap`-driven responsive grid of news cards. Pinned announcements render
// first with a gold "Pinned" pill in the corner.
//
// Layout:
//   • xs / sm / md: 1 column
//   • lg: 2 columns
//   • xl+: 3 columns

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

class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({
    required this.announcements,
    super.key,
    this.onSeeAll,
    this.onAnnouncementTap,
  });

  final List<DashboardAnnouncement> announcements;
  final VoidCallback? onSeeAll;
  final void Function(DashboardAnnouncement)? onAnnouncementTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'Announcements',
          subtitle: 'News and updates from your church family',
          actionLabel: announcements.length > 3 ? 'See all' : null,
          onAction: onSeeAll,
          icon: Icons.campaign_rounded,
        ),
        if (announcements.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: const DashboardEmptyState(
              icon: Icons.campaign_outlined,
              title: 'No announcements right now',
              body:
                  "You'll see church news and updates here when they're posted.",
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final band = layoutBandFromWidth(constraints.maxWidth);
              final columns = switch (band) {
                LayoutBand.xs => 1,
                LayoutBand.sm => 1,
                LayoutBand.md => 1,
                LayoutBand.lg => 2,
                LayoutBand.xl => 3,
                LayoutBand.xxl => 3,
              };
              final spacing = insets.md;
              final tileWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                child: Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: List.generate(announcements.length, (i) {
                    return SizedBox(
                      width: tileWidth,
                      child: _AnnouncementCard(
                        announcement: announcements[i],
                        onTap: () => onAnnouncementTap?.call(announcements[i]),
                      )
                          .animate()
                          .fadeIn(
                            duration: AppMotion.standard,
                            delay: Duration(milliseconds: 60 * i),
                            curve: AppMotion.decelerate,
                          )
                          .slideY(begin: 0.1, end: 0),
                    );
                  }),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement, this.onTap});
  final DashboardAnnouncement announcement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border:
                Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (announcement.isPinned)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: insets.md,
                    vertical: insets.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.push_pin_rounded,
                        size: 14,
                        color: AppColors.goldDark,
                      ),
                      SizedBox(width: insets.xs),
                      Text(
                        'PINNED',
                        style: AppTypography.scriptureRef.copyWith(
                          color: AppColors.goldDark,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(insets.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      announcement.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: insets.xs),
                    Text(
                      announcement.body,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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
