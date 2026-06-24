// Kingdom Heir — Group Prayer Models
//
// Prayer requests shared inside a group. Distinct from the church-wide
// PrayerFeed in /features/prayer_requests — these are scoped to a group
// and surface inside the group's chat and prayer wall.

import 'package:equatable/equatable.dart';

/// Bucket a prayer request falls into — drives filter chips and icon.
enum PrayerCategory {
  healing,
  family,
  provision,
  guidance,
  thanks,
  other;

  String get label => switch (this) {
        PrayerCategory.healing => 'Healing',
        PrayerCategory.family => 'Family',
        PrayerCategory.provision => 'Provision',
        PrayerCategory.guidance => 'Guidance',
        PrayerCategory.thanks => 'Thanksgiving',
        PrayerCategory.other => 'Other',
      };

  static PrayerCategory parse(String? raw) => switch (raw) {
        'HEALING' => PrayerCategory.healing,
        'FAMILY' => PrayerCategory.family,
        'PROVISION' => PrayerCategory.provision,
        'GUIDANCE' => PrayerCategory.guidance,
        'THANKS' || 'THANKSGIVING' => PrayerCategory.thanks,
        _ => PrayerCategory.other,
      };
}

/// A prayer request posted by a member inside a group.
class GroupPrayerRequest extends Equatable {
  const GroupPrayerRequest({
    required this.id,
    required this.groupId,
    required this.authorMemberId,
    required this.authorName,
    required this.body,
    required this.category,
    required this.createdAt,
    this.authorAvatarUrl,
    this.prayingCount = 0,
    this.hasTestimony = false,
    this.isAnswered = false,
  });

  factory GroupPrayerRequest.fromJson(Map<String, dynamic> json) {
    final author =
        (json['group_members'] as Map?)?.cast<String, dynamic>() ?? const {};
    final profile =
        (author['profiles'] as Map?)?.cast<String, dynamic>() ?? const {};
    return GroupPrayerRequest(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      authorMemberId: json['author_member_id'] as String,
      authorName: profile['full_name'] as String? ?? 'Member',
      authorAvatarUrl: profile['avatar_url'] as String?,
      body: json['body'] as String,
      category: PrayerCategory.parse(json['category'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      prayingCount: json['praying_count'] as int? ?? 0,
      hasTestimony: json['has_testimony'] as bool? ?? false,
      isAnswered: json['is_answered'] as bool? ?? false,
    );
  }

  final String id;
  final String groupId;
  final String authorMemberId;
  final String authorName;
  final String? authorAvatarUrl;
  final String body;
  final PrayerCategory category;
  final DateTime createdAt;
  final int prayingCount;
  final bool hasTestimony;
  final bool isAnswered;

  @override
  List<Object?> get props => [
        id,
        groupId,
        authorMemberId,
        authorName,
        authorAvatarUrl,
        body,
        category,
        createdAt,
        prayingCount,
        hasTestimony,
        isAnswered,
      ];
}
