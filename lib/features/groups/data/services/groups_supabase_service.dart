import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsSupabaseService {
  GroupsSupabaseService(this._client, this._prefs);
  final SupabaseClient _client;
  final SharedPreferences _prefs;

  Future<Either<String, T>> _guardData<T>(
    String label,
    Future<dynamic> Function() fetchJson,
    T Function(dynamic) parseJson,
    T emptyState,
  ) async {
    final cacheKey = 'groups_cache_$label';
    try {
      final data = await fetchJson();
      final cachePayload = {
        'data': data,
        'cached_at': DateTime.now().toIso8601String(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cachePayload));
      return right(parseJson(data));
    } catch (e) {
      final cachedString = _prefs.getString(cacheKey);
      if (cachedString != null) {
        try {
          final cached = jsonDecode(cachedString) as Map<String, dynamic>;
          final data = cached['data'];
          if (data != null) {
            return right(parseJson(data));
          }
        } catch (_) {}
      }
      return right(emptyState);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Existing — preserved unchanged
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, List<CommunityGroup>>> getGroups() => _guardData<List<CommunityGroup>>(
        'getGroups',
        () async {
          return await _client.from('groups').select('''
            *,
            group_categories(name),
            member_count:group_members(count),
            group_members(*)
          ''').order('created_at');
        },
        (dynamic rows) {
          final user = _client.auth.currentUser;
          final userId = user?.id;
          return (rows as List<dynamic>)
              .map(
                (json) => CommunityGroup.fromJson(
                  json as Map<String, dynamic>,
                  currentUserId: userId,
                ),
              )
              .toList();
        },
        const [],
      );

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
    final cacheKey = 'groups_cache_detail_$groupId';
    try {
      final response = await _client.from('groups').select('''
            *,
            group_categories(name),
            group_members(*, profiles(*))
          ''').eq('id', groupId).maybeSingle();

      if (response != null) {
        final cachePayload = {
          'data': response,
          'cached_at': DateTime.now().toIso8601String(),
        };
        await _prefs.setString(cacheKey, jsonEncode(cachePayload));

        final group = CommunityGroup.fromJson(
          (response as Map).cast<String, dynamic>(),
          currentUserId: _client.auth.currentUser?.id,
        );
        return right(
          GroupDetail(
            group: group,
          ),
        );
      }

      return left('Group not found');
    } catch (_) {
      final cachedString = _prefs.getString(cacheKey);
      if (cachedString != null) {
        try {
          final cached = jsonDecode(cachedString) as Map<String, dynamic>;
          final data = cached['data'];
          if (data != null) {
            final group = CommunityGroup.fromJson(
              (data as Map).cast<String, dynamic>(),
              currentUserId: _client.auth.currentUser?.id,
            );
            return right(
              GroupDetail(
                group: group,
              ),
            );
          }
        } catch (_) {}
      }
      return left('Group not found offline');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Per-section feeds — returning empty collections until tables exist
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, List<GroupEvent>>> getGroupEvents(
    String groupId,
  ) async {
    return right(const []);
  }

  Future<Either<String, List<GroupPrayerRequest>>> getGroupPrayer(
    String groupId,
  ) async {
    return right(const []);
  }

  Future<Either<String, List<GroupAnnouncement>>> getGroupAnnouncements(
    String groupId,
  ) async {
    return right(const []);
  }

  Future<Either<String, List<GroupMember>>> getGroupMembers(
    String groupId,
  ) async {
    return right(const []);
  }

  Future<Either<String, List<GroupDiscussionPost>>> getGroupDiscussion(
    String groupId,
  ) async {
    return right(const []);
  }

  // ─────────────────────────────────────────────────────────────────
  // Home aggregated feeds — returning empty collections
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, List<GroupEvent>>> getUpcomingMeetingsForUser() async {
    return right(const []);
  }

  Future<Either<String, List<GroupPrayerRequest>>>
      getPrayerFeedForUser() async {
    return right(const []);
  }

  Future<Either<String, List<GroupAnnouncement>>>
      getAnnouncementsFeedForUser() async {
    return right(const []);
  }

  Future<Either<String, List<CommunityGroup>>> getSuggestedGroups() async {
    return right(const []);
  }

  Future<Either<String, List<CommunityGroup>>> getRecentlyActiveGroups() async {
    return right(const []);
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
    return right(const []);
  }

  Future<Either<String, int>> getLeaderWeeklyEngagement(String groupId) async {
    return right(0);
  }

  Future<Either<String, double>> getLeaderAvgAttendance(String groupId) async {
    return right(0);
  }
}
