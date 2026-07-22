import 'dart:async';
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/logging/structured_logger.dart';
import 'package:kingdom_heir/core/storage/cache_keys.dart';
import 'package:kingdom_heir/core/storage/cache_manager.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsSupabaseService {
  GroupsSupabaseService(this._client, this._cacheManager);
  final SupabaseClient _client;
  final CacheManager _cacheManager;

  Future<Either<String, T>> _guardData<T>(
    String cacheKey,
    Duration ttl,
    Future<dynamic> Function() fetchJson,
    T Function(dynamic) parseJson,
    T emptyState,
  ) async {
    StructuredLogger.networkRequestStarted(
      feature: 'groups',
      repository: 'GroupsSupabaseService',
      datasource: 'supabase',
    );
    final stopwatch = Stopwatch()..start();

    try {
      final data = await fetchJson();
      stopwatch.stop();

      StructuredLogger.networkRequestCompleted(
        feature: 'groups',
        repository: 'GroupsSupabaseService',
        datasource: 'supabase',
        durationMs: stopwatch.elapsedMilliseconds,
      );

      await _cacheManager.write(
        key: cacheKey,
        payload: data,
        feature: 'groups',
        repository: 'GroupsSupabaseService',
        ttl: ttl,
      );

      return right(parseJson(data));
    } catch (e) {
      stopwatch.stop();
      
      final isNetworkError = e is SocketException || e is TimeoutException || e.toString().toLowerCase().contains('network') || e.toString().toLowerCase().contains('socket');
      
      if (!isNetworkError) {
        StructuredLogger.parsingFailed(
          feature: 'groups',
          repository: 'GroupsSupabaseService',
          error: e.toString(),
        );
        rethrow;
      }

      StructuredLogger.networkRequestFailed(
        feature: 'groups',
        repository: 'GroupsSupabaseService',
        datasource: 'supabase',
        durationMs: stopwatch.elapsedMilliseconds,
        errorType: e.runtimeType.toString(),
      );

      final cached = _cacheManager.read(
        key: cacheKey,
        feature: 'groups',
        repository: 'GroupsSupabaseService',
      );

      if (cached != null) {
        try {
          return right(parseJson(cached));
        } catch (_) {}
      }
      return right(emptyState);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Existing — preserved unchanged
  // ─────────────────────────────────────────────────────────────────

  Future<Either<String, List<CommunityGroup>>> getGroups() => _guardData<List<CommunityGroup>>(
        CacheKeys.groupsList,
        const Duration(minutes: 30),
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
    return _guardData<GroupDetail>(
      CacheKeys.groupDetail(groupId),
      const Duration(minutes: 30),
      () async {
        final response = await _client.from('groups').select('''
            *,
            group_categories(name),
            group_members(*, profiles(*))
          ''').eq('id', groupId).maybeSingle();
        if (response == null) {
          throw Exception('Group not found');
        }
        return response;
      },
      (dynamic data) {
        final group = CommunityGroup.fromJson(
          (data as Map).cast<String, dynamic>(),
          currentUserId: _client.auth.currentUser?.id,
        );
        return GroupDetail(group: group);
      },
      const GroupDetail(group: CommunityGroup(id: '0', name: 'Unknown', description: 'Unknown', isPrivate: false)),
    );
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
