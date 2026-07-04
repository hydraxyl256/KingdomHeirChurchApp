import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

/// Top App Bar (Sticky)
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

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 4,
      // Adaptive: light-glass on white, navy-glass on dark
      backgroundColor: cs.surface.withValues(alpha: 0.88),
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
                radius: 19,
                backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                backgroundImage: greeting.avatarUrl != null
                    ? NetworkImage(greeting.avatarUrl!)
                    : null,
                onBackgroundImageError: greeting.avatarUrl != null
                    ? (_, __) {} // silently fallback to child
                    : null,
                child: greeting.avatarUrl == null
                    ? const Icon(Icons.person_rounded,
                        color: AppColors.gold, size: 20,)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Royal Steward',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontFamily: 'Playfair Display',
              color: AppColors.goldDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          // Use colorScheme.onSurface so it adapts to dark/light
          icon: Icon(Icons.notifications_none_rounded, color: cs.onSurface),
          onPressed: onNotificationTap,
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}

/// Premium Hero Header
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    required this.greeting,
    super.key,
  });

  final DashboardGreeting greeting;

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Stack(
      children: [
        // Animated gradient background (intentionally dark/navy — the hero
        // is always rendered as a cinematic dark band regardless of theme)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .custom(
             duration: const Duration(seconds: 4),
             builder: (_, value, child) {
               return Container(
                 decoration: BoxDecoration(
                   gradient: RadialGradient(
                     center: Alignment(0, -0.5 + (value * 0.2)),
                     radius: 1.5,
                     colors: [
                       AppColors.gold.withValues(alpha: 0.15),
                       Colors.transparent,
                     ],
                   ),
                 ),
               );
             },
           ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                today.toUpperCase(),
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.gold,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${greeting.greeting},',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              Text(
                greeting.firstName,
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color: AppColors.gold,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.sm),

              Text(
                greeting.tagline,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fadeIn(delay: 280.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.lg),

              // Pills — always on the dark hero, so use white/warmWhite text
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _StreakPill(
                      icon: Icons.local_fire_department,
                      label: greeting.streakDays > 0
                          ? '${greeting.streakDays}-Day Streak 🔥'
                          : 'Start Your Streak',
                    ),
                    if (greeting.unreadNotifications > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _StreakPill(
                        icon: Icons.notifications_active_rounded,
                        label: '${greeting.unreadNotifications} New',
                      ),
                    ],
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Pill lives inside the always-dark HeroHeader band, so keep
    // translucent white glass styling regardless of theme.
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        // Translucent white — readable on both navy and darker backgrounds
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: AppElevation.shadowFor(AppElevation.level1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              // Always white/warmWhite — pill sits on the dark hero banner
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
