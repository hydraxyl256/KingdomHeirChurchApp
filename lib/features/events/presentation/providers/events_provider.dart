import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/localization/locale_provider.dart';
import 'package:kingdom_heir/features/events/data/repositories/events_repository.dart';
import 'package:kingdom_heir/features/events/domain/entities/event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Calendar State
// ─────────────────────────────────────────────────────────────────────────────

final calendarFocusedDayProvider =
    StateProvider<DateTime>((ref) => DateTime.now());
final calendarSelectedDayProvider = StateProvider<DateTime?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming Events
// ─────────────────────────────────────────────────────────────────────────────

final upcomingEventsProvider =
    AsyncNotifierProvider<UpcomingEventsNotifier, List<Event>>(
  UpcomingEventsNotifier.new,
);

class UpcomingEventsNotifier extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() async {
    final repo = ref.watch(eventsRepositoryProvider);
    final locale = ref.watch(localeProvider);
    final result =
        await repo.getUpcomingEvents(languageCode: locale.languageCode);

    return result.fold(
      (err) => throw Exception(err),
      (events) => events,
    );
  }

  /// Manually update a specific event's RSVP status in the local cache.
  void updateLocalRsvp(String eventId, RsvpStatus status) {
    state = state.whenData((events) {
      return events.map((e) {
        if (e.id == eventId) {
          // Adjust count purely for optimistic UI (if going from none -> going, +1)
          var newCount = e.rsvpCount;
          if (e.userRsvp != RsvpStatus.going && status == RsvpStatus.going) {
            newCount++;
          } else if (e.userRsvp == RsvpStatus.going &&
              status != RsvpStatus.going) {
            newCount--;
          }
          return e.copyWith(userRsvp: status, rsvpCount: newCount);
        }
        return e;
      }).toList();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar Month Events Cache
// ─────────────────────────────────────────────────────────────────────────────

final monthlyEventsProvider =
    FutureProvider.family<List<Event>, DateTime>((ref, month) async {
  final repo = ref.watch(eventsRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final result =
      await repo.getEventsByMonth(month, languageCode: locale.languageCode);

  return result.fold(
    (err) => throw Exception(err),
    (events) => events,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// RSVP Mutator
// ─────────────────────────────────────────────────────────────────────────────

final rsvpMutationProvider =
    StateNotifierProvider<RsvpMutationNotifier, AsyncValue<void>>((ref) {
  return RsvpMutationNotifier(
    ref.watch(eventsRepositoryProvider),
    ref,
  );
});

class RsvpMutationNotifier extends StateNotifier<AsyncValue<void>> {
  RsvpMutationNotifier(this._repo, this._ref) : super(const AsyncData(null));

  final EventsRepository _repo;
  final Ref _ref;

  Future<void> submitRsvp({
    required String eventId,
    required RsvpStatus status,
    required int guestCount,
    String? notes,
  }) async {
    state = const AsyncLoading();

    final result = await _repo.rsvpForEvent(
      eventId: eventId,
      status: status,
      guestCount: guestCount,
      notes: notes,
    );

    result.fold(
      (err) => state = AsyncError(err, StackTrace.current),
      (_) {
        state = const AsyncData(null);
        // Optimistically update the list
        _ref
            .read(upcomingEventsProvider.notifier)
            .updateLocalRsvp(eventId, status);
        // Note: Full reload of month cache would happen if we invalidate monthlyEventsProvider
      },
    );
  }
}
