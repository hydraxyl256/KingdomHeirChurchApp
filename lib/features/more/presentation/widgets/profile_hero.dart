// Kingdom Heir — Profile Hero (SECTION 1)
//
// Top-of-screen premium card showing:
//   • Greeting (time-of-day based)
//   • Display name + role chip
//   • Spiritual streak + member-since
//   • Avatar with gold ring
//   • Quick-action "View profile" link
//
// Visual:
//   • GlassCard (navyGold tone) with frosted backdrop
//   • Gold accent border, navy gradient overlay
//   • Avatar with gold ring on the right; on < 360 dp the avatar moves
//     to the top row so the name doesn't fight for horizontal space.
//
// Animation:
//   • Self-contained 400ms opacity + Y-translate fade-in via
//     `TweenAnimationBuilder` (no flutter_animate — its internal Builder
//     crashed inside SliverToBoxAdapter).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/core/widgets/glass_card.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart'
    show MoreProfileHero;

class ProfileHeroSection extends StatelessWidget {
  const ProfileHeroSection({required this.hero, super.key});

  final MoreProfileHero hero;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final greeting = _greeting();
    final initial =
        (hero.displayName.isNotEmpty ? hero.displayName.characters.first : 'K')
            .toUpperCase();

    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.lg, insets.lg, insets.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow =
              layoutBandFromWidth(constraints.maxWidth).isAtMost(LayoutBand.sm);

          final greetingLine = Text(
            greeting,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.gold.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          );

          final nameLine = Text(
            hero.displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          );

          final roleChip = _RoleChip(roleLabel: hero.roleLabel);

          final streak = _MetaRow(
            icon: Icons.local_fire_department_rounded,
            label: '${hero.streakDays}-day streak',
          );

          final memberSince = _MetaRow(
            icon: Icons.workspace_premium_outlined,
            label: hero.memberSinceLabel,
          );

          final avatar = _ProfileAvatar(
            avatarUrl: hero.avatarUrl,
            initial: initial,
          );

          final content = GlassCard(
            padding: EdgeInsets.fromLTRB(
              insets.lg,
              insets.lg,
              insets.lg,
              insets.lg,
            ),
            onTap: () => GoRouter.of(context).push(RouteNames.myProfile),
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          avatar,
                          SizedBox(width: insets.md),
                          Expanded(child: greetingLine),
                        ],
                      ),
                      SizedBox(height: insets.md),
                      nameLine,
                      SizedBox(height: insets.sm),
                      roleChip,
                      SizedBox(height: insets.md),
                      Wrap(
                        spacing: insets.md,
                        runSpacing: insets.xs,
                        children: [streak, memberSince],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                greetingLine,
                                SizedBox(height: insets.xs),
                                nameLine,
                                SizedBox(height: insets.sm),
                                roleChip,
                              ],
                            ),
                          ),
                          SizedBox(width: insets.md),
                          avatar,
                        ],
                      ),
                      SizedBox(height: insets.md),
                      Wrap(
                        spacing: insets.md,
                        runSpacing: insets.xs,
                        children: [streak, memberSince],
                      ),
                    ],
                  ),
          );

          return _ProfileHeroFadeIn(child: content);
        },
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'GOOD NIGHT';
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    if (hour < 21) return 'GOOD EVENING';
    return 'GOOD NIGHT';
  }
}

/// Self-contained opacity + Y-translate fade-in for the profile hero.
/// Replaces flutter_animate's chain so SliverToBoxAdapter measurement
/// never sees an internal Builder.
class _ProfileHeroFadeIn extends StatelessWidget {
  const _ProfileHeroFadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.roleLabel});

  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.gold, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              roleLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.gold, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.warmWhite.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl, required this.initial});

  final String? avatarUrl;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: AppAvatar(
        imageUrl: avatarUrl,
        name: initial,
        size: 56,
      ),
    );
  }
}

/// Skeleton placeholder used while the profile loads.
class ProfileHeroSkeleton extends StatelessWidget {
  const ProfileHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.lg, insets.lg, insets.sm),
      child: GlassCard(
        padding: EdgeInsets.all(insets.lg),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.warmWhite.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 10,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.warmWhite.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  SizedBox(height: insets.xs),
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.warmWhite.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
