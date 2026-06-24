// Kingdom Heir — Upcoming Events (SECTION 9)
//
// A horizontal carousel on phones, a 3-column Wrap on tablets/desktop.
// Each card shows:
//   • Date block (month / day) on the left
//   • Title + location + relative time on the right
//   • Tinted accent strip matching the event's accent index
//
// Card width is derived from LayoutBuilder — never a fixed dp.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/states/dashboard_empty_state.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({
    required this.events,
    super.key,
    this.onSeeAll,
    this.onEventTap,
  });

  final List<UpcomingEvent> events;
  final VoidCallback? onSeeAll;
  final void Function(UpcomingEvent)? onEventTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'Upcoming events',
          subtitle: 'Worship, study, and fellowship',
          actionLabel: events.length > 3 ? 'See all' : null,
          onAction: onSeeAll,
          icon: Icons.calendar_month_rounded,
        ),
        if (events.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: const DashboardEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'No upcoming events',
              body:
                  "Check back soon — events will appear here as they're scheduled.",
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final band = layoutBandFromWidth(constraints.maxWidth);
              final isMultiColumn = band.isAtLeast(LayoutBand.xl);

              if (isMultiColumn) {
                final spacing = insets.md;
                final tileWidth = (constraints.maxWidth - spacing * 2) / 3;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: insets.lg),
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: List.generate(events.length, (i) {
                      return SizedBox(
                        width: tileWidth,
                        child: _EventCard(
                          event: events[i],
                          onTap: () => onEventTap?.call(events[i]),
                        )
                            .animate()
                            .fadeIn(
                              duration: AppMotion.standard,
                              delay: Duration(milliseconds: 50 * i),
                              curve: AppMotion.decelerate,
                            )
                            .slideX(begin: 0.1, end: 0),
                      );
                    }),
                  ),
                );
              }

              final factor = switch (band) {
                LayoutBand.xs => 0.82,
                LayoutBand.sm => 0.74,
                LayoutBand.md => 0.62,
                LayoutBand.lg => 0.50,
                _ => 0.50,
              };
              final cardWidth = constraints.maxWidth * factor;

              return SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: insets.lg),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => SizedBox(width: insets.md),
                  itemBuilder: (context, i) {
                    return SizedBox(
                      width: cardWidth,
                      child: _EventCard(
                        event: events[i],
                        onTap: () => onEventTap?.call(events[i]),
                      )
                          .animate()
                          .fadeIn(
                            duration: AppMotion.standard,
                            delay: Duration(milliseconds: 50 * i),
                            curve: AppMotion.decelerate,
                          )
                          .slideX(begin: 0.12, end: 0),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.onTap});
  final UpcomingEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    final accent = _accentFor(event.accentIndex);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border:
                Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.MMM().format(event.startsAt).toUpperCase(),
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.warmWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(height: insets.xxxs),
                    Text(
                      DateFormat.d().format(event.startsAt),
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.warmWhite,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(insets.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _iconFor(event.iconKey),
                            size: 12,
                            color: accent,
                          ),
                          SizedBox(width: insets.xxs),
                          Expanded(
                            child: Text(
                              event.locationLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.textTheme.labelSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: insets.xs),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: insets.xxs),
                      Text(
                        _relative(event.startsAt),
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _accentFor(int index) {
    const palette = [
      AppColors.goldDark,
      AppColors.tertiary,
      AppColors.success,
      AppColors.navyAccent,
    ];
    return palette[index % palette.length];
  }

  static IconData _iconFor(String key) => switch (key) {
        'church' => Icons.church_rounded,
        'groups' => Icons.groups_rounded,
        'volunteer_activism' => Icons.volunteer_activism_rounded,
        'favorite' => Icons.favorite_rounded,
        _ => Icons.event_rounded,
      };

  static String _relative(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Past';
    if (diff.inDays >= 1) {
      return 'in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
    }
    if (diff.inHours >= 1) {
      return 'in ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}';
    }
    if (diff.inMinutes >= 1) return 'in ${diff.inMinutes} min';
    return 'soon';
  }
}
