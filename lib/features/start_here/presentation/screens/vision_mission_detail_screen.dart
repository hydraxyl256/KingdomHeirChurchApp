// Kingdom Heirs — Vision & Mission screen (release polish).
//
// Redesign per `C:\Users\HP\Desktop\Vision & Mission.txt`:
//   "The screen should contain only two elegant premium cards."
//
//   Card 1 — Our Mission
//   Card 2 — Our Vision
//
// Requirements:
//   • Premium typography, beautiful spacing, elegant iconography.
//   • Soft shadows, rounded cards, church branding, gold accents.
//   • Responsive layout, subtle fade animations.
//   • No placeholder graphics, no unnecessary text, no clutter.
//   • "This page should feel like an official ministry presentation."

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Verbatim copy from `C:\Users\HP\Desktop\Vision & Mission.txt`.
// ─────────────────────────────────────────────────────────────────────────────

const String _kMissionBody =
    'Kingdom Heirs Foundation is dedicated to advancing the gospel of '
    'Jesus Christ by addressing both the spiritual and practical needs '
    'of communities. Through strategic partnerships with local churches, '
    'we merge evangelism with humanitarian outreach—bringing freedom, '
    'dignity, and hope to those most in need while combating issues like '
    'modern slavery.';

const String _kVisionBody =
    'Our vision is to witness cities, nations, and unreached people '
    'groups transformed as the Church unites in compassion, evangelism, '
    'and discipleship.';

class VisionMissionDetailScreen extends ConsumerWidget {
  const VisionMissionDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => context.canPop() ? context.pop() : null),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  final cards = <Widget>[
                    const _MissionCard(body: _kMissionBody)
                        .animate()
                        .fadeIn(
                          duration: AppMotion.standard,
                          curve: AppMotion.decelerate,
                        )
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          duration: AppMotion.standard,
                          curve: AppMotion.decelerate,
                        ),
                    const _VisionCard(body: _kVisionBody)
                        .animate()
                        .fadeIn(
                          duration: AppMotion.standard,
                          delay: const Duration(milliseconds: 120),
                          curve: AppMotion.decelerate,
                        )
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          duration: AppMotion.standard,
                          delay: const Duration(milliseconds: 120),
                          curve: AppMotion.decelerate,
                        ),
                  ];
                  if (isWide) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.huge,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(child: cards[1]),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.huge,
                    ),
                    children: [
                      cards[0],
                      const SizedBox(height: AppSpacing.xl),
                      cards[1],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: onBack,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VISION & MISSION',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Who we are.',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.warmWhite
                        : AppColors.navy,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.warmWhite
                : AppColors.navy,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mission card (Card 1) — gold-tinted
// ─────────────────────────────────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      iconBg: AppColors.goldContainer,
      iconColor: AppColors.goldDark,
      icon: Icons.volunteer_activism_rounded,
      eyebrow: 'OUR MISSION',
      title: 'Advancing the gospel.',
      body: body,
      accent: _CardAccent.gold,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vision card (Card 2) — navy-tinted
// ─────────────────────────────────────────────────────────────────────────────

class _VisionCard extends StatelessWidget {
  const _VisionCard({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      iconBg: AppColors.goldContainer,
      iconColor: AppColors.goldDark,
      icon: Icons.public_rounded,
      eyebrow: 'OUR VISION',
      title: 'Cities, nations, transformed.',
      body: body,
      accent: _CardAccent.navy,
    );
  }
}

enum _CardAccent { gold, navy }

// ─────────────────────────────────────────────────────────────────────────────
// Shared premium card chrome
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String eyebrow;
  final String title;
  final String body;
  final _CardAccent accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = accent == _CardAccent.gold
        ? const LinearGradient(
            colors: [AppColors.goldDark, AppColors.gold, AppColors.goldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [AppColors.navy, AppColors.navyMid, AppColors.navyAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final onSurfaceColor =
        accent == _CardAccent.gold ? AppColors.navy : AppColors.warmWhite;

    // Fix body color to contrast with the actual card surface, not the accent banner.
    // In dark mode, card surface is dark (AppColors.surfaceDark), so body text must be light.
    // In light mode, card surface is light (AppColors.surface), so body text must be dark.
    final bodyColor = isDark
        ? AppColors.warmWhite.withValues(alpha: 0.85)
        : AppColors.navy.withValues(alpha: 0.78);

    final eyebrowColor = accent == _CardAccent.gold
        ? AppColors.goldDark
        : AppColors.goldLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A), // navy @ 8%
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Accent banner with icon + eyebrow ─────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              decoration: BoxDecoration(gradient: gradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A0F172A), // navy @ 10%
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: AppSpacing.iconLg,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    eyebrow,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: eyebrowColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: onSurfaceColor,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body copy on warm white surface ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Text(
                body,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: bodyColor,
                  height: 1.6,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
