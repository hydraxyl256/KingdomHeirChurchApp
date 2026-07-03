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
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.85),
      titleSpacing: AppSpacing.md,
      title: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
                image: greeting.avatarUrl != null
                    ? DecorationImage(
                        image: AssetImage(greeting.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: greeting.avatarUrl == null
                  ? const Icon(Icons.person, color: AppColors.gold)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Royal Steward',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontFamily: 'Playfair Display', // or fallback to serif
              color: AppColors.goldDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
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
        // Simulated Shader Background (Animated Gradient)
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
                'Welcome Home,\n',
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
              
              const SizedBox(height: AppSpacing.lg),
              
              // Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _StreakPill(
                      icon: Icons.local_fire_department,
                      label: '${greeting.streakDays} Day Prayer Streak',
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const _StreakPill(
                      icon: Icons.menu_book,
                      label: '24% Through Genesis',
                    ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: AppElevation.shadowFor(AppElevation.level1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.goldDark, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
