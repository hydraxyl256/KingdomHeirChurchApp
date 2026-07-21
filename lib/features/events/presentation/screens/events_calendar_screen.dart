import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/events/domain/entities/event.dart';
import 'package:kingdom_heir/features/events/presentation/providers/events_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsCalendarScreen extends ConsumerStatefulWidget {
  const EventsCalendarScreen({super.key});

  @override
  ConsumerState<EventsCalendarScreen> createState() =>
      _EventsCalendarScreenState();
}

class _EventsCalendarScreenState extends ConsumerState<EventsCalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final focusedDay = ref.watch(calendarFocusedDayProvider);
    final selectedDay = ref.watch(calendarSelectedDayProvider);

    // Watch the monthly events for markers
    final monthlyEventsAsync = ref.watch(monthlyEventsProvider(focusedDay));

    List<Event> getEventsForDay(DateTime day) {
      return monthlyEventsAsync.maybeWhen(
        data: (events) =>
            events.where((e) => isSameDay(e.startsAt, day)).toList(),
        orElse: () => [],
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.eventsCalendar),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Calendar Widget ──────────────────────────────────────────
          ColoredBox(
            color: isDark ? AppColors.navyMid : Colors.white,
            child: TableCalendar<Event>(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              calendarFormat: _format,
              eventLoader: getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selected, focused) {
                ref.read(calendarSelectedDayProvider.notifier).state = selected;
                ref.read(calendarFocusedDayProvider.notifier).state = focused;
              },
              onPageChanged: (focused) {
                ref.read(calendarFocusedDayProvider.notifier).state = focused;
              },
              onFormatChanged: (format) => setState(() => _format = format),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: isDark ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.bold,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonDecoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                titleTextStyle: AppTypography.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: cs.onSurface),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: cs.onSurface),
              ),
            ).animate().fadeIn(),
          ),

          // ── Events List ──────────────────────────────────────────────
          Expanded(
            child: ColoredBox(
              color:
                  isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              child: selectedDay != null
                  ? _EventsForDayList(
                      day: selectedDay,
                      events: getEventsForDay(selectedDay),
                    )
                  : const _AllUpcomingEventsList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.go(RouteNames.events), // Navigate to listing screen
        icon: const Icon(Icons.list_rounded),
        label: Text(AppLocalizations.of(context)!.listView),
        backgroundColor: AppColors.navyAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selected Day View
// ─────────────────────────────────────────────────────────────────────────────

class _EventsForDayList extends StatelessWidget {
  const _EventsForDayList({required this.day, required this.events});
  final DateTime day;
  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.event_busy_rounded,
          title: 'No Events',
          description:
              'There are no events scheduled for ${DateFormat('MMM d, yyyy').format(day)}.',
          isCompact: true,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) => _EventCard(event: events[i], index: i),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming View (Default when no day is selected)
// ─────────────────────────────────────────────────────────────────────────────

class _AllUpcomingEventsList extends ConsumerWidget {
  const _AllUpcomingEventsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingEventsProvider);

    return upcomingAsync.when(
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => const AppShimmerBox(
          height: 100,
          borderRadius: AppSpacing.radiusLg,
        ),
      ),
      error: (err, _) => AppErrorWidget(
        message: err.toString(),
        onRetry: () => ref.invalidate(upcomingEventsProvider),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: AppEmptyState(
              icon: Icons.event_available_rounded,
              title: 'No Upcoming Events',
              description: 'Stay tuned for more updates from the church.',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => _EventCard(event: events[i], index: i),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Event Card Item
// ─────────────────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.index});
  final Event event;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? AppColors.navyMid : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () => context.push('${RouteNames.events}/${event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Box
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldDark, AppColors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM').format(event.startsAt).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      DateFormat('d').format(event.startsAt),
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('h:mm a').format(event.startsAt),
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          event.isOnline
                              ? Icons.videocam_rounded
                              : Icons.location_on_rounded,
                          size: 12,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 60))
        .slideX(begin: 0.05, end: 0);
  }
}
