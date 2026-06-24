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
    super.tags,
    super.userRsvp,
    super.reminderSet,
    super.latitude,
    super.longitude,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: _categoryFromString(json['category'] as String? ?? 'other'),
      status: _statusFromString(json['status'] as String? ?? 'upcoming'),
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.tryParse(json['end_at'] as String? ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      location: json['location'] as String? ?? 'TBD',
      isOnline: json['is_online'] as bool? ?? false,
      isFree: json['is_free'] as bool? ?? true,
      rsvpCount: json['rsvp_count'] as int? ?? 0,
      maxAttendees: json['max_attendees'] as int? ?? 0,
      createdBy: json['created_by'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'GHS',
      coverImageUrl: json['cover_image_url'] as String?,
      meetingLink: json['meeting_link'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      userRsvp: _rsvpFromString(json['user_rsvp'] as String?),
      reminderSet: json['reminder_set'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'status': status.name,
        'starts_at': startsAt.toIso8601String(),
        'end_at': endsAt.toIso8601String(),
        'location': location,
        'is_online': isOnline,
        'is_free': isFree,
        'price': price,
        'currency': currency,
        'cover_image_url': coverImageUrl,
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
