// Kingdom Heir — Group Detail Provider
//
// Aggregates the per-section providers for a single groupId into a
// single bundle the Detail screen consumes. Also exposes mutation
// helpers (rsvpEvent, postPrayer, postAnnouncement) that invalidate
// the relevant section provider when complete.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';

/// Read every per-section provider for a `groupId` in parallel. Returns a
/// single `GroupSections` record for easy pattern matching in widgets.
class GroupSections {
  const GroupSections({
    required this.detail,
    required this.events,
    required this.prayer,
    required this.members,
    required this.announcements,
    required this.discussion,
    required this.pendingRequests,
    required this.weeklyEngagement,
    required this.avgAttendance,
  });

  final AsyncValue<GroupDetail> detail;
  final AsyncValue<List<GroupEvent>> events;
  final AsyncValue<List<GroupPrayerRequest>> prayer;
  final AsyncValue<List<GroupMember>> members;
  final AsyncValue<List<GroupAnnouncement>> announcements;
  final AsyncValue<List<GroupDiscussionPost>> discussion;
  final AsyncValue<List<PendingJoinRequest>> pendingRequests;
  final AsyncValue<int> weeklyEngagement;
  final AsyncValue<double> avgAttendance;

  bool get hasAnyError =>
      detail.hasError ||
      events.hasError ||
      prayer.hasError ||
      members.hasError ||
      announcements.hasError ||
      discussion.hasError;

  bool get isLoading =>
      detail.isLoading ||
      events.isLoading ||
      prayer.isLoading ||
      members.isLoading ||
      announcements.isLoading ||
      discussion.isLoading;
}

final groupSectionsProvider =
    Provider.family<GroupSections, String>((ref, groupId) {
  return GroupSections(
    detail: ref.watch(groupDetailProvider(groupId)),
    events: ref.watch(groupEventsProvider(groupId)),
    prayer: ref.watch(groupPrayerProvider(groupId)),
    members: ref.watch(groupMembersProvider(groupId)),
    announcements: ref.watch(groupAnnouncementsProvider(groupId)),
    discussion: ref.watch(groupDiscussionProvider(groupId)),
    pendingRequests: ref.watch(groupPendingRequestsProvider(groupId)),
    weeklyEngagement: ref.watch(groupWeeklyEngagementProvider(groupId)),
    avgAttendance: ref.watch(groupAvgAttendanceProvider(groupId)),
  );
});

// ─────────────────────────────────────────────────────────────────────
// Mutation helpers — invalidate relevant providers after write
// ─────────────────────────────────────────────────────────────────────

class GroupMutations {
  GroupMutations(this._ref);
  final Ref _ref;

  Future<void> rsvpEvent({
    required String eventId,
    required String groupId,
    required bool going,
  }) async {
    final repo = _ref.read(groupsRepositoryProvider);
    final result = await repo.rsvpEvent(eventId: eventId, going: going);
    result.fold((err) => throw Exception(err), (_) {
      _ref
        ..invalidate(groupEventsProvider(groupId))
        ..invalidate(groupDetailProvider(groupId));
    });
  }

  Future<void> postPrayer({
    required String groupId,
    required String body,
    required PrayerCategory category,
  }) async {
    final repo = _ref.read(groupsRepositoryProvider);
    final result = await repo.postPrayerRequest(
      groupId: groupId,
      body: body,
      category: category,
    );
    result.fold((err) => throw Exception(err), (_) {
      _ref
        ..invalidate(groupPrayerProvider(groupId))
        ..invalidate(groupDetailProvider(groupId))
        ..invalidate(prayerFeedForUserProvider);
    });
  }

  Future<void> markPraying({
    required String prayerId,
    required String groupId,
  }) async {
    final repo = _ref.read(groupsRepositoryProvider);
    final result = await repo.markPraying(prayerId);
    result.fold((err) => throw Exception(err), (_) {
      _ref
        ..invalidate(groupPrayerProvider(groupId))
        ..invalidate(groupDetailProvider(groupId));
    });
  }

  Future<void> postAnnouncement({
    required String groupId,
    required String body,
    required bool pinned,
  }) async {
    final repo = _ref.read(groupsRepositoryProvider);
    final result = await repo.postAnnouncement(
      groupId: groupId,
      body: body,
      pinned: pinned,
    );
    result.fold((err) => throw Exception(err), (_) {
      _ref
        ..invalidate(groupAnnouncementsProvider(groupId))
        ..invalidate(groupDetailProvider(groupId))
        ..invalidate(announcementsFeedForUserProvider);
    });
  }

  Future<void> approveJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    final repo = _ref.read(groupsRepositoryProvider);
    final result = await repo.approveJoinRequest(
      groupId: groupId,
      userId: userId,
    );
    result.fold((err) => throw Exception(err), (_) {
      _ref
        ..invalidate(groupPendingRequestsProvider(groupId))
        ..invalidate(groupMembersProvider(groupId))
        ..invalidate(groupDetailProvider(groupId));
    });
  }

  Future<void> denyJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    final repo = _ref.read(groupsRepositoryProvider);
    final result = await repo.denyJoinRequest(
      groupId: groupId,
      userId: userId,
    );
    result.fold((err) => throw Exception(err), (_) {
      _ref.invalidate(groupPendingRequestsProvider(groupId));
    });
  }
}

final groupMutationsProvider = Provider<GroupMutations>(GroupMutations.new);
