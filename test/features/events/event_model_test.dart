import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/features/events/data/models/event_model.dart';

void main() {
  group('EventModel.fromJson', () {
    test('maps the get_events_localized RPC contract', () {
      final event = EventModel.fromJson(const {
        'id': '1e10e898-d4e0-4a46-9420-b4b526cd08ac',
        'title': 'Sunday Worship Service',
        'description': 'Join us for worship.',
        'category': 'worship',
        'image_url': 'https://example.com/event.jpg',
        'start_at': '2026-08-02T09:00:00.000Z',
        'end_at': '2026-08-02T11:00:00.000Z',
        'is_online': false,
        'location_name': 'Main Sanctuary',
        'meeting_link': null,
        'created_by': null,
        'status': 'published',
        'rsvp_count': 12,
      });

      expect(event.startsAt, DateTime.parse('2026-08-02T09:00:00.000Z'));
      expect(event.endsAt, DateTime.parse('2026-08-02T11:00:00.000Z'));
      expect(event.location, 'Main Sanctuary');
      expect(event.coverImageUrl, 'https://example.com/event.jpg');
      expect(event.isFree, isTrue);
      expect(event.maxAttendees, 0);
    });

    test('reports a missing required start_at field without a cast error', () {
      expect(
        () => EventModel.fromJson(const {
          'id': '1e10e898-d4e0-4a46-9420-b4b526cd08ac',
          'title': 'Invalid event',
        }),
        throwsFormatException,
      );
    });
  });
}
