// Kingdom Heir — Group Event Models
//
// Events scoped to a single community group (study nights, outreach,
// socials, etc). Distinct from the global Events feature which is
// church-wide.

import 'package:equatable/equatable.dart';

import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';

/// A scheduled event hosted inside a group.
class GroupEvent extends Equatable {
  const GroupEvent({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.location,
    required this.meetingType,
    this.endsAt,
    this.rsvpCount = 0,
    this.coverUrl,
  });

  factory GroupEvent.fromJson(Map<String, dynamic> json) {
    final meetingType = switch (json['meeting_type'] as String?) {
      'ONLINE' => GroupMeetingType.online,
      'HYBRID' => GroupMeetingType.hybrid,
      _ => GroupMeetingType.physical,
    };
    return GroupEvent(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: json['ends_at'] != null
          ? DateTime.tryParse(json['ends_at'] as String)
          : null,
      location: json['location'] as String? ?? '',
      meetingType: meetingType,
      rsvpCount: json['rsvp_count'] as int? ?? 0,
      coverUrl: json['cover_url'] as String?,
    );
  }

  final String id;
  final String groupId;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String location;
  final GroupMeetingType meetingType;
  final int rsvpCount;
  final String? coverUrl;

  bool get isUpcoming => startsAt.isAfter(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        groupId,
        title,
        description,
        startsAt,
        endsAt,
        location,
        meetingType,
        rsvpCount,
        coverUrl,
      ];
}

/// Per-user RSVP record — drives "Going" toggles on event cards.
class GroupEventRSVP extends Equatable {
  const GroupEventRSVP({
    required this.eventId,
    required this.userId,
    required this.respondedAt,
  });

  final String eventId;
  final String userId;
  final DateTime respondedAt;

  @override
  List<Object?> get props => [eventId, userId, respondedAt];
}
