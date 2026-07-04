import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardTopBar — Sticky sliver app bar (avatar + title + bell)
// ─────────────────────────────────────────────────────────────────────────────

/// Sticky top bar that scrolls under the content. Theme-adaptive surface.
class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    required this.greeting,
    super.key,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  final DashboardGreeting greeting;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: cs.surface.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      titleSpacing: AppSpacing.md,
      title: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.gold.withValues(alpha: 0.18),
                backgroundImage: greeting.avatarUrl != null
                    ? NetworkImage(greeting.avatarUrl!)
                    : null,
                onBackgroundImageError:
                    greeting.avatarUrl != null ? (_, __) {} : null,
                child: greeting.avatarUrl == null
                    ? const Icon(Icons.person_rounded,
                        color: AppColors.gold, size: 19,)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              greeting.firstName,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontFamily: 'Playfair Display',
                color: isDark ? AppColors.goldLight : AppColors.goldDark,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                color: cs.onSurface,
              ),
              onPressed: onNotificationTap,
            ),
            if (greeting.unreadNotifications > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardGreetingBanner — responsive, theme-adaptive hero banner
// ─────────────────────────────────────────────────────────────────────────────
//
// Root-cause of previous issues:
//   • Stack + Positioned.fill with a looping animated RadialGradient had no
//     intrinsic height — the Stack collapsed and the animated layer bled
//     outside the banner bounds.
//   • All text colors were hardcoded white/white54, making the banner
//     completely unreadable in light theme.
//   • Chips were in a SingleChildScrollView→Row with no overflow protection.
//
// This widget:
//   • Uses a plain Container (no Stack/Positioned) with a theme-specific
//     decoration → the banner sizes to its content naturally.
//   • Defines separate semantic color sets for dark and light.
//   • Uses Wrap for chips so they reflow on narrow screens.
//   • Has no fixed height — padding + content drives the height.

// Keep as a private alias so the call-site in dashboard_screen.dart continues
// to use `HeroHeader(greeting: data.greeting)` with no changes.
class HeroHeader extends StatelessWidget {
  const HeroHeader({required this.greeting, super.key});

  final DashboardGreeting greeting;

  @override
  Widget build(BuildContext context) =>
      DashboardGreetingBanner(greeting: greeting);
}

/// Production-quality, fully responsive greeting banner.
class DashboardGreetingBanner extends StatelessWidget {
  const DashboardGreetingBanner({required this.greeting, super.key});

  final DashboardGreeting greeting;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase();

    // ── Theme-specific semantic colors ────────────────────────────────────────
    //
    // Dark theme:  deep navy banner, warm ivory primary text, gold accents.
    // Light theme: warm ivory/cream banner, deep navy/charcoal primary text,
    //              rich brown-gold accent — no white-on-white issues.

    final bannerDecoration = isDark
        ? const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1A2744)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          )
        : BoxDecoration(
            // Warm ivory/cream — distinct from the page background (white)
            // so the banner reads as an intentional block.
            color: const Color(0xFFF5F0E8),
            border: Border(
              bottom: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.25),
              ),
            ),
          );

    // Date label
    final dateColor = isDark
        ? AppColors.gold
        : const Color(0xFF8B6914); // deep amber-brown, WCAG AA on cream

    // "Good Afternoon," greeting line
    final greetingColor = isDark
        ? AppColors.warmWhite // high contrast on navy
        : const Color(0xFF1A2744); // deep navy on cream — strong contrast

    // Member name (italic gold emphasis)
    final nameColor = isDark
        ? AppColors.goldLight
        : const Color(0xFF9A6C00); // rich warm gold, readable on cream

    // Tagline / subtitle
    final subtitleColor = isDark
        ? const Color(0xFFB0BEC5) // muted blue-grey, readable on navy
        : const Color(0xFF4A5568); // dark slate — clearly readable on cream

    // Chip surface + text
    final chipBackground = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE8DEC8); // pale warm tan on cream background
    final chipBorder = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.gold.withValues(alpha: 0.35);
    final chipTextColor = isDark
        ? AppColors.warmWhite
        : const Color(0xFF5C4500); // dark amber — readable on tan
    final chipIconColor = isDark ? AppColors.gold : const Color(0xFF9A6C00);

    return Container(
      width: double.infinity,
      decoration: bannerDecoration,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Date ──────────────────────────────────────────────────────────
          Text(
            today,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: dateColor,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 350.ms),

          const SizedBox(height: AppSpacing.xs),

          // ── "Good Afternoon," ──────────────────────────────────────────────
          Text(
            '${greeting.greeting},',
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: greetingColor,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.3,
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 350.ms),

          // ── Member name ────────────────────────────────────────────────────
          Text(
            greeting.firstName,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: nameColor,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).animate().fadeIn(delay: 160.ms, duration: 350.ms),

          const SizedBox(height: AppSpacing.sm),

          // ── Tagline ────────────────────────────────────────────────────────
          Text(
            greeting.tagline,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: subtitleColor,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 240.ms, duration: 350.ms),

          const SizedBox(height: AppSpacing.md),

          // ── Chips — Wrap so they reflow on narrow screens ─────────────────
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _BannerChip(
                icon: Icons.local_fire_department_rounded,
                label: greeting.streakDays > 0
                    ? '${greeting.streakDays}-Day Streak 🔥'
                    : 'Start Your Streak',
                background: chipBackground,
                border: chipBorder,
                textColor: chipTextColor,
                iconColor: chipIconColor,
              ),
              if (greeting.unreadNotifications > 0)
                _BannerChip(
                  icon: Icons.notifications_active_rounded,
                  label: '${greeting.unreadNotifications} New',
                  background: chipBackground,
                  border: chipBorder,
                  textColor: chipTextColor,
                  iconColor: chipIconColor,
                ),
            ],
          ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BannerChip — compact pill for streak / notifications
// ─────────────────────────────────────────────────────────────────────────────

class _BannerChip extends StatelessWidget {
  const _BannerChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.border,
    required this.textColor,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color border;
  final Color textColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
