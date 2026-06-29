// Kingdom Heir — Section 1: Dynamic Greeting Header
//
// Time-aware greeting with avatar shortcut, notification badge, and
// a soft inspirational tagline. Animates in on mount.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    required this.greeting,
    super.key,
    this.onNotificationTap,
    this.onSearchTap,
    this.onAvatarTap,
  });

  final DashboardGreeting greeting;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Get localized greeting based on time of day
    String getGreeting(GreetingMoment moment) {
      switch (moment) {
        case GreetingMoment.morning:
          return localizations.goodMorning;
        case GreetingMoment.afternoon:
          return localizations.goodAfternoon;
        case GreetingMoment.evening:
          return localizations.goodEvening;
        case GreetingMoment.night:
          return localizations.goodNight;
      }
    }

    // Get localized tagline based on time of day
    String getTagline(GreetingMoment moment) {
      switch (moment) {
        case GreetingMoment.morning:
          return localizations.morningTagline;
        case GreetingMoment.afternoon:
          return localizations.afternoonTagline;
        case GreetingMoment.evening:
          return localizations.eveningTagline;
        case GreetingMoment.night:
          return localizations.nightTagline;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Avatar
          _Avatar(
            avatarUrl: greeting.avatarUrl,
            firstName: greeting.firstName,
            onTap: onAvatarTap,
          ).animate().fadeIn(duration: 300.ms).scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(width: AppSpacing.md),
          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getGreeting(greeting.moment),
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.goldDark,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 60.ms, duration: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms),
                Text(
                  greeting.firstName,
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                    .animate()
                    .fadeIn(delay: 90.ms, duration: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms),
                const SizedBox(height: 2),
                Text(
                  getTagline(greeting.moment),
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(delay: 140.ms, duration: 350.ms),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Action icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBtn(
                icon: Icons.search_rounded,
                onTap: onSearchTap,
              ),
              _NotificationBtn(
                count: greeting.unreadNotifications,
                onTap: onNotificationTap,
              ),
            ],
          ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.firstName,
    this.avatarUrl,
    this.onTap,
  });

  final String? avatarUrl;
  final String firstName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSpacing.avatarLg,
        height: AppSpacing.avatarLg,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.goldDark, AppColors.gold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: avatarUrl != null
            ? ClipOval(
                child: Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _Initials(name: firstName),
                ),
              )
            : _Initials(name: firstName),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'K',
        style: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            size: AppSpacing.iconMd,
            color: AppColors.navy.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _NotificationBtn extends StatelessWidget {
  const _NotificationBtn({required this.count, this.onTap});
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: AppSpacing.iconMd,
                color: AppColors.navy.withValues(alpha: 0.7),
              ),
              if (count > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
