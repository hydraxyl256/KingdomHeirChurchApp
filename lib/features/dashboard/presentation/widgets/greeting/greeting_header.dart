// Kingdom Heir — Section 1: Premium Greeting Header
//
// Time-aware hero header with avatar, date row, weather chip, streak pill,
// and notification/search actions. All icons come from `Iconography` —
// Phosphor only, no mixed families.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    required this.greeting,
    super.key,
    this.onNotificationTap,
    this.onSearchTap,
    this.onAvatarTap,
    this.onStreakTap,
  });

  final DashboardGreeting greeting;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onStreakTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final greetingLine = _greetingText(loc, greeting.moment);
    final tagline = _taglineText(loc, greeting.moment);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date + weather row
          Row(
            children: [
              Flexible(
                child: Text(
                  today,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _WeatherBadge(),
            ],
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: AppSpacing.md),

          // Avatar + greeting
          Row(
            children: [
              _Avatar(
                avatarUrl: greeting.avatarUrl,
                firstName: greeting.firstName,
                onTap: onAvatarTap,
              ).animate().fadeIn(duration: 320.ms).scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: 320.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      greetingLine,
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
                      tagline,
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionBtn(
                    icon: Iconography.search,
                    onTap: onSearchTap,
                    semanticLabel: 'Search',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _NotificationBtn(
                    count: greeting.unreadNotifications,
                    onTap: onNotificationTap,
                  ),
                ],
              ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Streak pill — tappable to jump to Daily Journey section
          _StreakPill(
            days: greeting.streakDays,
            onTap: onStreakTap,
          ).animate().fadeIn(delay: 220.ms, duration: 320.ms).slideY(
                begin: 0.15,
                end: 0,
                duration: 320.ms,
                curve: Curves.easeOut,
              ),
        ],
      ),
    );
  }

  String _greetingText(AppLocalizations? loc, GreetingMoment moment) {
    switch (moment) {
      case GreetingMoment.morning:
        return loc?.goodMorning ?? 'Good Morning';
      case GreetingMoment.afternoon:
        return loc?.goodAfternoon ?? 'Good Afternoon';
      case GreetingMoment.evening:
        return loc?.goodEvening ?? 'Good Evening';
      case GreetingMoment.night:
        return loc?.goodNight ?? 'Good Night';
    }
  }

  String _taglineText(AppLocalizations? loc, GreetingMoment moment) {
    switch (moment) {
      case GreetingMoment.morning:
        return loc?.morningTagline ?? 'Begin your day in the Word.';
      case GreetingMoment.afternoon:
        return loc?.afternoonTagline ?? 'Walk boldly in Christ today.';
      case GreetingMoment.evening:
        return loc?.eveningTagline ?? 'Reflect on His goodness today.';
      case GreetingMoment.night:
        return loc?.nightTagline ?? 'Rest in His peace tonight.';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _WeatherBadge extends StatelessWidget {
  const _WeatherBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.goldContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Iconography.weather,
            size: 14,
            color: AppColors.goldDark,
          ),
          const SizedBox(width: 4),
          Text(
            '72° · Partly Cloudy',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.goldDark,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days, this.onTap});
  final int days;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = days == 1 ? '1 day streak' : '$days day streak';
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldDark, AppColors.gold],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Iconography.streak,
                size: 16,
                color: AppColors.ink,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
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
              blurRadius: 14,
              offset: const Offset(0, 5),
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

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.goldContainer.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: AppSpacing.iconMd,
              color: AppColors.navy,
            ),
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
    return Semantics(
      button: true,
      label: count > 0
          ? 'Notifications, $count unread'
          : 'Notifications',
      child: Material(
        color: AppColors.goldContainer.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Iconography.notifications,
                  size: AppSpacing.iconMd,
                  color: AppColors.navy,
                ),
                if (count > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}