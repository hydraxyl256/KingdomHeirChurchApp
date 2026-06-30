import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

/// Button variants available in Kingdom Heir.
enum AppButtonVariant {
  /// Gold-filled (primary CTA).
  filled,

  /// Transparent with gold border.
  outlined,

  /// Transparent with gold text, no border.
  text,

  /// Navy-filled (secondary / destructive actions).
  navy,
}

/// Production-grade button component with loading state, icon support,
/// width control, and all [AppButtonVariant] styles.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;

  /// null = full-width (default). Pass a fixed value for compact buttons.
  final double? width;
  final double height;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null || isLoading;

    final effectiveStyle = textStyle ??
        AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        );

    final label_ = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _foreground(scheme),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: AppSpacing.iconSm, color: _foreground(scheme),),
                  const SizedBox(width: AppSpacing.sm),
                  // Wrap the label in Flexible + ellipsis so an
                  // icon+label row never overflows a narrow parent.
                  // Before this change a fixed-width AppButton (e.g.
                  // the secondary "History" CTA inside
                  // `KingdomGivingCard`) overflowed its inner Row by
                  // ~40 px on a 360 dp phone and threw
                  // "A RenderFlex overflowed by N pixels on the right".
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style:
                          effectiveStyle?.copyWith(color: _foreground(scheme)),
                    ),
                  ),
                ],
              )
            : Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: effectiveStyle?.copyWith(color: _foreground(scheme)),);

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      side: variant == AppButtonVariant.outlined
          ? BorderSide(
              color: isDisabled
                  ? AppColors.gold.withValues(alpha: 0.38)
                  : AppColors.gold,
              width: 1.5,
            )
          : BorderSide.none,
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: switch (variant) {
        AppButtonVariant.filled || AppButtonVariant.navy => ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled
                  ? _background(scheme).withValues(alpha: 0.38)
                  : _background(scheme),
              foregroundColor: _foreground(scheme),
              elevation: variant == AppButtonVariant.filled
                  ? AppSpacing.elevation1
                  : 0,
              shadowColor: variant == AppButtonVariant.filled
                  ? AppColors.gold.withValues(alpha: 0.35)
                  : Colors.transparent,
              shape: shape,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              minimumSize: Size(width ?? double.infinity, height),
            ),
            child: label_,
          ),
        AppButtonVariant.outlined => OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: shape.side,
              shape: shape,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              minimumSize: Size(width ?? double.infinity, height),
            ),
            child: label_,
          ),
        AppButtonVariant.text => TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
              shape: shape,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              minimumSize: Size(width ?? 0, height),
            ),
            child: label_,
          ),
      },
    );
  }

  Color _background(ColorScheme scheme) => switch (variant) {
        AppButtonVariant.filled => AppColors.gold,
        AppButtonVariant.navy => AppColors.navy,
        _ => Colors.transparent,
      };

  Color _foreground(ColorScheme scheme) => switch (variant) {
        AppButtonVariant.filled => AppColors.ink,
        AppButtonVariant.navy => AppColors.white,
        AppButtonVariant.outlined || AppButtonVariant.text => AppColors.gold,
      };
}

/// Small pill badge button — e.g. "LIVE" badge, category filter.
class AppPillButton extends StatelessWidget {
  const AppPillButton({
    required this.label,
    super.key,
    this.onPressed,
    this.isSelected = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.ink : AppColors.gold,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: isSelected ? AppColors.ink : AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold icon button with circular background — used in quick-action grids.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.gold.withValues(alpha: 0.12);
    final fg = foregroundColor ?? AppColors.gold;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: fg, size: AppSpacing.iconMd),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
