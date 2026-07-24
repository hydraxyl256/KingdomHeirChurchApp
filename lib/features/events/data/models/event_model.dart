import 'package:kingdom_heir/features/events/domain/entities/event.dart';

/// Data model that maps Supabase JSON ↔ [Event] domain entity.
class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.status,
    required super.startsAt,
    required super.endsAt,
    required super.location,
    required super.isOnline,
    required super.isFree,
    required super.rsvpCount,
    required super.maxAttendees,
    required super.createdBy,
    super.price,
    super.currency,
    super.coverImageUrl,
    super.meetingLink,
    super.speaker,
    super.tags,
    super.userRsvp,
    super.reminderSet,
    super.latitude,
    super.longitude,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final startsAt = _requiredDateTime(json, 'start_at');

    return EventModel(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      description: _stringOr(
        json['description'],
        'More details will be shared soon.',
      ),
      category: _categoryFromString(_nullableString(json['category']) ?? 'other'),
      status: _statusFromString(_nullableString(json['status']) ?? 'upcoming'),
      startsAt: startsAt,
      endsAt: _tryDateTime(json['end_at']) ??
          startsAt.add(const Duration(hours: 1)),
      location: _stringOr(json['location_name'], 'Location to be announced'),
      isOnline: _boolOr(json['is_online'], false),
      isFree: _boolOr(json['is_free'], true),
      rsvpCount: _intOr(json['rsvp_count'], 0),
      maxAttendees: _intOr(json['max_attendees'], 0),
      createdBy: _nullableString(json['created_by']) ?? '',
      price: _nullableDouble(json['price']),
      currency: _stringOr(json['currency'], 'GHS'),
      coverImageUrl: _nullableString(json['image_url']),
      meetingLink: _nullableString(json['meeting_link']),
      speaker: _stringOr(json['speaker'], 'Guest Speaker'),
      tags: _stringList(json['tags']),
      userRsvp: _rsvpFromString(_nullableString(json['user_rsvp'])),
      reminderSet: _boolOr(json['reminder_set'], false),
      latitude: _nullableDouble(json['latitude']),
      longitude: _nullableDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'status': status.name,
        'start_at': startsAt.toIso8601String(),
        'end_at': endsAt.toIso8601String(),
        'location_name': location,
        'is_online': isOnline,
        'is_free': isFree,
        'price': price,
        'currency': currency,
        'image_url': coverImageUrl,
        'meeting_link': meetingLink,
        'tags': tags,
        'max_attendees': maxAttendees,
      };

  static EventCategory _categoryFromString(String s) {
    return EventCategory.values.firstWhere(
      (e) => e.name == s,
      orElse: () => EventCategory.other,
    );
  }

  static DateTime _requiredDateTime(Map<String, dynamic> json, String key) {
    final raw = _nullableString(json[key]);
    if (raw == null) {
      throw FormatException('Event payload is missing required "$key".');
    }

    final value = DateTime.tryParse(raw);
    if (value == null) {
      throw FormatException('Event payload has an invalid "$key": $raw');
    }
    return value;
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = _nullableString(json[key]);
    if (value == null) {
      throw FormatException('Event payload is missing required "$key".');
    }
    return value;
  }

  static String? _nullableString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _stringOr(Object? value, String fallback) =>
      _nullableString(value) ?? fallback;

  static DateTime? _tryDateTime(Object? value) {
    final raw = _nullableString(value);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  static bool _boolOr(Object? value, bool fallback) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return fallback;
  }

  static int _intOr(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double? _nullableDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static EventStatus _statusFromString(String s) {
    return EventStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => EventStatus.upcoming,
    );
  }

  static RsvpStatus _rsvpFromString(String? s) {
    if (s == null) return RsvpStatus.none;
    return RsvpStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => RsvpStatus.none,
    );
  }
}
