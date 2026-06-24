// Kingdom Heir — Kingdom Impact (SECTION 6)
//
// THE overflow fix. Four stat tiles that adapt their layout to the screen:
//
//   • xs / sm: 2×2 Wrap grid   (tile width = (W - spacing) / 2)
//   • md:     2×2 Wrap grid
//   • lg+:    4-column Row (IntrinsicHeight + 4× Expanded)
//
// Each tile is an [ImpactStatTile] which uses AnimatedCount for the value,
// wraps the label with `maxLines: 2` + ellipsis, and never depends on
// intrinsic widths of its children.
//
// If [stats] is empty, the section shows the empty state.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/animated_count.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/states/dashboard_empty_state.dart';

class KingdomImpactSection extends StatelessWidget {
  const KingdomImpactSection({
    required this.stats,
    super.key,
    this.onSeeAll,
  });

  final List<ImpactStat> stats;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'Kingdom Impact',
          subtitle: 'Together we are making a difference',
          actionLabel: stats.length > 4 ? 'See all' : null,
          onAction: onSeeAll,
          icon: Icons.public_rounded,
        ),
        if (stats.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: const DashboardEmptyState(
              icon: Icons.public_off_rounded,
              title: 'No impact to report yet',
              body:
                  'Impact stats will appear here once we publish our first quarterly report.',
            ),
          )
        else
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
                final isWide = band.isAtLeast(LayoutBand.lg);

                if (isWide) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          if (i > 0) SizedBox(width: insets.md),
                          Expanded(
                            child: ImpactStatTile(stat: stats[i])
                                .animate()
                                .fadeIn(
                                  duration: AppMotion.standard,
                                  delay: Duration(milliseconds: 80 * i),
                                  curve: AppMotion.decelerate,
                                )
                                .slideY(
                                  begin: 0.15,
                                  end: 0,
                                  duration: AppMotion.standard,
                                  delay: Duration(milliseconds: 80 * i),
                                ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final spacing = insets.md;
                final tileWidth = (constraints.maxWidth - spacing) / 2;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: List.generate(stats.length, (i) {
                    final stat = stats[i];
                    return SizedBox(
                      width: tileWidth,
                      child: ImpactStatTile(stat: stat)
                          .animate()
                          .fadeIn(
                            duration: AppMotion.standard,
                            delay: Duration(milliseconds: 80 * i),
                            curve: AppMotion.decelerate,
                          )
                          .slideY(
                            begin: 0.15,
                            end: 0,
                            duration: AppMotion.standard,
                            delay: Duration(milliseconds: 80 * i),
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
}

class ImpactStatTile extends StatelessWidget {
  const ImpactStatTile({required this.stat, super.key});
  final ImpactStat stat;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    final (icon, accent) = _visual(stat.iconKey);

    return Container(
      padding: EdgeInsets.all(insets.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              if (stat.deltaLabel != null)
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: insets.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      stat.deltaLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: insets.sm),
          AnimatedCount(
            value: stat.value,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _visual(String key) => switch (key) {
        'favorite' => (Icons.favorite_rounded, AppColors.goldDark),
        'public' => (Icons.public_rounded, AppColors.tertiary),
        'flight_takeoff' => (Icons.flight_takeoff_rounded, AppColors.success),
        'auto_awesome' => (Icons.auto_awesome_rounded, AppColors.gold),
        _ => (Icons.insights_rounded, AppColors.goldDark),
      };
}
