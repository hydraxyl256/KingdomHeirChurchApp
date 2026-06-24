// Kingdom Heir — Home Hero (SECTION 1)
//
// Glassy navy/gold shell that greets the user, shows their total
// group counts, and surfaces the Quick Actions row. Designed to land
// first on the Community Home screen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/glass_card.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    required this.displayName,
    required this.totalGroups,
    required this.activeGroups,
    this.prayerCount = 0,
    super.key,
  });

  final String displayName;
  final int totalGroups;
  final int activeGroups;
  final int prayerCount;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final greeting = _greeting();

    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.lg, insets.lg, insets.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow =
              layoutBandFromWidth(constraints.maxWidth).isAtMost(LayoutBand.sm);

          final stats = Wrap(
            spacing: insets.md,
            runSpacing: insets.sm,
            children: [
              _Stat(
                  label: 'My groups',
                  value: '$activeGroups',
                  icon: Icons.groups_2_rounded,),
              _Stat(
                  label: 'Total',
                  value: '$totalGroups',
                  icon: Icons.public_rounded,),
              _Stat(
                  label: 'Praying',
                  value: '$prayerCount',
                  icon: Icons.volunteer_activism_rounded,),
            ],
          );

          return GlassCard(
            padding: EdgeInsets.all(insets.lg),
            onTap: () => _openDiscover(context),
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.gold.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                      SizedBox(height: insets.xxs),
                      Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.headlineSmall?.copyWith(
                          color: AppColors.warmWhite,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: insets.xs),
                      Text(
                        'Your kingdom family, gathered.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.warmWhite.withValues(alpha: 0.78),
                        ),
                      ),
                      SizedBox(height: insets.md),
                      stats,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              greeting,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.textTheme.labelMedium?.copyWith(
                                color: AppColors.gold.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                              ),
                            ),
                            SizedBox(height: insets.xs),
                            Text(
                              displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppColors.warmWhite,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: insets.xs),
                            Text(
                              'Your kingdom family, gathered.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.textTheme.bodyMedium?.copyWith(
                                color:
                                    AppColors.warmWhite.withValues(alpha: 0.78),
                              ),
                            ),
                            SizedBox(height: insets.md),
                            stats,
                          ],
                        ),
                      ),
                    ],
                  ),
          )
              .animate()
              .fadeIn(
                  duration: AppMotion.emphasized, curve: AppMotion.decelerate,)
              .slideY(begin: 0.06, end: 0, duration: AppMotion.emphasized);
        },
      ),
    );
  }

  void _openDiscover(BuildContext context) {
    // Detail card is decorative — full discovery lives behind a chip.
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'GOOD NIGHT';
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    if (hour < 21) return 'GOOD EVENING';
    return 'GOOD NIGHT';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: insets.sm,
        vertical: insets.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.gold, size: 14),
          const SizedBox(width: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.warmWhite.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
