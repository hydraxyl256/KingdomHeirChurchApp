import 'package:equatable/equatable.dart';

import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';

/// Categories that a community group can belong to.
class GroupCategory extends Equatable {
  const GroupCategory({
    required this.id,
    required this.name,
    this.icon,
  });

  factory GroupCategory.fromJson(Map<String, dynamic> json) {
    return GroupCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );
  }

  final String id;
  final String name;
  final String? icon;

  @override
  List<Object?> get props => [id, name, icon];
}

/// How a group meets (online / in-person / both).
enum GroupMeetingType {
  online,
  physical,
  hybrid;

  String get label => switch (this) {
        GroupMeetingType.online => 'Online',
        GroupMeetingType.physical => 'In Person',
        GroupMeetingType.hybrid => 'Hybrid',
      };
}

/// Life-stage bucket — used to filter suggestions and discovery.
enum GroupLifeStage {
  youth,
  youngAdult,
  family,
  emptyNester,
  seniors,
  allAges;

  String get label => switch (this) {
        GroupLifeStage.youth => 'Youth (13-17)',
        GroupLifeStage.youngAdult => 'Young Adults (18-25)',
        GroupLifeStage.family => 'Families',
        GroupLifeStage.emptyNester => 'Empty Nesters',
        GroupLifeStage.seniors => 'Seniors (60+)',
        GroupLifeStage.allAges => 'All Ages',
      };
}

/// Open to anyone vs gated by leader approval.
enum GroupPrivacy {
  open,
  private;

  String get label => switch (this) {
        GroupPrivacy.open => 'Open',
        GroupPrivacy.private => 'Private',
      };
}

/// Core community group record. The members/details sections expand this
/// record into a richer [GroupDetail] aggregate (see bottom of file).
class CommunityGroup extends Equatable {
  const CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.isPrivate,
    this.categoryId,
    this.categoryName,
    this.meetingTime,
    this.location,
    this.imageUrl,
    this.memberCount = 0,
    this.userRole,
    this.userStatus,
    // ── Optional enriched fields (used by Detail / Home sections) ──
    this.privacy = GroupPrivacy.open,
    this.meetingType = GroupMeetingType.physical,
    this.lifeStage = GroupLifeStage.allAges,
    this.coverUrl,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.weeklyActiveMembers = 0,
  });

  factory CommunityGroup.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    String? role;
    String? status;
    final memberCount = json['member_count'];
    var members = 0;
    if (memberCount is List && memberCount.isNotEmpty) {
      members = (memberCount[0] as Map<String, dynamic>)['count'] as int? ?? 0;
    }

    if (json['group_members'] != null && json['group_members'] is List) {
      final memList = json['group_members'] as List<dynamic>;
      for (final dynamic raw in memList) {
        final m = raw as Map<String, dynamic>;
        if (m['user_id'] == currentUserId) {
          role = m['role'] as String?;
          status = m['status'] as String?;
          break;
        }
      }
    }

    final isPrivate = json['is_private'] as bool? ?? false;
    final meetingType = _parseMeetingType(json['meeting_type'] as String?);
    final lifeStage = _parseLifeStage(json['life_stage'] as String?);

    return CommunityGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      categoryName: (json['group_categories'] as Map<String, dynamic>?)?['name']
          as String?,
      meetingTime: json['meeting_time'] as String?,
      location: json['location'] as String?,
      isPrivate: isPrivate,
      imageUrl: json['image_url'] as String?,
      memberCount: members,
      userRole: role,
      userStatus: status,
      privacy: isPrivate ? GroupPrivacy.private : GroupPrivacy.open,
      meetingType: meetingType,
      lifeStage: lifeStage,
      coverUrl: json['cover_url'] as String? ?? json['image_url'] as String?,
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'] as String)
          : null,
      weeklyActiveMembers: json['weekly_active_members'] as int? ?? 0,
    );
  }

  final String id;
  final String name;
  final String description;
  final String? categoryId;
  final String? categoryName;
  final String? meetingTime;
  final String? location;
  final bool isPrivate;
  final String? imageUrl;

  // Computed/Joined fields
  final int memberCount;
  final String? userRole; // ROLE of the current user (if member)
  final String? userStatus; // STATUS of the current user (if member)

  // Enriched fields (optional — present on Detail / Home views)
  final GroupPrivacy privacy;
  final GroupMeetingType meetingType;
  final GroupLifeStage lifeStage;
  final String? coverUrl;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int weeklyActiveMembers;

  bool get isMember => userStatus == 'ACTIVE';
  bool get isPending => userStatus == 'PENDING';
  bool get isLeader => userRole == 'LEADER' || userRole == 'ADMIN';

  CommunityGroup copyWith({
    String? name,
    String? description,
    String? imageUrl,
    String? coverUrl,
    String? meetingTime,
    String? location,
    GroupPrivacy? privacy,
    GroupMeetingType? meetingType,
    GroupLifeStage? lifeStage,
    int? memberCount,
    int? weeklyActiveMembers,
    String? userRole,
    String? userStatus,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
  }) {
    return CommunityGroup(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId,
      categoryName: categoryName,
      meetingTime: meetingTime ?? this.meetingTime,
      location: location ?? this.location,
      isPrivate: privacy == GroupPrivacy.private,
      imageUrl: imageUrl ?? this.imageUrl,
      memberCount: memberCount ?? this.memberCount,
      userRole: userRole ?? this.userRole,
      userStatus: userStatus ?? this.userStatus,
      privacy: privacy ?? this.privacy,
      meetingType: meetingType ?? this.meetingType,
      lifeStage: lifeStage ?? this.lifeStage,
      coverUrl: coverUrl ?? this.coverUrl,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      weeklyActiveMembers: weeklyActiveMembers ?? this.weeklyActiveMembers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        categoryId,
        categoryName,
        meetingTime,
        location,
        isPrivate,
        imageUrl,
        memberCount,
        userRole,
        userStatus,
        privacy,
        meetingType,
        lifeStage,
        coverUrl,
        lastMessagePreview,
        lastMessageAt,
        weeklyActiveMembers,
      ];
}

GroupMeetingType _parseMeetingType(String? raw) => switch (raw) {
      'ONLINE' => GroupMeetingType.online,
      'PHYSICAL' || 'IN_PERSON' => GroupMeetingType.physical,
      'HYBRID' => GroupMeetingType.hybrid,
      _ => GroupMeetingType.physical,
    };

GroupLifeStage _parseLifeStage(String? raw) => switch (raw) {
      'YOUTH' => GroupLifeStage.youth,
      'YOUNG_ADULT' => GroupLifeStage.youngAdult,
      'FAMILY' => GroupLifeStage.family,
      'EMPTY_NESTER' => GroupLifeStage.emptyNester,
      'SENIORS' => GroupLifeStage.seniors,
      _ => GroupLifeStage.allAges,
    };

/// Single chat message in a group's conversation.
class GroupMessage extends Equatable {
  const GroupMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.senderAvatarUrl,
    this.kind = GroupMessageKind.text,
    this.metadata = const {},
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    final rawKind = json['kind'] as String? ?? 'TEXT';
    final kind = switch (rawKind) {
      'PRAYER' => GroupMessageKind.prayer,
      'SCRIPTURE' => GroupMessageKind.scripture,
      'MEDIA' => GroupMessageKind.media,
      'ANNOUNCEMENT' => GroupMessageKind.announcement,
      _ => GroupMessageKind.text,
    };
    final meta = (json['metadata'] as Map?)?.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ) ??
        const <String, String>{};

    return GroupMessage(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: (json['profiles'] as Map<String, dynamic>?)?['full_name']
              as String? ??
          'User',
      senderAvatarUrl:
          (json['profiles'] as Map<String, dynamic>?)?['avatar_url'] as String?,
      kind: kind,
      metadata: meta,
    );
  }

  final String id;
  final String groupId;
  final String userId;
  final String content;
  final DateTime createdAt;

  // Joined fields
  final String? senderName;
  final String? senderAvatarUrl;

  /// Message type — drives bubble styling in the chat surface.
  final GroupMessageKind kind;

  /// Optional metadata: scripture reference, media URL, etc.
  final Map<String, String> metadata;

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        content,
        createdAt,
        senderName,
        senderAvatarUrl,
        kind,
        metadata,
      ];
}

/// Distinguishes message types for chat styling.
enum GroupMessageKind { text, prayer, scripture, media, announcement }

/// A short, structured description of a group's purpose + meeting pattern.
class GroupMission extends Equatable {
  const GroupMission({
    required this.statement,
    this.scripture,
    this.meetingCadence,
  });

  final String statement;
  final String? scripture;
  final String? meetingCadence;

  @override
  List<Object?> get props => [statement, scripture, meetingCadence];
}

/// Activity snapshot for the group, used in Home + Detail cards.
class GroupActivity extends Equatable {
  const GroupActivity({
    this.lastMessageAt,
    this.lastMessagePreview,
    this.lastMessageAuthor,
    this.weeklyActiveMembers = 0,
    this.newMembersThisWeek = 0,
  });

  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final String? lastMessageAuthor;
  final int weeklyActiveMembers;
  final int newMembersThisWeek;

  bool get hasRecent =>
      lastMessageAt != null &&
      DateTime.now().difference(lastMessageAt!).inHours < 24;

  @override
  List<Object?> get props => [
        lastMessageAt,
        lastMessagePreview,
        lastMessageAuthor,
        weeklyActiveMembers,
        newMembersThisWeek,
      ];
}

/// Aggregate bundle for the Detail screen. One FutureProvider.fetchDetail()
/// returns this so the screen calls one repository method.
class GroupDetail extends Equatable {
  const GroupDetail({
    required this.group,
    required this.leader,
    required this.mission,
    required this.activity,
    this.members = const [],
    this.events = const [],
    this.prayerRequests = const [],
    this.announcements = const [],
    this.discussion = const [],
  });

  final CommunityGroup group;
  final GroupLeaderProfile leader;
  final GroupMission mission;
  final GroupActivity activity;
  final List<GroupMember> members;
  final List<GroupEvent> events;
  final List<GroupPrayerRequest> prayerRequests;
  final List<GroupAnnouncement> announcements;
  final List<GroupDiscussionPost> discussion;

  @override
  List<Object?> get props => [
        group,
        leader,
        mission,
        activity,
        members,
        events,
        prayerRequests,
        announcements,
        discussion,
      ];
}
