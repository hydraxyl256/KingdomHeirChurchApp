import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/features/events/data/models/event_model.dart';

void main() {
  group('EventModel production-safe parsing', () {
    test('uses presentation defaults for missing optional data', () {
      final event = EventModel.fromJson(const {
        'id': 'dcf4339e-9f41-4f3a-8d53-47c7c67fb320',
        'title': 'Sunday Service',
        'start_at': '2026-07-26T09:00:00Z',
        'description': null,
        'location_name': null,
        'speaker': null,
        'image_url': null,
        'end_at': null,
      });

      expect(event.description, 'More details will be shared soon.');
      expect(event.location, 'Location to be announced');
      expect(event.speaker, 'Guest Speaker');
      expect(event.coverImageUrl, isNull);
      expect(event.endsAt, event.startsAt.add(const Duration(hours: 1)));
    });

    test('ignores malformed optional values without crashing', () {
      final event = EventModel.fromJson(const {
        'id': 'dcf4339e-9f41-4f3a-8d53-47c7c67fb320',
        'title': 'Prayer Night',
        'start_at': '2026-07-26T09:00:00Z',
        'is_online': 'not-a-boolean',
        'rsvp_count': 'unknown',
        'price': 'not-a-number',
        'tags': ['prayer', 42, null, '  worship  '],
        'image_url': 404,
      });

      expect(event.isOnline, isFalse);
      expect(event.rsvpCount, 0);
      expect(event.tags, ['prayer', 'worship']);
      expect(event.coverImageUrl, isNull);
    });

    test('rejects records missing a required identifier, title, or start time', () {
      expect(
        () => EventModel.fromJson(const {
          'title': 'Sunday Service',
          'start_at': '2026-07-26T09:00:00Z',
        }),
        throwsFormatException,
      );
      expect(
        () => EventModel.fromJson(const {
          'id': 'dcf4339e-9f41-4f3a-8d53-47c7c67fb320',
          'start_at': '2026-07-26T09:00:00Z',
        }),
        throwsFormatException,
      );
      expect(
        () => EventModel.fromJson(const {
          'id': 'dcf4339e-9f41-4f3a-8d53-47c7c67fb320',
          'title': 'Sunday Service',
          'start_at': 'not-a-date',
        }),
        throwsFormatException,
      );
    });
  });
}
