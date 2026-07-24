import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum EventCategory {
  worship,
  prayer,
  conference,
  youth,
  outreach,
  kids,
  missions,
  training,
  fellowship,
  other,
}

enum EventStatus { upcoming, ongoing, completed, cancelled }

enum RsvpStatus { going, notGoing, maybe, none }

// ─────────────────────────────────────────────────────────────────────────────
// Event Entity
// ─────────────────────────────────────────────────────────────────────────────

class Event extends Equatable {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.location,
    required this.isOnline,
    required this.isFree,
    required this.rsvpCount,
    required this.maxAttendees,
    required this.createdBy,
    this.price,
    this.currency = 'GHS',
    this.coverImageUrl,
    this.meetingLink,
    this.speaker = 'Guest Speaker',
    this.tags = const [],
    this.userRsvp = RsvpStatus.none,
    this.reminderSet = false,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final EventStatus status;
  final DateTime startsAt;
  final DateTime endsAt;
  final String location;
  final bool isOnline;
  final bool isFree;
  final int rsvpCount;
  final int maxAttendees;
  final String createdBy;
  final double? price;
  final String currency;
  final String? coverImageUrl;
  final String? meetingLink;
  final String speaker;
  final List<String> tags;
  final RsvpStatus userRsvp;
  final bool reminderSet;
  final double? latitude;
  final double? longitude;

  // ── Computed ──────────────────────────────────────────────────────────────

  bool get isSoldOut => maxAttendees > 0 && rsvpCount >= maxAttendees;

  bool get isUpcoming => status == EventStatus.upcoming;

  int get spotsRemaining => maxAttendees > 0 ? maxAttendees - rsvpCount : -1;

  double get attendancePercent =>
      maxAttendees > 0 ? rsvpCount / maxAttendees : 0;

  String get priceLabel =>
      isFree ? 'Free' : '$currency ${price?.toStringAsFixed(2) ?? '0.00'}';

  String get durationLabel {
    final diff = endsAt.difference(startsAt);
    if (diff.inHours >= 1) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
  }

  Event copyWith({
    RsvpStatus? userRsvp,
    int? rsvpCount,
    bool? reminderSet,
  }) =>
      Event(
        id: id,
        title: title,
        description: description,
        category: category,
        status: status,
        startsAt: startsAt,
        endsAt: endsAt,
        location: location,
        isOnline: isOnline,
        isFree: isFree,
        rsvpCount: rsvpCount ?? this.rsvpCount,
        maxAttendees: maxAttendees,
        createdBy: createdBy,
        price: price,
        currency: currency,
        coverImageUrl: coverImageUrl,
        meetingLink: meetingLink,
        speaker: speaker,
        tags: tags,
        userRsvp: userRsvp ?? this.userRsvp,
        reminderSet: reminderSet ?? this.reminderSet,
        latitude: latitude,
        longitude: longitude,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        status,
        startsAt,
        endsAt,
        location,
        isOnline,
        isFree,
        rsvpCount,
        maxAttendees,
        createdBy,
        price,
        currency,
        coverImageUrl,
        meetingLink,
        speaker,
        tags,
        userRsvp,
        reminderSet,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// RSVP Registration Entity
// ─────────────────────────────────────────────────────────────────────────────

class EventRegistration extends Equatable {
  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.registeredAt,
    this.ticketCode,
    this.guestCount = 1,
    this.notes,
    this.attendedAt,
  });

  final String id;
  final String eventId;
  final String userId;
  final RsvpStatus status;
  final DateTime registeredAt;
  final String? ticketCode;
  final int guestCount;
  final String? notes;
  final DateTime? attendedAt;

  bool get hasAttended => attendedAt != null;

  @override
  List<Object?> get props => [
        id,
        eventId,
        userId,
        status,
        registeredAt,
        ticketCode,
        guestCount,
        notes,
        attendedAt,
      ];
}
