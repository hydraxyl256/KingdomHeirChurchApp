import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user.
/// Pure Dart — no Flutter, no Supabase imports.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.role,
    this.phone,
    this.bio,
    this.createdAt,
    this.isCovenantSigned = false,
    this.leaderLevel,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final UserRole? role;
  final String? phone;
  final String? bio;
  final DateTime? createdAt;
  final bool isCovenantSigned;
  final LeaderLevel? leaderLevel;

  String get displayName => fullName ?? email.split('@').first;

  bool get isAdmin => role == UserRole.admin;
  bool get isPastor => role == UserRole.pastor;
  bool get isLeader => role == UserRole.groupLeader;

  AppUser copyWith({
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    String? phone,
    String? bio,
    bool? isCovenantSigned,
    LeaderLevel? leaderLevel,
  }) =>
      AppUser(
        id: id,
        email: email,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        phone: phone ?? this.phone,
        bio: bio ?? this.bio,
        createdAt: createdAt,
        isCovenantSigned: isCovenantSigned ?? this.isCovenantSigned,
        leaderLevel: leaderLevel ?? this.leaderLevel,
      );

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        role,
        isCovenantSigned,
        leaderLevel,
      ];
}

enum UserRole {
  member,
  groupLeader,
  volunteer,
  pastor,
  admin;

  String get displayName => switch (this) {
        UserRole.member => 'Member',
        UserRole.groupLeader => 'Group Leader',
        UserRole.volunteer => 'Volunteer',
        UserRole.pastor => 'Pastor',
        UserRole.admin => 'Admin',
      };
}

enum LeaderLevel {
  participant,
  groupLeader,
  trainer,
  regionalLeader;

  String get displayName => switch (this) {
        LeaderLevel.participant => 'Participant',
        LeaderLevel.groupLeader => 'Group Leader',
        LeaderLevel.trainer => 'Trainer',
        LeaderLevel.regionalLeader => 'Regional Leader',
      };
}
