import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/features/groups/data/repositories/groups_repository.dart';
import 'package:kingdom_heir/features/groups/data/services/groups_supabase_service.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';

// ─────────────────────────────────────────────────────────────────────
// Services & Repositories
// ─────────────────────────────────────────────────────────────────────

final groupsSupabaseServiceProvider = Provider<GroupsSupabaseService>((ref) {
  return GroupsSupabaseService(ref.watch(supabaseClientProvider));
});

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepositoryImpl(ref.watch(groupsSupabaseServiceProvider));
});

// ─────────────────────────────────────────────────────────────────────
// Existing — All groups (kept for backward compat)
// ─────────────────────────────────────────────────────────────────────

final groupsListProvider =
    AsyncNotifierProvider<GroupsNotifier, List<CommunityGroup>>(
  GroupsNotifier.new,
);

class GroupsNotifier extends AsyncNotifier<List<CommunityGroup>> {
  @override
  Future<List<CommunityGroup>> build() async {
    final repo = ref.read(groupsRepositoryProvider);
    final result = await repo.getGroups();
    return result.fold(
      (err) => throw Exception(err),
      (groups) => groups,
    );
  }

  Future<void> joinGroup(String groupId, {bool isPrivate = false}) async {
    final repo = ref.read(groupsRepositoryProvider);
    await repo.joinGroup(groupId, isPrivate: isPrivate);
    ref
      ..invalidateSelf()
      ..invalidate(communityHomeProvider);
  }

  Future<void> leaveGroup(String groupId) async {
    final repo = ref.read(groupsRepositoryProvider);
    await repo.leaveGroup(groupId);
    ref
      ..invalidateSelf()
      ..invalidate(communityHomeProvider);
  }
}

// ─────────────────────────────────────────────────────────────────────
// Derived — My Groups / Discoverable
// ─────────────────────────────────────────────────────────────────────

final myGroupsProvider = Provider<AsyncValue<List<CommunityGroup>>>((ref) {
  final asyncGroups = ref.watch(groupsListProvider);
  return asyncGroups.whenData(
    (groups) => groups.where((g) => g.isMember || g.isPending).toList(),
  );
});

final discoverableGroupsProvider =
    Provider<AsyncValue<List<CommunityGroup>>>((ref) {
  final asyncGroups = ref.watch(groupsListProvider);
  return asyncGroups.whenData(
    (groups) => groups.where((g) => !g.isMember && !g.isPending).toList(),
  );
});

// ─────────────────────────────────────────────────────────────────────
// Chat
// ─────────────────────────────────────────────────────────────────────

final groupChatStreamProvider =
    StreamProvider.family<List<GroupMessage>, String>((ref, groupId) {
  final repo = ref.watch(groupsRepositoryProvider);
  return repo.streamMessages(groupId);
});

// ─────────────────────────────────────────────────────────────────────
// Home — per-section FutureProviders (parallel load)
// ─────────────────────────────────────────────────────────────────────

final myGroupsCarouselProvider =
    FutureProvider<List<CommunityGroup>>((ref) async {
  // `myGroupsProvider` is a derived `Provider<AsyncValue<...>>`. Wait
  // for the underlying `groupsListProvider` to settle, then filter.
  final groups = await ref.watch(groupsListProvider.future);
  return groups.where((g) => g.isMember).toList();
});

final recentlyActiveGroupsProvider =
    FutureProvider<List<CommunityGroup>>((ref) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getRecentlyActiveGroups();
  return result.fold(
    (err) => throw Exception(err),
    (groups) => groups,
  );
});

final upcomingMeetingsProvider = FutureProvider<List<GroupEvent>>((ref) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getUpcomingMeetingsForUser();
  return result.fold(
    (err) => throw Exception(err),
    (events) => events,
  );
});

final prayerFeedForUserProvider =
    FutureProvider<List<GroupPrayerRequest>>((ref) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getPrayerFeedForUser();
  return result.fold(
    (err) => throw Exception(err),
    (list) => list,
  );
});

final announcementsFeedForUserProvider =
    FutureProvider<List<GroupAnnouncement>>((ref) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getAnnouncementsFeedForUser();
  return result.fold(
    (err) => throw Exception(err),
    (list) => list,
  );
});

final suggestedGroupsProvider =
    FutureProvider<List<CommunityGroup>>((ref) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getSuggestedGroups();
  return result.fold(
    (err) => throw Exception(err),
    (list) => list,
  );
});

/// Aggregate bundle — used by the Community Home screen to load all
/// sections in parallel.
class CommunityHomeData {
  const CommunityHomeData({
    required this.myGroups,
    required this.recentlyActive,
    required this.upcomingMeetings,
    required this.prayerFeed,
    required this.announcements,
    required this.suggested,
  });

  final List<CommunityGroup> myGroups;
  final List<CommunityGroup> recentlyActive;
  final List<GroupEvent> upcomingMeetings;
  final List<GroupPrayerRequest> prayerFeed;
  final List<GroupAnnouncement> announcements;
  final List<CommunityGroup> suggested;
}

final communityHomeProvider = FutureProvider<CommunityHomeData>((ref) async {
  // Fire all six in parallel.
  final myGroups = await ref.watch(myGroupsCarouselProvider.future);
  final recentlyActive = await ref.watch(recentlyActiveGroupsProvider.future);
  final upcomingMeetings = await ref.watch(upcomingMeetingsProvider.future);
  final prayerFeed = await ref.watch(prayerFeedForUserProvider.future);
  final announcements =
      await ref.watch(announcementsFeedForUserProvider.future);
  final suggested = await ref.watch(suggestedGroupsProvider.future);

  return CommunityHomeData(
    myGroups: myGroups,
    recentlyActive: recentlyActive,
    upcomingMeetings: upcomingMeetings,
    prayerFeed: prayerFeed,
    announcements: announcements,
    suggested: suggested,
  );
});

// ─────────────────────────────────────────────────────────────────────
// Per-group detail providers (family by groupId)
// ─────────────────────────────────────────────────────────────────────

final groupDetailProvider =
    FutureProvider.family<GroupDetail, String>((ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getGroupDetail(groupId);
  return result.fold((err) => throw Exception(err), (d) => d);
});

final groupEventsProvider =
    FutureProvider.family<List<GroupEvent>, String>((ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getGroupEvents(groupId);
  return result.fold((err) => <GroupEvent>[], (list) => list);
});

final groupPrayerProvider =
    FutureProvider.family<List<GroupPrayerRequest>, String>(
        (ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getGroupPrayer(groupId);
  return result.fold((err) => <GroupPrayerRequest>[], (list) => list);
});

final groupMembersProvider =
    FutureProvider.family<List<GroupMember>, String>((ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getGroupMembers(groupId);
  return result.fold((err) => <GroupMember>[], (list) => list);
});

final groupAnnouncementsProvider =
    FutureProvider.family<List<GroupAnnouncement>, String>(
        (ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getGroupAnnouncements(groupId);
  return result.fold((err) => <GroupAnnouncement>[], (list) => list);
});

final groupDiscussionProvider =
    FutureProvider.family<List<GroupDiscussionPost>, String>(
        (ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getGroupDiscussion(groupId);
  return result.fold((err) => <GroupDiscussionPost>[], (list) => list);
});

// ─────────────────────────────────────────────────────────────────────
// Leader dashboard providers
// ─────────────────────────────────────────────────────────────────────

final groupPendingRequestsProvider =
    FutureProvider.family<List<PendingJoinRequest>, String>(
        (ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getPendingRequests(groupId);
  return result.fold((err) => <PendingJoinRequest>[], (list) => list);
});

final groupWeeklyEngagementProvider =
    FutureProvider.family<int, String>((ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getLeaderWeeklyEngagement(groupId);
  return result.fold((err) => 0, (val) => val);
});

final groupAvgAttendanceProvider =
    FutureProvider.family<double, String>((ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final result = await repo.getLeaderAvgAttendance(groupId);
  return result.fold((err) => 0.0, (val) => val);
});
