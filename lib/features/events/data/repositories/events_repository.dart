import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/events/data/models/event_model.dart';
import 'package:kingdom_heir/features/events/domain/entities/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return SupabaseEventsRepository(supabase.Supabase.instance.client);
});

abstract class EventsRepository {
  /// Fetch all upcoming events (paginated/limited).
  Future<Either<String, List<Event>>> getUpcomingEvents({int limit = 50});

  /// Fetch events for a specific month (for calendar view).
  Future<Either<String, List<Event>>> getEventsByMonth(DateTime month);

  /// Fetch a single event by ID.
  Future<Either<String, Event>> getEventById(String id);

  /// Register/RSVP for an event.
  Future<Either<String, void>> rsvpForEvent({
    required String eventId,
    required RsvpStatus status,
    required int guestCount,
    String? notes,
  });
}

class SupabaseEventsRepository implements EventsRepository {
  SupabaseEventsRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<Either<String, List<Event>>> getUpcomingEvents(
      {int limit = 50,}) async {
    try {
      // Public surface: only show events that have been published by an admin.
      // The `events.status` column defaults to 'draft' (see core_schema.sql),
      // so without this filter the query returns zero rows for non-admins.
      final response = await _client
          .from('events')
          .select()
          .eq('status', 'published')
          .gte('end_at', DateTime.now().toIso8601String())
          .order('start_at', ascending: true)
          .limit(limit);

      final events = (response as List)
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return right(events);
    } catch (e) {
      return left('Failed to load upcoming events: $e');
    }
  }

  @override
  Future<Either<String, List<Event>>> getEventsByMonth(DateTime month) async {
    try {
      final start = DateTime(month.year, month.month);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final response = await _client
          .from('events')
          .select()
          .eq('status', 'published')
          .gte('start_at', start.toIso8601String())
          .lte('start_at', end.toIso8601String())
          .order('start_at', ascending: true);

      final events = (response as List)
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return right(events);
    } catch (e) {
      return left('Failed to load events for the selected month: $e');
    }
  }

  @override
  Future<Either<String, Event>> getEventById(String id) async {
    try {
      final response =
          await _client.from('events').select().eq('id', id).single();

      final event = EventModel.fromJson(response);
      return right(event);
    } catch (e) {
      return left('Failed to load event details: $e');
    }
  }

  @override
  Future<Either<String, void>> rsvpForEvent({
    required String eventId,
    required RsvpStatus status,
    required int guestCount,
    String? notes,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return left('You must be logged in to RSVP.');
      }

      // Upsert the RSVP
      await _client.from('event_rsvps').upsert(
        {
          'event_id': eventId,
          'user_id': user.id,
          'status': status.name,
          'notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'event_id, user_id',
      );

      return right(null);
    } catch (e) {
      return left('Failed to submit RSVP: $e');
    }
  }
}
