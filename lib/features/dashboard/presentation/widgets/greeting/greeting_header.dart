// Kingdom Heir — Premium Home Dashboard Header (REDESIGNED)
//
// Replaces the plain gradient/white block with a full-width immersive hero
// that matches the visual quality of YouVersion, Hallow, Glorify, and Abide.
//
// Stack architecture:
//   Layer 0 — bundled hero asset (Image.asset, BoxFit.cover, slow Ken Burns)
//   Layer 1 — dark linear gradient overlay (bottom-heavy, ensures readability)
//   Layer 2 — vignette radial overlay (subtle edge darkening)
//   Layer 3 — content column (app brand, date, greeting, name, subtitle, chips)
//
// DashboardTopBar (sticky SliverAppBar):
//   Left  — "Kingdom Heirs" brand mark (Playfair Display, gold)
//   Right — Bell (Phosphor) + gold-bordered avatar
//
// Typography:
//   Date      → labelSmall, gold, uppercase, 1.8 letter-spacing
//   Greeting  → headlineMedium, white, bold
//   Name      → headlineMedium, gold, italic, bold
//   Subtitle  → bodySmall, #CBD5E1, italic
//
// Chips (glassmorphism):
//   Streak  → PhosphorIconsBold.flame  + gold glow border
//   Notifs  → PhosphorIconsRegular.bellRinging (shown when > 0)
//
// Icons: exclusively Phosphor — no Material icons, no emojis.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardTopBar — Sticky sliver app bar (brand + avatar + bell)
// ─────────────────────────────────────────────────────────────────────────────

/// Sticky top bar. Shows the Kingdom Heirs brand on the left and the
/// user avatar + notification bell on the right.
/// "Royal Steward" / raw firstName text is intentionally absent — the brand
/// identity replaces it so the app never displays a user name as the title.
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
      // ── Brand mark ────────────────────────────────────────────────────────
      title: Row(
        children: [
          const Icon(
            PhosphorIconsBold.cross,
            color: AppColors.gold,
            size: 16,
            semanticLabel: 'Kingdom Heirs',
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Kingdom Heirs',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontFamily: 'Playfair Display',
              color: isDark ? AppColors.goldLight : AppColors.goldDark,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
      // ── Actions: notification bell + avatar ───────────────────────────────
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: AppLocalizations.of(context)!.notifications,
              icon: Icon(
                PhosphorIconsRegular.bellRinging,
                color: cs.onSurface,
                semanticLabel: 'Notifications',
              ),
              onPressed: onNotificationTap,
            ),
            if (greeting.unreadNotifications > 0)
              Positioned(
                top: 10,
                right: 10,
                child: _NotificationDot(
                  count: greeting.unreadNotifications,
                ).animate().scale(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutBack,
                    ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: GestureDetector(
            onTap: onAvatarTap,
            child: Semantics(
              label: 'View profile',
              button: true,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.30),
                      blurRadius: 8,
                    ),
                  ],
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
                      ? const Icon(
                          PhosphorIconsRegular.userCircle,
                          color: AppColors.gold,
                          size: 20,
                          semanticLabel: 'Profile',
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HeroHeader — public alias used by dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

/// Public alias so dashboard_screen.dart requires zero changes.
class HeroHeader extends StatelessWidget {
  const HeroHeader({required this.greeting, super.key});

  final DashboardGreeting greeting;

  @override
  Widget build(BuildContext context) => _PremiumHeroBanner(greeting: greeting);
}

// ─────────────────────────────────────────────────────────────────────────────
// _PremiumHeroBanner — Full-width immersive hero
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumHeroBanner extends StatelessWidget {
  const _PremiumHeroBanner({required this.greeting});

  final DashboardGreeting greeting;

  static String _cleanTagline(String raw) => raw
      .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
      .trim();

  @override
  Widget build(BuildContext context) {
    final today =
        DateFormat('EEEE • MMMM d').format(DateTime.now()).toUpperCase();
    final displayName = greeting.firstName.isNotEmpty
        ? greeting.firstName
        : 'Kingdom Heirs Member';
    final tagline = _cleanTagline(greeting.tagline);

    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth < 360
        ? 260.0
        : screenWidth < 480
            ? 300.0
            : screenWidth > 700
                ? 380.0
                : 320.0;

    return SizedBox(
      width: double.infinity,
      height: bannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 0: Hero background image ───────────────────────────────
          const _HeroImage(),

          // ── Layer 1: Dark gradient overlay (bottom-heavy) ────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x22000000),
                  Color(0x88000000),
                  Color(0xE8000000),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ── Layer 2: Edge vignette ────────────────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.1,
                colors: [
                  Colors.transparent,
                  Color(0x44000000),
                ],
              ),
            ),
          ),

          // ── Layer 3: Content ─────────────────────────────────────────────
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // App identity
                    Row(
                      children: [
                        const Icon(
                          PhosphorIconsBold.cross,
                          color: AppColors.gold,
                          size: 13,
                          semanticLabel: 'Kingdom Heirs',
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Kingdom Heirs',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.gold,
                            fontFamily: 'Playfair Display',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: AppSpacing.xs),

                    // Date
                    Text(
                      today,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.gold,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 60.ms),

                    const SizedBox(height: AppSpacing.sm),

                    // "Good Morning,"
                    Text(
                      '${greeting.greeting},',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.warmWhite,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -0.3,
                        shadows: [
                          const Shadow(
                            color: Color(0x99000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 350.ms, delay: 120.ms)
                        .slideY(begin: 0.15, end: 0),

                    // User name (gold italic)
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.goldLight,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -0.2,
                        shadows: [
                          const Shadow(
                            color: Color(0xAA000000),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 350.ms, delay: 200.ms)
                        .slideY(begin: 0.15, end: 0),

                    const SizedBox(height: AppSpacing.sm),

                    // Subtitle
                    Text(
                      tagline,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        shadows: [
                          const Shadow(
                            color: Color(0x88000000),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: 270.ms),

                    const SizedBox(height: AppSpacing.md),

                    // Glassmorphism chips
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _GlassChip(
                          icon: PhosphorIconsBold.flame,
                          iconColor: AppColors.goldLight,
                          label: greeting.streakDays > 0
                              ? '${greeting.streakDays}-Day Streak'
                              : 'Start Your Streak',
                        ),
                        if (greeting.unreadNotifications > 0)
                          _GlassChip(
                            icon: PhosphorIconsRegular.bellRinging,
                            iconColor: AppColors.goldLight,
                            label: '${greeting.unreadNotifications} New',
                          ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 350.ms, delay: 340.ms)
                        .slideY(begin: 0.12, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeroImage — Ken Burns slow zoom (repeating)
// ─────────────────────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/dashboard/verse_bg.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: AppColors.navy,
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.06, 1.06),
          duration: const Duration(seconds: 12),
          curve: Curves.easeInOut,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GlassChip — glassmorphism pill (streak / notifications)
// ─────────────────────────────────────────────────────────────────────────────

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.gold,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.38),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.12),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 15,
                semanticLabel: label,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.warmWhite,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NotificationDot — gold badge on the bell icon
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationDot extends StatelessWidget {
  const _NotificationDot({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final showCount = count < 10;
    return Container(
      width: showCount ? 14 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(AppRadius.circle),
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: showCount
          ? Text(
              '$count',
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1,
              ),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardGreetingBanner — legacy alias
// ─────────────────────────────────────────────────────────────────────────────

/// Alias retained for backwards compatibility. Delegates to [_PremiumHeroBanner].
class DashboardGreetingBanner extends StatelessWidget {
  const DashboardGreetingBanner({required this.greeting, super.key});

  final DashboardGreeting greeting;

  @override
  Widget build(BuildContext context) => _PremiumHeroBanner(greeting: greeting);
}
