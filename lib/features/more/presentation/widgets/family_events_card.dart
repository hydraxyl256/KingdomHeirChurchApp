// Kingdom Heir — Family & Events Card (SECTION 6)
//
// Premium card summarizing the user's family + event footprint:
//   • Next event label + when
//   • Upcoming / this-week counts
//   • Kids checked in today
//   • Three quick-action tiles (Events / Calendar / Kids)
//
// Visual:
//   • Soft sky-themed card (light) / navy glass (dark)
//   • Stat strip across the top
//   • Three colored action tiles in a `Wrap` so 320 dp phones don't
//     overflow.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';

class FamilyEventsCard extends StatelessWidget {
  const FamilyEventsCard({required this.data, super.key});

  final FamilyEvents data;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.md, insets.lg, insets.lg),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: AppColors.tertiary,
                    size: 18,
                  ),
                ),
                SizedBox(width: insets.sm),
                Expanded(
                  child: Text(
                    'FAMILY & EVENTS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: insets.md),

            // Next event
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(insets.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE0F2FE),
                    Color(0xFFDBEAFE),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.warmWhite,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: AppColors.tertiary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: insets.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'NEXT UP',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.tertiary.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.nextEventLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          data.nextEventWhen,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.navy.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: insets.md),

            // Stats strip — uses Wrap so phone widths never overflow.
            LayoutBuilder(
              builder: (context, constraints) {
                final band = layoutBandFromWidth(constraints.maxWidth);
                final tileWidth = switch (band) {
                  LayoutBand.xs ||
                  LayoutBand.sm ||
                  LayoutBand.md =>
                    (constraints.maxWidth - insets.sm) / 3,
                  _ => (constraints.maxWidth - insets.sm * 2) / 3,
                };
                return Wrap(
                  spacing: insets.sm,
                  runSpacing: insets.sm,
                  children: [
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        icon: Icons.event_note_rounded,
                        label: 'Upcoming',
                        value: '${data.upcomingCount}',
                        color: AppColors.tertiary,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        icon: Icons.today_rounded,
                        label: 'This week',
                        value: '${data.thisWeekCount}',
                        color: AppColors.goldDark,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        icon: Icons.child_care_rounded,
                        label: 'Kids today',
                        value: '${data.kidsCheckedInToday}',
                        color: const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: insets.md),

            // Action tiles
            LayoutBuilder(
              builder: (context, constraints) {
                final band = layoutBandFromWidth(constraints.maxWidth);
                final columns = switch (band) {
                  LayoutBand.xs || LayoutBand.sm => 3,
                  LayoutBand.md => 3,
                  _ => 3,
                };
                final spacing = insets.sm;
                final tileWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: tileWidth,
                      child: _ActionTile(
                        icon: Icons.event_rounded,
                        label: 'Events',
                        onTap: () =>
                            GoRouter.of(context).push(RouteNames.events),
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _ActionTile(
                        icon: Icons.calendar_month_rounded,
                        label: 'Calendar',
                        onTap: () => GoRouter.of(context)
                            .push(RouteNames.eventsCalendar),
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _ActionTile(
                        icon: Icons.child_friendly_rounded,
                        label: 'Kids',
                        onTap: () => GoRouter.of(context).push(RouteNames.kids),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: AppMotion.emphasized, curve: AppMotion.decelerate)
          .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.colorScheme.onSurface, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
