import 'package:equatable/equatable.dart';

class Kid extends Equatable {
  const Kid({
    required this.id,
    required this.parentId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gradeClass,
    this.medicalNotes,
  });

  factory Kid.fromJson(Map<String, dynamic> json) {
    return Kid(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      medicalNotes: json['medical_notes'] as String?,
      gradeClass: json['grade_class'] as String,
    );
  }

  final String id;
  final String parentId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? medicalNotes;
  final String gradeClass;

  String get fullName => '$firstName $lastName';
  int get age => DateTime.now().year - dateOfBirth.year;

  @override
  List<Object?> get props => [
        id,
        parentId,
        firstName,
        lastName,
        dateOfBirth,
        medicalNotes,
        gradeClass,
      ];
}

class KidsSession extends Equatable {
  const KidsSession({
    required this.id,
    required this.name,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory KidsSession.fromJson(Map<String, dynamic> json) {
    return KidsSession(
      id: json['id'] as String,
      name: json['name'] as String,
      sessionDate: DateTime.parse(json['session_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  final String id;
  final String name;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final bool isActive;

  @override
  List<Object?> get props =>
      [id, name, sessionDate, startTime, endTime, isActive];
}

class KidsCheckin extends Equatable {
  const KidsCheckin({
    required this.id,
    required this.kidId,
    required this.sessionId,
    required this.checkedInBy,
    required this.safetyCode,
    required this.checkedInAt,
    this.checkedOutBy,
    this.checkedOutAt,
  });

  factory KidsCheckin.fromJson(Map<String, dynamic> json) {
    return KidsCheckin(
      id: json['id'] as String,
      kidId: json['kid_id'] as String,
      sessionId: json['session_id'] as String,
      checkedInBy: json['checked_in_by'] as String,
      checkedOutBy: json['checked_out_by'] as String?,
      safetyCode: json['safety_code'] as String,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      checkedOutAt: json['checked_out_at'] != null
          ? DateTime.parse(json['checked_out_at'] as String)
          : null,
    );
  }

  final String id;
  final String kidId;
  final String sessionId;
  final String checkedInBy;
  final String? checkedOutBy;
  final String safetyCode;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;

  bool get isCheckedIn => checkedOutAt == null;

  @override
  List<Object?> get props => [
        id,
        kidId,
        sessionId,
        checkedInBy,
        checkedOutBy,
        safetyCode,
        checkedInAt,
        checkedOutAt,
      ];
}
