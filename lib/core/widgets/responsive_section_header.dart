// Kingdom Heir — ResponsiveSectionHeader
//
// The shared header used by every dashboard section. Unlike the legacy
// AppSectionHeader (which puts the action in a trailing Row that can
// overflow on 320 dp devices), this header uses a `Wrap` so the title
// and action button stack vertically when horizontal space runs out.
//
// Layout rules:
//   • title + (subtitle?) on the first line, occupies available width
//   • optional action label rendered as a real TextButton on the right
//   • if the title + subtitle + action can't fit on one line, the action
//     wraps to the next line and aligns to the start (left)
//
// All padding uses Insets.of(context) so it adapts to layout band.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

class ResponsiveSectionHeader extends StatelessWidget {
  const ResponsiveSectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    final titleStyle = AppTypography.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    );

    final subtitleStyle = AppTypography.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final actionButton = actionLabel == null
        ? const SizedBox.shrink()
        : TextButton.icon(
            onPressed: onAction,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.gold,
            ),
            label: Text(
              actionLabel!,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: insets.xs,
                vertical: insets.xxs,
              ),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );

    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(
            insets.lg,
            insets.xl,
            insets.lg,
            insets.sm,
          ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: insets.sm,
            runSpacing: insets.xs,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: AppColors.gold),
                      SizedBox(width: insets.xs),
                    ],
                    Flexible(
                      child: Text(
                        title,
                        style: titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: insets.xxxs),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      subtitle!,
                      style: subtitleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              actionButton,
            ],
          );
        },
      ),
    );
  }
}
