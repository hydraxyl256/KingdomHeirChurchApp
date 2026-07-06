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
//
// Safety: card-level entrance animation is a self-contained
// `TweenAnimationBuilder`, not `flutter_animate`'s `.animate().fadeIn()
// .slideY()` chain. `flutter_animate` mounts an internal `Builder` that
// interacted badly with `SliverToBoxAdapter`'s measurement, producing a
// `RenderBox.size` null-deref in the More screen.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
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
      // Self-contained fade-in. flutter_animate's internal Builder
      // crashed inside SliverToBoxAdapter — avoided here.
      child: _FamilyEventsFadeIn(
        child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.06),
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
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.celebration_rounded,
                    color: theme.colorScheme.tertiary,
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
                      color: theme.colorScheme.tertiary,
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
                gradient: LinearGradient(
                  colors: theme.brightness == Brightness.dark
                      ? [AppColors.navyMid, AppColors.navyLight]
                      : [
                          theme.colorScheme.tertiaryContainer,
                          theme.colorScheme.secondaryContainer,
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
                      color: theme.brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.event_available_rounded,
                      color: theme.colorScheme.tertiary,
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
                            color: theme.colorScheme.tertiary,
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
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          data.nextEventWhen,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        icon: Icons.today_rounded,
                        label: 'This week',
                        value: '${data.thisWeekCount}',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        icon: Icons.child_care_rounded,
                        label: 'Kids today',
                        value: '${data.kidsCheckedInToday}',
                        color: theme.colorScheme.error,
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
      ),
      ),
    );
  }
}

/// Self-contained opacity + Y-translate fade-in for the Family & Events
/// card. Replaces flutter_animate's chain so SliverToBoxAdapter
/// measurement never sees an internal Builder.
class _FamilyEventsFadeIn extends StatelessWidget {
  const _FamilyEventsFadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: animatedChild,
          ),
        );
      },
      child: child,
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
