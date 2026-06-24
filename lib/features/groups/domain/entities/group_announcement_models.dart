// Kingdom Heir — Group Announcement Models
//
// Pinned/top-of-feed items inside a group chat. Different from NewsArticle
// (church-wide) — these are scoped to one group.

import 'package:equatable/equatable.dart';

/// Announcement posted by a group leader or admin.
class GroupAnnouncement extends Equatable {
  const GroupAnnouncement({
    required this.id,
    required this.groupId,
    required this.authorMemberId,
    required this.authorName,
    required this.body,
    required this.createdAt,
    this.authorAvatarUrl,
    this.pinned = false,
  });

  factory GroupAnnouncement.fromJson(Map<String, dynamic> json) {
    final author =
        (json['group_members'] as Map?)?.cast<String, dynamic>() ?? const {};
    final profile =
        (author['profiles'] as Map?)?.cast<String, dynamic>() ?? const {};
    return GroupAnnouncement(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      authorMemberId: json['author_member_id'] as String,
      authorName: profile['full_name'] as String? ?? 'Leader',
      authorAvatarUrl: profile['avatar_url'] as String?,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      pinned: json['pinned'] as bool? ?? false,
    );
  }

  final String id;
  final String groupId;
  final String authorMemberId;
  final String authorName;
  final String? authorAvatarUrl;
  final String body;
  final DateTime createdAt;
  final bool pinned;

  @override
  List<Object?> get props => [
        id,
        groupId,
        authorMemberId,
        authorName,
        authorAvatarUrl,
        body,
        createdAt,
        pinned,
      ];
}

/// Discussion thread post — long-form, threaded below the live chat.
class GroupDiscussionPost extends Equatable {
  const GroupDiscussionPost({
    required this.id,
    required this.groupId,
    required this.authorMemberId,
    required this.authorName,
    required this.body,
    required this.createdAt,
    this.authorAvatarUrl,
    this.reactionCount = 0,
    this.commentCount = 0,
  });

  factory GroupDiscussionPost.fromJson(Map<String, dynamic> json) {
    final author =
        (json['group_members'] as Map?)?.cast<String, dynamic>() ?? const {};
    final profile =
        (author['profiles'] as Map?)?.cast<String, dynamic>() ?? const {};
    return GroupDiscussionPost(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      authorMemberId: json['author_member_id'] as String,
      authorName: profile['full_name'] as String? ?? 'Member',
      authorAvatarUrl: profile['avatar_url'] as String?,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      reactionCount: json['reaction_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
    );
  }

  final String id;
  final String groupId;
  final String authorMemberId;
  final String authorName;
  final String? authorAvatarUrl;
  final String body;
  final DateTime createdAt;
  final int reactionCount;
  final int commentCount;

  @override
  List<Object?> get props => [
        id,
        groupId,
        authorMemberId,
        authorName,
        authorAvatarUrl,
        body,
        createdAt,
        reactionCount,
        commentCount,
      ];
}
