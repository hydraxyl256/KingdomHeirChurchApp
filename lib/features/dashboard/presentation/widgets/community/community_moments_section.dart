// Kingdom Heir — Community Moments (SECTION 8)
//
// A vertical list of community feed cards. Each card shows:
//   • Author avatar + name + kind label
//   • Title (titleMedium)
//   • Body (bodyMedium, 3 lines max, ellipsis)
//   • Reaction count with heart icon
//
// On tablets (≥ 1024 dp), the list switches to a 2-column Wrap so the section
// feels native on iPad.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/responsive/sizing.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/states/dashboard_empty_state.dart';

class CommunityMomentsSection extends StatelessWidget {
  const CommunityMomentsSection({
    required this.moments,
    super.key,
    this.onSeeAll,
    this.onMomentTap,
  });

  final List<CommunityMoment> moments;
  final VoidCallback? onSeeAll;
  final void Function(CommunityMoment)? onMomentTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'Community moments',
          subtitle: 'Testimonies, prayer requests, and wins',
          actionLabel: moments.length > 3 ? 'See all' : null,
          onAction: onSeeAll,
          icon: Icons.people_alt_rounded,
        ),
        if (moments.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: DashboardEmptyState(
              icon: Icons.forum_outlined,
              title: 'No community moments yet',
              body: 'Be the first to share a testimony or prayer request.',
              actionLabel: 'Share',
              onAction: onSeeAll,
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final band = layoutBandFromWidth(constraints.maxWidth);
                final twoColumn = band.isAtLeast(LayoutBand.xl);
                final spacing = insets.md;

                if (twoColumn) {
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: List.generate(moments.length, (i) {
                      return SizedBox(
                        width: (constraints.maxWidth - spacing) / 2,
                        child: _CommunityCard(
                          moment: moments[i],
                          onTap: () => onMomentTap?.call(moments[i]),
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
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(moments.length, (i) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i == moments.length - 1 ? 0 : insets.sm,
                      ),
                      child: _CommunityCard(
                        moment: moments[i],
                        onTap: () => onMomentTap?.call(moments[i]),
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
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.moment, this.onTap});
  final CommunityMoment moment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final sizing = Sizing.of(context);
    final theme = Theme.of(context);
    final (accent, icon) = _visual(moment.kind);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(insets.md),
          decoration: BoxDecoration(
            border:
                Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: sizing.avatarSm,
                    height: sizing.avatarSm,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.7),
                          accent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        moment.authorName.isEmpty
                            ? '?'
                            : moment.authorName.characters.first.toUpperCase(),
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.warmWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: insets.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          moment.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(icon, size: 11, color: accent),
                            SizedBox(width: insets.xxs),
                            Text(
                              '${moment.kindLabel.toUpperCase()} · ${_formatDate(moment.publishedAt)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.scriptureRef.copyWith(
                                color: accent,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: insets.sm),
              Text(
                moment.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: insets.xxs),
              Text(
                moment.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: insets.sm),
              Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 14,
                    color: AppColors.goldDark,
                  ),
                  SizedBox(width: insets.xxs),
                  Text(
                    '${moment.reactionCount}',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Amen',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: insets.xxs),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.goldDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat.MMMd().format(dt);
  }

  (Color, IconData) _visual(CommunityKind kind) => switch (kind) {
        CommunityKind.testimony => (
            AppColors.success,
            Icons.auto_awesome_rounded
          ),
        CommunityKind.prayerRequest => (
            AppColors.goldDark,
            Icons.volunteer_activism_rounded
          ),
        CommunityKind.communityWin => (
            AppColors.tertiary,
            Icons.celebration_rounded
          ),
      };
}
