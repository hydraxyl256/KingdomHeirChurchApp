import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/groups/data/mock/mock_groups_seed.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps the Supabase client. New methods fall back to [MockGroupsSeed]
/// fixtures when the underlying table doesn't exist yet (so the UI works
/// end-to-end without a backend).
class GroupsSupabaseService {
  GroupsSupabaseService(this._client);
  final SupabaseClient _client;

  // ─────────────────────────────────────────────────────────────────
  // Existing — preserved unchanged
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, List<CommunityGroup>>> getGroups() async {
    try {
      final user = _client.auth.currentUser;
      final userId = user?.id;

      final response = await _client.from('groups').select('''
        *,
        group_categories(name),
        member_count:group_members(count),
        group_members(*)
      ''').order('created_at');

      final list = (response as List<dynamic>)
          .map(
            (json) => CommunityGroup.fromJson(
              json as Map<String, dynamic>,
              currentUserId: userId,
            ),
          )
          .toList();

      return right(list);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> joinGroup(
    String groupId, {
    bool isPrivate = false,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('User not authenticated');

      await _client.from('group_members').insert({
        'group_id': groupId,
        'user_id': user.id,
        'role': 'MEMBER',
        'status': isPrivate ? 'PENDING' : 'ACTIVE',
      });
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> leaveGroup(String groupId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('User not authenticated');

      await _client
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', user.id);
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Stream<List<GroupMessage>> streamMessages(String groupId) {
    return _client
        .from('group_messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at', ascending: true)
        .map(
          (data) => data.map(GroupMessage.fromJson).toList(),
        );
  }

  Future<Either<String, void>> sendMessage(
    String groupId,
    String content, {
    String? kind,
    Map<String, String> metadata = const {},
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('User not authenticated');

      final payload = <String, dynamic>{
        'group_id': groupId,
        'user_id': user.id,
        'content': content,
      };
      if (kind != null) payload['kind'] = kind;
      if (metadata.isNotEmpty) payload['metadata'] = metadata;

      await _client.from('group_messages').insert(payload);
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Detail — aggregate fetch
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, GroupDetail>> getGroupDetail(String groupId) async {
    try {
      // Try real Supabase first.
      final response = await _client.from('groups').select('''
            *,
            group_categories(name),
            group_members(*, profiles(*))
          ''').eq('id', groupId).maybeSingle();

      if (response != null) {
        final group = CommunityGroup.fromJson(
          (response as Map).cast<String, dynamic>(),
          currentUserId: _client.auth.currentUser?.id,
        );
        return right(
          GroupDetail(
            group: group,
            leader: MockGroupsSeed.leaderFor(groupId),
            mission: MockGroupsSeed.missionFor(groupId),
            activity: MockGroupsSeed.activityFor(groupId),
            members: MockGroupsSeed.sampleMembers(groupId),
            events: MockGroupsSeed.sampleEvents(groupId),
            prayerRequests: MockGroupsSeed.samplePrayer(groupId),
            announcements: MockGroupsSeed.sampleAnnouncements(groupId),
            discussion: MockGroupsSeed.sampleDiscussion(groupId),
          ),
        );
      }

      return left('Group not found');
    } catch (_) {
      // Table not yet wired → fall back to seed fixtures.
      final group = MockGroupsSeed.groups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => MockGroupsSeed.groups.first,
      );
      return right(
        GroupDetail(
          group: group,
          leader: MockGroupsSeed.leaderFor(groupId),
          mission: MockGroupsSeed.missionFor(groupId),
          activity: MockGroupsSeed.activityFor(groupId),
          members: MockGroupsSeed.sampleMembers(groupId),
          events: MockGroupsSeed.sampleEvents(groupId),
          prayerRequests: MockGroupsSeed.samplePrayer(groupId),
          announcements: MockGroupsSeed.sampleAnnouncements(groupId),
          discussion: MockGroupsSeed.sampleDiscussion(groupId),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Per-section feeds — always mock-backed for now (eventually real)
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, List<GroupEvent>>> getGroupEvents(
    String groupId,
  ) async {
    return right(MockGroupsSeed.sampleEvents(groupId));
  }

  Future<Either<String, List<GroupPrayerRequest>>> getGroupPrayer(
    String groupId,
  ) async {
    return right(MockGroupsSeed.samplePrayer(groupId));
  }

  Future<Either<String, List<GroupAnnouncement>>> getGroupAnnouncements(
    String groupId,
  ) async {
    return right(MockGroupsSeed.sampleAnnouncements(groupId));
  }

  Future<Either<String, List<GroupMember>>> getGroupMembers(
    String groupId,
  ) async {
    return right(MockGroupsSeed.sampleMembers(groupId));
  }

  Future<Either<String, List<GroupDiscussionPost>>> getGroupDiscussion(
    String groupId,
  ) async {
    return right(MockGroupsSeed.sampleDiscussion(groupId));
  }

  // ─────────────────────────────────────────────────────────────────
  // Home aggregated feeds
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, List<GroupEvent>>> getUpcomingMeetingsForUser() async {
    final myGroups = await _myGroups();
    if (myGroups.isEmpty) return right(const []);

    final events = <GroupEvent>[];
    for (final g in myGroups) {
      events.addAll(MockGroupsSeed.sampleEvents(g.id));
    }
    events.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return right(events.take(6).toList());
  }

  Future<Either<String, List<GroupPrayerRequest>>>
      getPrayerFeedForUser() async {
    final myGroups = await _myGroups();
    if (myGroups.isEmpty) return right(const []);

    final all = <GroupPrayerRequest>[];
    for (final g in myGroups) {
      all.addAll(MockGroupsSeed.samplePrayer(g.id));
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return right(all.take(5).toList());
  }

  Future<Either<String, List<GroupAnnouncement>>>
      getAnnouncementsFeedForUser() async {
    final myGroups = await _myGroups();
    if (myGroups.isEmpty) return right(const []);

    final all = <GroupAnnouncement>[];
    for (final g in myGroups) {
      all.addAll(MockGroupsSeed.sampleAnnouncements(g.id));
    }
    all.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return right(all.take(5).toList());
  }

  Future<Either<String, List<CommunityGroup>>> getSuggestedGroups() async {
    return right(MockGroupsSeed.suggestedGroups);
  }

  Future<Either<String, List<CommunityGroup>>> getRecentlyActiveGroups() async {
    try {
      final groups = await getGroups();
      return groups.fold(
        (err) => right(<CommunityGroup>[]),
        (list) {
          final mine = list.where((g) => g.isMember).toList()
            ..sort((a, b) {
              final ad = a.lastMessageAt;
              final bd = b.lastMessageAt;
              if (ad == null && bd == null) return 0;
              if (ad == null) return 1;
              if (bd == null) return -1;
              return bd.compareTo(ad);
            });
          return right(mine.take(4).toList());
        },
      );
    } catch (_) {
      return right(const []);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Mutations
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, void>> postPrayerRequest({
    required String groupId,
    required String body,
    required PrayerCategory category,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('User not authenticated');
      await _client.from('group_prayer_requests').insert({
        'group_id': groupId,
        'author_user_id': user.id,
        'body': body,
        'category': category.name.toUpperCase(),
      });
      return right(null);
    } catch (_) {
      // Stub success when table isn't present.
      return right(null);
    }
  }

  Future<Either<String, void>> markPraying(String prayerId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('User not authenticated');
      await _client.from('group_prayer_prayers').insert({
        'prayer_id': prayerId,
        'user_id': user.id,
      });
      return right(null);
    } catch (_) {
      return right(null);
    }
  }

  Future<Either<String, void>> postAnnouncement({
    required String groupId,
    required String body,
    required bool pinned,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('User not authenticated');
      await _client.from('group_announcements').insert({
        'group_id': groupId,
        'author_user_id': user.id,
        'body': body,
        'pinned': pinned,
      });
      return right(null);
    } catch (_) {
      return right(null);
    }
  }

  Future<Either<String, void>> approveJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _client
          .from('group_members')
          .update(
            {'status': 'ACTIVE'},
          )
          .eq('group_id', groupId)
          .eq('user_id', userId);
      return right(null);
    } catch (_) {
      return right(null);
    }
  }

  Future<Either<String, void>> denyJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _client
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
      return right(null);
    } catch (_) {
      return right(null);
    }
  }

  Future<Either<String, void>> rsvpEvent({
    required String eventId,
    required bool going,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('User not authenticated');
      if (going) {
        await _client.from('group_event_rsvps').upsert({
          'event_id': eventId,
          'user_id': user.id,
        });
      } else {
        await _client
            .from('group_event_rsvps')
            .delete()
            .eq('event_id', eventId)
            .eq('user_id', user.id);
      }
      return right(null);
    } catch (_) {
      return right(null);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Leader dashboard
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, List<PendingJoinRequest>>> getPendingRequests(
    String groupId,
  ) async {
    // Stub: 2 pending requests for the upper-room group.
    if (groupId == 'g-upper-room') {
      return right([
        PendingJoinRequest(
          id: 'pr-1',
          userId: 'u-new-1',
          displayName: 'Esther Njeri',
          requestedAt: DateTime.now().subtract(const Duration(hours: 6)),
          note:
              'Heard about this group from my cousin. Hungry for prayer community.',
        ),
        PendingJoinRequest(
          id: 'pr-2',
          userId: 'u-new-2',
          displayName: 'Mark Otieno',
          requestedAt: DateTime.now().subtract(const Duration(days: 1)),
          note: 'New to the city — looking for a prayer family.',
        ),
      ]);
    }
    return right(const []);
  }

  Future<Either<String, int>> getLeaderWeeklyEngagement(String groupId) async {
    return right(72); // 72% engagement
  }

  Future<Either<String, double>> getLeaderAvgAttendance(String groupId) async {
    return right(0.68); // 68% avg attendance
  }

  // ─────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────

  Future<List<CommunityGroup>> _myGroups() async {
    try {
      final user = _client.auth.currentUser;
      final userId = user?.id;
      final response = await _client.from('groups').select('''
        *,
        group_categories(name),
        member_count:group_members(count),
        group_members(*)
      ''').order('created_at');

      final list = (response as List<dynamic>)
          .map(
            (json) => CommunityGroup.fromJson(
              json as Map<String, dynamic>,
              currentUserId: userId,
            ),
          )
          .toList();
      return list.where((g) => g.isMember).toList();
    } catch (_) {
      // Fallback: assume user is a member of the seed "upper room".
      return MockGroupsSeed.groups.where((g) => g.isMember).toList();
    }
  }
}
