// Kingdom Heir — Personalized Hero (SECTION 1)
//
// The most important visual moment in the app. Renders inside a GlassCard
// (frosted navy gradient with gold accent border) and adapts its layout by
// band:
//   • xs / sm: vertical stack — greeting, streak, avatar in a row
//   • md: same as xs but with breathing room
//   • lg+: two-column — greeting + streak on the left, large avatar + bell
//     on the right
//
// A subtle pulsing "live" indicator pulses whenever [streakDays] >= 7.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/responsive/sizing.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/glass_card.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';

class PersonalizedHero extends StatelessWidget {
  const PersonalizedHero({
    required this.data,
    super.key,
    this.onNotificationsTap,
  });

  final HeroGreeting data;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final sizing = Sizing.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final band = layoutBandFromWidth(constraints.maxWidth);
        final isWide = band.isAtLeast(LayoutBand.lg);

        final greetingText = '${data.greeting},';
        final nameText = data.firstName;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            insets.lg,
            insets.sm,
            insets.lg,
            insets.lg,
          ),
          child: GlassCard(
            radius: BorderRadius.circular(AppRadius.xxl),
            padding: EdgeInsets.symmetric(
              horizontal: insets.lg,
              vertical: insets.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row — avatar + bell OR full-width text depending on band.
                if (isWide)
                  _WideTopRow(
                    data: data,
                    sizing: sizing,
                    onNotificationsTap: onNotificationsTap,
                  )
                else
                  _NarrowTopRow(
                    data: data,
                    sizing: sizing,
                    onNotificationsTap: onNotificationsTap,
                  ),
                SizedBox(height: insets.lg),
                // Greeting + tagline
                Text(
                  greetingText,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: AppMotion.standard,
                      curve: AppMotion.decelerate,
                    )
                    .slideY(begin: 0.2, end: 0),
                SizedBox(height: insets.xxs),
                Text(
                  nameText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.displaySmall?.copyWith(
                    color: AppColors.warmWhite,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: AppMotion.emphasized,
                      delay: const Duration(milliseconds: 60),
                      curve: AppMotion.decelerate,
                    )
                    .slideY(begin: 0.2, end: 0),
                SizedBox(height: insets.sm),
                Text(
                  data.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmWhite.withValues(alpha: 0.78),
                  ),
                ).animate().fadeIn(
                      duration: AppMotion.standard,
                      delay: const Duration(milliseconds: 140),
                    ),
                SizedBox(height: insets.lg),
                _StreakBadge(streakDays: data.streakDays),
                SizedBox(height: insets.sm),
                _SeasonPill(label: data.seasonLabel),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WideTopRow extends StatelessWidget {
  const _WideTopRow({
    required this.data,
    required this.sizing,
    this.onNotificationsTap,
  });

  final HeroGreeting data;
  final Sizing sizing;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SeasonPill(label: data.seasonLabel),
              SizedBox(height: insets.sm),
              _StreakBadge(streakDays: data.streakDays),
            ],
          ),
        ),
        SizedBox(width: insets.md),
        _AvatarWithBell(
          sizing: sizing,
          avatarUrl: data.avatarUrl,
          firstName: data.firstName,
          onNotificationsTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _NarrowTopRow extends StatelessWidget {
  const _NarrowTopRow({
    required this.data,
    required this.sizing,
    this.onNotificationsTap,
  });

  final HeroGreeting data;
  final Sizing sizing;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StreakBadge(streakDays: data.streakDays, compact: true),
        _AvatarWithBell(
          sizing: sizing,
          avatarUrl: data.avatarUrl,
          firstName: data.firstName,
          onNotificationsTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _AvatarWithBell extends StatelessWidget {
  const _AvatarWithBell({
    required this.sizing,
    this.avatarUrl,
    this.firstName,
    this.onNotificationsTap,
  });

  final Sizing sizing;
  final String? avatarUrl;
  final String? firstName;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onNotificationsTap,
            customBorder: const CircleBorder(),
            child: Container(
              padding: EdgeInsets.all(insets.xs),
              decoration: BoxDecoration(
                color: AppColors.warmWhite.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.warmWhite,
                size: sizing.iconMd,
              ),
            ),
          ),
        ),
        SizedBox(width: insets.sm),
        Container(
          width: sizing.avatarLg,
          height: sizing.avatarLg,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.navy,
            ),
            clipBehavior: Clip.antiAlias,
            child: hasAvatar
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Initial(
                      (firstName?.isNotEmpty ?? false)
                          ? firstName![0].toUpperCase()
                          : 'K',
                    ),
                  )
                : _Initial(
                    (firstName?.isNotEmpty ?? false)
                        ? firstName![0].toUpperCase()
                        : 'K',
                  ),
          ),
        ),
      ],
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial(this.letter);
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        letter,
        style: AppTypography.textTheme.headlineMedium?.copyWith(
          color: AppColors.warmWhite,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streakDays, this.compact = false});
  final int streakDays;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? insets.sm : insets.md,
        vertical: compact ? insets.xxs : insets.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pulse(),
          SizedBox(width: insets.xs),
          Text(
            '$streakDays-day streak',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulse() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.goldLight,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          duration: const Duration(milliseconds: 1200),
          begin: const Offset(0.7, 0.7),
          end: const Offset(1.1, 1.1),
        )
        .fade(
          duration: const Duration(milliseconds: 1200),
          begin: 0.6,
          end: 1,
        );
  }
}

class _SeasonPill extends StatelessWidget {
  const _SeasonPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: insets.sm,
        vertical: insets.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warmWhite.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.goldLight, size: 12),
          SizedBox(width: insets.xs),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
