// Kingdom Heir — Group Member Models
//
// People inside a community group. GroupMember is the canonical record.
// GroupLeaderProfile is the enriched "public face" shown on the Detail
// screen's leader card. GroupRole mirrors the existing DB enum.

import 'package:equatable/equatable.dart';

/// Role of a user inside a single group.
enum GroupRole {
  leader,
  admin,
  member,
  pending;

  String get label => switch (this) {
        GroupRole.leader => 'Leader',
        GroupRole.admin => 'Admin',
        GroupRole.member => 'Member',
        GroupRole.pending => 'Pending',
      };

  static GroupRole parse(String? raw) => switch (raw) {
        'LEADER' => GroupRole.leader,
        'ADMIN' => GroupRole.admin,
        'MEMBER' => GroupRole.member,
        'PENDING' => GroupRole.pending,
        _ => GroupRole.member,
      };
}

/// A person who belongs to a group.
class GroupMember extends Equatable {
  const GroupMember({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.role,
    required this.joinedAt,
    this.avatarUrl,
    this.lastActiveAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return GroupMember(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: profile?['full_name'] as String? ?? 'Member',
      avatarUrl: profile?['avatar_url'] as String?,
      role: GroupRole.parse(json['role'] as String?),
      joinedAt: DateTime.tryParse(json['joined_at'] as String? ?? '') ??
          DateTime.now(),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.tryParse(json['last_active_at'] as String)
          : null,
    );
  }

  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final GroupRole role;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;

  bool get isLeader => role == GroupRole.leader || role == GroupRole.admin;

  @override
  List<Object?> get props =>
      [id, userId, displayName, avatarUrl, role, joinedAt, lastActiveAt];
}

/// The leader card displayed at the top of the Detail screen.
class GroupLeaderProfile extends Equatable {
  const GroupLeaderProfile({
    required this.member,
    this.bio,
    this.yearsInRole = 0,
    this.languages = const [],
    this.prayerCount = 0,
  });

  factory GroupLeaderProfile.fromJson(Map<String, dynamic> json) {
    final member = GroupMember.fromJson(
      (json['member'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    return GroupLeaderProfile(
      member: member,
      bio: json['bio'] as String?,
      yearsInRole: json['years_in_role'] as int? ?? 0,
      languages: ((json['languages'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      prayerCount: json['prayer_count'] as int? ?? 0,
    );
  }

  final GroupMember member;
  final String? bio;
  final int yearsInRole;
  final List<String> languages;
  final int prayerCount;

  @override
  List<Object?> get props => [member, bio, yearsInRole, languages, prayerCount];
}

/// Pending join request — surfaced in the leader dashboard.
class PendingJoinRequest extends Equatable {
  const PendingJoinRequest({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.requestedAt,
    this.avatarUrl,
    this.note,
  });

  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final DateTime requestedAt;
  final String? note;

  @override
  List<Object?> get props =>
      [id, userId, displayName, avatarUrl, requestedAt, note];
}
