import 'package:equatable/equatable.dart';

class VolunteerOpportunity extends Equatable {
  const VolunteerOpportunity({
    required this.id,
    required this.title,
    required this.timeDescription,
    required this.openSlots,
    required this.ministryArea,
    required this.isActive,
  });

  factory VolunteerOpportunity.fromJson(Map<String, dynamic> json) {
    return VolunteerOpportunity(
      id: json['id'] as String,
      title: json['title'] as String,
      timeDescription: json['time_description'] as String,
      openSlots: json['open_slots'] as int,
      ministryArea: json['ministry_area'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  final String id;
  final String title;
  final String timeDescription;
  final int openSlots;
  final String ministryArea;
  final bool isActive;

  @override
  List<Object?> get props =>
      [id, title, timeDescription, openSlots, ministryArea, isActive];
}

class VolunteerApplication extends Equatable {
  const VolunteerApplication({
    required this.id,
    required this.opportunityId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory VolunteerApplication.fromJson(Map<String, dynamic> json) {
    return VolunteerApplication(
      id: json['id'] as String,
      opportunityId: json['opportunity_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String opportunityId;
  final String userId;
  final String status;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, opportunityId, userId, status, createdAt];
}
