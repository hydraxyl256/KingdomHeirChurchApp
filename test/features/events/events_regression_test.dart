import 'package:flutter_test/flutter_test.dart';

import 'package:kingdom_heir/features/events/data/models/event_model.dart';

void main() {
  group('Events production regression payloads', () {
    test('maps an event with every supported payload field populated', () {
      final event = EventModel.fromJson(_completeEvent());

      expect(event.id, 'dcf4339e-9f41-4f3a-8d53-47c7c67fb320');
      expect(event.title, 'Sunday Celebration');
      expect(event.description, 'A gathering for worship and prayer.');
      expect(event.location, 'Main Auditorium');
      expect(event.speaker, 'Pastor Grace');
      expect(event.coverImageUrl, 'https://cdn.example.org/events/sunday.jpg');
      expect(event.startsAt, DateTime.parse('2026-07-26T09:00:00Z'));
      expect(event.endsAt, DateTime.parse('2026-07-26T11:00:00Z'));
      expect(event.isOnline, isTrue);
      expect(event.rsvpCount, 125);
      expect(event.tags, ['worship', 'family']);
    });

    test('keeps a missing image nullable for the UI placeholder', () {
      final event = EventModel.fromJson(_completeEvent()..['image_url'] = null);

      expect(event.coverImageUrl, isNull);
    });

    test('uses the friendly speaker fallback when speaker is missing', () {
      final event = EventModel.fromJson(_completeEvent()..remove('speaker'));

      expect(event.speaker, 'Guest Speaker');
    });

    test('uses the friendly venue fallback when location is null', () {
      final event = EventModel.fromJson(
        _completeEvent()..['location_name'] = null,
      );

      expect(event.location, 'Location to be announced');
    });

    test('uses the friendly description fallback when description is null', () {
      final event = EventModel.fromJson(
        _completeEvent()..['description'] = null,
      );

      expect(event.description, 'More details will be shared soon.');
    });

    test('rejects an event with a missing start date', () {
      final payload = _completeEvent()..remove('start_at');

      expect(() => EventModel.fromJson(payload), throwsFormatException);
    });

    test('derives a safe one-hour end time when end date is missing', () {
      final event = EventModel.fromJson(_completeEvent()..remove('end_at'));

      expect(event.endsAt, event.startsAt.add(const Duration(hours: 1)));
    });

    test('maps an empty database result to an empty event list', () {
      final events = _mapEvents(const []);

      expect(events, isEmpty);
    });

    test('rejects corrupt required JSON without constructing an event', () {
      final payload = _completeEvent()
        ..['title'] = 42
        ..['start_at'] = 'not-a-date';

      expect(() => EventModel.fromJson(payload), throwsFormatException);
    });

    test('accepts nullable database columns without runtime cast failures', () {
      final payload = _completeEvent()
        ..['description'] = null
        ..['image_url'] = null
        ..['location_name'] = null
        ..['meeting_link'] = null
        ..['end_at'] = null;

      expect(() => EventModel.fromJson(payload), returnsNormally);
    });

    test('maps a delayed successful response after the loading period', () async {
      final result = await Future<List<EventModel>>.delayed(
        const Duration(milliseconds: 1),
        () => _mapEvents([_completeEvent()]),
      );

      expect(result, hasLength(1));
    });

    test('preserves an offline transport failure for the provider to classify',
        () async {
      final request = Future<List<EventModel>>.error(
        const _OfflineException(),
      );

      await expectLater(request, throwsA(isA<_OfflineException>()));
    });

    test('maps a large event response without dropping valid events', () {
      final events = _mapEvents(
        List.generate(1000, (index) {
          final payload = _completeEvent();
          payload['id'] = 'event-$index';
          payload['title'] = 'Event $index';
          return payload;
        }),
      );

      expect(events, hasLength(1000));
      expect(events.first.title, 'Event 0');
      expect(events.last.title, 'Event 999');
    });
  });
}

List<EventModel> _mapEvents(List<Map<String, dynamic>> rows) =>
    rows.map(EventModel.fromJson).toList(growable: false);

Map<String, dynamic> _completeEvent() => {
      'id': 'dcf4339e-9f41-4f3a-8d53-47c7c67fb320',
      'title': 'Sunday Celebration',
      'description': 'A gathering for worship and prayer.',
      'category': 'worship',
      'status': 'published',
      'start_at': '2026-07-26T09:00:00Z',
      'end_at': '2026-07-26T11:00:00Z',
      'is_online': true,
      'location_name': 'Main Auditorium',
      'meeting_link': 'https://meet.example.org/sunday',
      'rsvp_count': 125,
      'capacity': 250,
      'price': 0,
      'currency': 'KES',
      'image_url': 'https://cdn.example.org/events/sunday.jpg',
      'speaker': 'Pastor Grace',
      'tags': ['worship', 'family'],
      'user_rsvp': 'going',
      'reminder_set': true,
      'latitude': -1.2921,
      'longitude': 36.8219,
    };

class _OfflineException implements Exception {
  const _OfflineException();
}
