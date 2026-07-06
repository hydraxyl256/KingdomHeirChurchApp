// Re-exports for the two app-level loading / error widgets.
//
// They are defined in their own files (`app_loading_indicator.dart`,
// `app_error_widget.dart`) but historically callers import this single
// file and rely on `AppEmptyState`, `AppLoadingIndicator`, and
// `AppErrorWidget` all being available. We re-export them here so
// `import '.../app_empty_state.dart';` is enough to get the full
// empty/loading/error set. The `AppEmptyState` API takes
// `icon` + `title` + optional `description` + optional CTA; the
// loading and error widgets wrap that base API.
export 'app_error_widget.dart' show AppErrorWidget;
export 'app_loading_indicator.dart' show AppLoadingIndicator;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';

/// A generic empty state with an icon, title, description, and optional CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.description,
    this.actionLabel,
    this.onAction,
    this.isCompact = false,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Compact variant for list sections (smaller padding).
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? AppSpacing.xl : AppSpacing.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isCompact ? 60 : 80,
              height: isCompact ? 60 : 80,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isCompact ? AppSpacing.iconLg : AppSpacing.iconXl,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
            Text(
              title,
              style: (isCompact
                      ? AppTypography.textTheme.titleSmall
                      : AppTypography.textTheme.titleMedium)
                  ?.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xxl),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 200,
                height: AppSpacing.buttonHeightSm,
              ).animate().fadeIn(delay: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}

// Re-exports for the two app-level loading / error widgets.
//
// They are defined in their own files (`app_loading_indicator.dart`,
// `app_error_widget.dart`) but historically callers import this single
// file and rely on `AppEmptyState`, `AppLoadingIndicator`, and
// `AppErrorWidget` all being available. We re-export them here so
// `import '.../app_empty_state.dart';` is enough to get the full
// empty/loading/error set. The new `AppEmptyState` API takes
// `icon` + `title` + optional `description` + optional CTA; the
// loading and error widgets wrap that base API.
export 'app_error_widget.dart' show AppErrorWidget;
export 'app_loading_indicator.dart' show AppLoadingIndicator;

/// Gold gradient banner for important announcements / live service notice.
class AppGoldBanner extends StatelessWidget {
  const AppGoldBanner({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.action,
    this.onAction,
    this.margin,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.goldDark, AppColors.gold],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.ink, size: AppSpacing.iconLg),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.ink.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(width: AppSpacing.md),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.ink.withValues(alpha: 0.12),
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xxs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              child: Text(
                action!,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A subtle shimmer placeholder used while content loads.
class AppShimmerBox extends StatefulWidget {
  const AppShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  State<AppShimmerBox> createState() => _AppShimmerBoxState();
}

class _AppShimmerBoxState extends State<AppShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.navyLight.withValues(alpha: _anim.value)
              : AppColors.goldContainer.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? AppSpacing.radiusSm,
          ),
        ),
      ),
    );
  }
}
