// Kingdom Heir — Group Events Screen
//
// Full list of events for one group. Sliver layout:
//
//   • SliverAppBar with the group name
//   • FilterChipsBar — Upcoming / Past / All
//   • SliverList of EventCards
//   • Empty / error states
//
// Reads `groupEventsProvider(groupId)` and applies the active time-window
// filter client-side. Mutations go through `groupMutationsProvider.rsvpEvent`.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/group_detail_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/events/event_card.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/events/event_filter_chips.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class GroupEventsScreen extends ConsumerStatefulWidget {
  const GroupEventsScreen({required this.groupId, super.key});
  final String groupId;

  @override
  ConsumerState<GroupEventsScreen> createState() => _GroupEventsScreenState();
}

class _GroupEventsScreenState extends ConsumerState<GroupEventsScreen> {
  EventFilter _filter = EventFilter.upcoming;
  final Set<String> _goingIds = {};

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(groupEventsProvider(widget.groupId));
    final detailAsync = ref.watch(groupDetailProvider(widget.groupId));
    final insets = Insets.of(context);
    final groupName = detailAsync.valueOrNull?.group.name ?? 'Events';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          '$groupName · Events',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          EventFilterChips(
            selected: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          SizedBox(height: insets.sm),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => AppErrorWidget(
                message: AppLocalizations.of(context)!.couldntLoadEvents,
                onRetry: () =>
                    ref.invalidate(groupEventsProvider(widget.groupId)),
              ),
              data: (events) {
                final filtered = events.where((e) {
                  return switch (_filter) {
                    EventFilter.upcoming => e.isUpcoming,
                    EventFilter.past => !e.isUpcoming,
                    EventFilter.all => true,
                  };
                }).toList()
                  ..sort((a, b) {
                    if (_filter == EventFilter.past) {
                      return b.startsAt.compareTo(a.startsAt);
                    }
                    return a.startsAt.compareTo(b.startsAt);
                  });

                if (filtered.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.event_busy_rounded,
                    title: _filter == EventFilter.upcoming
                        ? 'Nothing on the calendar'
                        : _filter == EventFilter.past
                            ? 'No past events yet'
                            : 'No events scheduled',
                    description: _filter == EventFilter.upcoming
                        ? 'Leaders can schedule meetings, retreats, and socials here.'
                        : 'When events wrap up, you’ll find them here.',
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    insets.lg,
                    0,
                    insets.lg,
                    insets.xxl,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: insets.sm),
                  itemBuilder: (_, i) {
                    final e = filtered[i];
                    final isGoing = _goingIds.contains(e.id);
                    return EventCard(
                      event: e,
                      isGoing: isGoing,
                      onToggleRsvp: () async {
                        setState(() {
                          if (isGoing) {
                            _goingIds.remove(e.id);
                          } else {
                            _goingIds.add(e.id);
                          }
                        });
                        try {
                          await ref.read(groupMutationsProvider).rsvpEvent(
                                eventId: e.id,
                                groupId: widget.groupId,
                                going: !isGoing,
                              );
                        } catch (_) {
                          // Roll back optimistic toggle on failure.
                          if (mounted) {
                            setState(() {
                              if (isGoing) {
                                _goingIds.add(e.id);
                              } else {
                                _goingIds.remove(e.id);
                              }
                            });
                          }
                        }
                      },
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 50 * i),
                          duration: 300.ms,
                        )
                        .slideY(
                          begin: 0.05,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOut,
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
