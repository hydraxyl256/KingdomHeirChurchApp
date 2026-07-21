import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

/// Card variants available in Kingdom Heir.
enum AppCardVariant {
  /// Standard white/navy card with border.
  standard,

  /// Gold gradient border — for featured/highlighted content.
  featured,

  /// Solid gold gradient background — for primary CTAs / banners.
  goldBanner,

  /// Navy gradient background — for dark accent sections.
  navyBanner,
}

/// Production card component with consistent border, elevation, radius,
/// and support for featured/banner variants.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding,
    this.margin,
    this.variant = AppCardVariant.standard,
    this.elevation = AppSpacing.elevation0,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AppCardVariant variant;
  final double elevation;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? AppSpacing.radiusLg;

    switch (variant) {
      case AppCardVariant.goldBanner:
        return _BannerCard(
          onTap: onTap,
          margin: margin,
          padding: padding,
          radius: radius,
          gradient: const LinearGradient(
            colors: [AppColors.goldDark, AppColors.gold, AppColors.goldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: child,
        );

      case AppCardVariant.navyBanner:
        return _BannerCard(
          onTap: onTap,
          margin: margin,
          padding: padding,
          radius: radius,
          gradient: const LinearGradient(
            colors: [AppColors.navy, AppColors.navyMid, AppColors.navyAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: child,
        );

      case AppCardVariant.featured:
        return Container(
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius + 1.5),
            gradient: const LinearGradient(
              colors: [AppColors.gold, AppColors.goldLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(1.5),
          child: _StandardBody(
            onTap: onTap,
            padding: padding,
            radius: radius,
            isDark: isDark,
            elevation: elevation,
            child: child,
          ),
        );

      case AppCardVariant.standard:
        return _StandardBody(
          onTap: onTap,
          padding: padding,
          margin: margin,
          radius: radius,
          isDark: isDark,
          elevation: elevation,
          child: child,
        );
    }
  }
}

class _StandardBody extends StatelessWidget {
  const _StandardBody({
    required this.child,
    required this.isDark,
    required this.radius,
    required this.elevation,
    this.onTap,
    this.padding,
    this.margin,
  });

  final Widget child;
  final bool isDark;
  final double radius;
  final double elevation;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.06 * elevation),
                  blurRadius: elevation * 3,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.child,
    required this.gradient,
    required this.radius,
    this.onTap,
    this.margin,
    this.padding,
  });

  final Widget child;
  final Gradient gradient;
  final double radius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: gradient,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Stat card — for dashboard metrics (giving total, sermon count, etc.)
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    required this.label,
    required this.value,
    super.key,
    this.icon,
    this.trend,
    this.trendPositive = true,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;

  /// Optional trend label — e.g. "+12% this month"
  final String? trend;
  final bool trendPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: AppSpacing.iconSm,
                    color: AppColors.gold,
                  ),
                ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs + 2,
                    vertical: AppSpacing.xxxs,
                  ),
                  decoration: BoxDecoration(
                    color: trendPositive
                        ? AppColors.successContainer
                        : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                  child: Text(
                    trend!,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color:
                          trendPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxs),
          Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header used in homefeed / dashboard.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxxs),
                  Text(
                    subtitle!,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              child: Text(
                actionLabel!,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
