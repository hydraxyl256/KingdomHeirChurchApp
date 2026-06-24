// Kingdom Heir — Quick Actions (SECTION 4)
//
// A responsive grid of 8 actions. Column count adapts to the layout band:
//   • xs / sm: 4 columns  → 8 tiles in 2 rows
//   • md:     4 columns  → 8 tiles in 2 rows
//   • lg:     6 columns  → 8 tiles filling 2 rows
//   • xl+:    8 columns  → 8 tiles in 1 row
//
// Each tile is a `Wrap`-compatible SizedBox — width is computed from the
// LayoutBuilder so it never overflows. Icon background is gold-tinted; the
// label uses Inter with `maxLines: 2` + ellipsis.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    required this.actions,
    super.key,
    this.onActionTap,
  });

  final List<QuickAction> actions;
  final void Function(QuickAction)? onActionTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResponsiveSectionHeader(
          title: 'Quick actions',
          subtitle: 'Jump straight to what matters',
          icon: Icons.bolt_rounded,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            insets.lg,
            insets.xs,
            insets.lg,
            insets.xl,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final band = layoutBandFromWidth(constraints.maxWidth);
              final columns = _columns(band);
              final spacing = insets.sm;
              final tileWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              final tileHeight = band.isAtLeast(LayoutBand.lg)
                  ? 92.0
                  : (tileWidth * 0.78).clamp(72.0, 96.0);

              return Wrap(
                spacing: spacing,
                runSpacing: insets.md,
                children: List.generate(actions.length, (i) {
                  final action = actions[i];
                  return SizedBox(
                    width: tileWidth,
                    height: tileHeight,
                    child: _QuickActionTile(
                      action: action,
                      onTap: () => onActionTap?.call(action),
                    )
                        .animate()
                        .fadeIn(
                          duration: AppMotion.standard,
                          delay: Duration(milliseconds: 40 * i),
                          curve: AppMotion.decelerate,
                        )
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1, 1),
                          duration: AppMotion.standard,
                          delay: Duration(milliseconds: 40 * i),
                          curve: AppMotion.overshoot,
                        ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  static int _columns(LayoutBand band) => switch (band) {
        LayoutBand.xs => 4,
        LayoutBand.sm => 4,
        LayoutBand.md => 4,
        LayoutBand.lg => 6,
        LayoutBand.xl => 8,
        LayoutBand.xxl => 8,
      };
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, this.onTap});
  final QuickAction action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    final (icon, accent) = _visual(action);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
          padding: EdgeInsets.all(insets.xs),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final iconBoxSize = constraints.maxHeight * 0.5;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(icon, color: accent, size: iconBoxSize * 0.55),
                  ),
                  SizedBox(height: insets.xs),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  (IconData, Color) _visual(QuickAction a) => switch (a) {
        QuickAction.pray => (
            Icons.volunteer_activism_rounded,
            AppColors.goldDark
          ),
        QuickAction.give => (Icons.favorite_rounded, AppColors.gold),
        QuickAction.watch => (
            Icons.play_circle_outline_rounded,
            AppColors.tertiary
          ),
        QuickAction.events => (Icons.event_rounded, AppColors.success),
        QuickAction.groups => (Icons.groups_rounded, AppColors.navyAccent),
        QuickAction.bible => (Icons.menu_book_rounded, AppColors.goldDark),
        QuickAction.testimonies => (Icons.format_quote_rounded, AppColors.gold),
        QuickAction.serve => (Icons.handshake_rounded, AppColors.tertiary),
      };
}
