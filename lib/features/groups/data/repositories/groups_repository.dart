import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/groups/data/services/groups_supabase_service.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';

/// Chat draft — sent through the chat send provider.
class ChatDraft {
  const ChatDraft({
    required this.groupId,
    required this.content,
    this.kind = GroupMessageKind.text,
    this.metadata = const {},
  });

  final String groupId;
  final String content;
  final GroupMessageKind kind;
  final Map<String, String> metadata;
}

abstract class GroupsRepository {
  // ── Existing — signatures unchanged ───────────────────────────────
  Future<Either<String, List<CommunityGroup>>> getGroups();
  Future<Either<String, void>> joinGroup(
    String groupId, {
    bool isPrivate = false,
  });
  Future<Either<String, void>> leaveGroup(String groupId);
  Stream<List<GroupMessage>> streamMessages(String groupId);
  Future<Either<String, void>> sendMessage(
    String groupId,
    String content, {
    String? kind,
    Map<String, String> metadata = const {},
  });

  // ── New — Detail screen aggregate ────────────────────────────────
  Future<Either<String, GroupDetail>> getGroupDetail(String groupId);

  // ── New — per-section feeds ──────────────────────────────────────
  Future<Either<String, List<GroupEvent>>> getGroupEvents(String groupId);
  Future<Either<String, List<GroupPrayerRequest>>> getGroupPrayer(
    String groupId,
  );
  Future<Either<String, List<GroupAnnouncement>>> getGroupAnnouncements(
    String groupId,
  );
  Future<Either<String, List<GroupMember>>> getGroupMembers(String groupId);
  Future<Either<String, List<GroupDiscussionPost>>> getGroupDiscussion(
    String groupId,
  );

  // ── New — Home / aggregated feeds ────────────────────────────────
  Future<Either<String, List<GroupEvent>>> getUpcomingMeetingsForUser();
  Future<Either<String, List<GroupPrayerRequest>>> getPrayerFeedForUser();
  Future<Either<String, List<GroupAnnouncement>>> getAnnouncementsFeedForUser();
  Future<Either<String, List<CommunityGroup>>> getSuggestedGroups();
  Future<Either<String, List<CommunityGroup>>> getRecentlyActiveGroups();

  // ── New — Mutations ──────────────────────────────────────────────
  Future<Either<String, void>> postPrayerRequest({
    required String groupId,
    required String body,
    required PrayerCategory category,
  });
  Future<Either<String, void>> markPraying(String prayerId);
  Future<Either<String, void>> postAnnouncement({
    required String groupId,
    required String body,
    required bool pinned,
  });
  Future<Either<String, void>> approveJoinRequest({
    required String groupId,
    required String userId,
  });
  Future<Either<String, void>> denyJoinRequest({
    required String groupId,
    required String userId,
  });
  Future<Either<String, void>> rsvpEvent({
    required String eventId,
    required bool going,
  });

  // ── New — Leader dashboard ───────────────────────────────────────
  Future<Either<String, List<PendingJoinRequest>>> getPendingRequests(
    String groupId,
  );
  Future<Either<String, int>> getLeaderWeeklyEngagement(String groupId);
  Future<Either<String, double>> getLeaderAvgAttendance(String groupId);
}

class GroupsRepositoryImpl implements GroupsRepository {
  GroupsRepositoryImpl(this._service);
  final GroupsSupabaseService _service;

  // ── Existing forwards ────────────────────────────────────────────

  @override
  Future<Either<String, List<CommunityGroup>>> getGroups() =>
      _service.getGroups();

  @override
  Future<Either<String, void>> joinGroup(
    String groupId, {
    bool isPrivate = false,
  }) =>
      _service.joinGroup(groupId, isPrivate: isPrivate);

  @override
  Future<Either<String, void>> leaveGroup(String groupId) =>
      _service.leaveGroup(groupId);

  @override
  Stream<List<GroupMessage>> streamMessages(String groupId) =>
      _service.streamMessages(groupId);

  @override
  Future<Either<String, void>> sendMessage(
    String groupId,
    String content, {
    String? kind,
    Map<String, String> metadata = const {},
  }) =>
      _service.sendMessage(
        groupId,
        content,
        kind: kind,
        metadata: metadata,
      );

  // ── Detail / per-section forwards ────────────────────────────────

  @override
  Future<Either<String, GroupDetail>> getGroupDetail(String groupId) =>
      _service.getGroupDetail(groupId);

  @override
  Future<Either<String, List<GroupEvent>>> getGroupEvents(String groupId) =>
      _service.getGroupEvents(groupId);

  @override
  Future<Either<String, List<GroupPrayerRequest>>> getGroupPrayer(
    String groupId,
  ) =>
      _service.getGroupPrayer(groupId);

  @override
  Future<Either<String, List<GroupAnnouncement>>> getGroupAnnouncements(
    String groupId,
  ) =>
      _service.getGroupAnnouncements(groupId);

  @override
  Future<Either<String, List<GroupMember>>> getGroupMembers(String groupId) =>
      _service.getGroupMembers(groupId);

  @override
  Future<Either<String, List<GroupDiscussionPost>>> getGroupDiscussion(
    String groupId,
  ) =>
      _service.getGroupDiscussion(groupId);

  // ── Home / aggregated feeds ──────────────────────────────────────

  @override
  Future<Either<String, List<GroupEvent>>> getUpcomingMeetingsForUser() =>
      _service.getUpcomingMeetingsForUser();

  @override
  Future<Either<String, List<GroupPrayerRequest>>> getPrayerFeedForUser() =>
      _service.getPrayerFeedForUser();

  @override
  Future<Either<String, List<GroupAnnouncement>>>
      getAnnouncementsFeedForUser() => _service.getAnnouncementsFeedForUser();

  @override
  Future<Either<String, List<CommunityGroup>>> getSuggestedGroups() =>
      _service.getSuggestedGroups();

  @override
  Future<Either<String, List<CommunityGroup>>> getRecentlyActiveGroups() =>
      _service.getRecentlyActiveGroups();

  // ── Mutations ─────────────────────────────────────────────────────

  @override
  Future<Either<String, void>> postPrayerRequest({
    required String groupId,
    required String body,
    required PrayerCategory category,
  }) =>
      _service.postPrayerRequest(
        groupId: groupId,
        body: body,
        category: category,
      );

  @override
  Future<Either<String, void>> markPraying(String prayerId) =>
      _service.markPraying(prayerId);

  @override
  Future<Either<String, void>> postAnnouncement({
    required String groupId,
    required String body,
    required bool pinned,
  }) =>
      _service.postAnnouncement(
        groupId: groupId,
        body: body,
        pinned: pinned,
      );

  @override
  Future<Either<String, void>> approveJoinRequest({
    required String groupId,
    required String userId,
  }) =>
      _service.approveJoinRequest(groupId: groupId, userId: userId);

  @override
  Future<Either<String, void>> denyJoinRequest({
    required String groupId,
    required String userId,
  }) =>
      _service.denyJoinRequest(groupId: groupId, userId: userId);

  @override
  Future<Either<String, void>> rsvpEvent({
    required String eventId,
    required bool going,
  }) =>
      _service.rsvpEvent(eventId: eventId, going: going);

  // ── Leader dashboard ──────────────────────────────────────────────

  @override
  Future<Either<String, List<PendingJoinRequest>>> getPendingRequests(
    String groupId,
  ) =>
      _service.getPendingRequests(groupId);

  @override
  Future<Either<String, int>> getLeaderWeeklyEngagement(String groupId) =>
      _service.getLeaderWeeklyEngagement(groupId);

  @override
  Future<Either<String, double>> getLeaderAvgAttendance(String groupId) =>
      _service.getLeaderAvgAttendance(groupId);
}
