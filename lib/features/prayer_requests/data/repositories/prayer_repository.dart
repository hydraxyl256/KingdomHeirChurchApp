// Kingdom Heir — Prayer request repository
//
// Reads / writes the `public.prayer_requests` table (and its approved-only
// view `prayer_requests_approved`) via Supabase. Server-side moderation
// is performed through SECURITY DEFINER RPCs so that RLS + admin checks
// are enforced at the database, not in the client.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/utils/prayer_error_mapper.dart';
import 'package:kingdom_heir/features/prayer_requests/data/models/prayer_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return SupabasePrayerRepository(supabase.Supabase.instance.client);
});

abstract class PrayerRepository {
  /// Fetches the public Prayer Wall — only approved requests, ordered
  /// by `approved_at DESC` (newest approval first). The query targets
  /// the `prayer_requests_approved` view, which has its own row-level
  /// security and never returns pending or rejected rows.
  Future<Either<String, List<PrayerRequestModel>>> getApprovedPrayerWall({
    int limit = 50,
  });

  /// Submits a new prayer request. The DB trigger forces the row to
  /// `status = 'pending'` regardless of what the client sends. The
  /// client must NOT pass `status`, `reviewed_by/at`, `approved_at`, or
  /// `admin_note` — the trigger nulls them if present.
  Future<Either<String, void>> submitPrayerRequest(
    Map<String, dynamic> insertData,
  );

  /// Toggles the 'prayed' status for a specific request.
  Future<Either<String, void>> togglePrayerIntercession(
    String prayerRequestId, {
    required bool isPraying,
  });

  /// Subscribes to real-time changes on the `prayer_requests` table.
  /// Filters to approved rows so the public wall only sees new
  /// approvals.
  Stream<List<Map<String, dynamic>>> streamApprovedPrayerWall();

  /// Fetches the IDs of requests the current user has prayed for.
  Future<List<String>> getIntercededPrayerIds();

  /// Fetches all prayer requests submitted by the current user (public +
  /// private), regardless of status. Used by the "My Prayer Requests"
  /// screen so the user can see their own pending / approved /
  /// rejected state.
  Future<Either<String, List<PrayerRequestModel>>> getMyPrayerRequests({
    int limit = 30,
  });

  // ── Admin moderation RPCs ────────────────────────────────────────

  /// Pending tab. RPC: `get_pending_prayer_requests_for_admin`.
  Future<Either<String, List<PrayerRequestModel>>>
      getPendingPrayerRequestsForAdmin({int limit = 50});

  /// Approved tab. RPC: `get_approved_prayer_requests_for_admin`.
  Future<Either<String, List<PrayerRequestModel>>>
      getApprovedPrayerRequestsForAdmin({int limit = 50});

  /// Rejected tab. RPC: `get_rejected_prayer_requests_for_admin`.
  Future<Either<String, List<PrayerRequestModel>>>
      getRejectedPrayerRequestsForAdmin({int limit = 50});

  /// Approve a pending request. RPC: `approve_prayer_request`.
  Future<Either<String, void>> approvePrayerRequest({
    required String id,
    String? adminNote,
  });

  /// Reject (do-not-publish) a pending request. RPC: `reject_prayer_request`.
  Future<Either<String, void>> rejectPrayerRequest({
    required String id,
    String? adminNote,
  });

  /// Move a previously approved or rejected request back into the
  /// pending queue. RPC: `set_prayer_request_pending`.
  Future<Either<String, void>> returnPrayerRequestToPending({
    required String id,
  });
}

class SupabasePrayerRepository implements PrayerRepository {
  SupabasePrayerRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<Either<String, List<PrayerRequestModel>>> getApprovedPrayerWall({
    int limit = 50,
  }) async {
    try {
      // Target the public-facing view. The view filters to status =
      // 'approved' AND visibility IN ('public','leaders_only'), and
      // exposes a `display_name` column that is always 'Anonymous' for
      // anonymous rows.
      final response = await _client
          .from('prayer_requests_approved')
          .select('*, profiles:user_id(full_name, avatar_url)')
          .order('approved_at', ascending: false)
          .limit(limit);

      final requests = (response as List)
          .map((e) => PrayerRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return right(requests);
    } on supabase.PostgrestException catch (e) {
      // If the profiles join fails, retry without the join — the
      // anonymous/display_name logic still works from `requester_name`.
      if (e.code == 'PGRST200' || e.code == 'PGRST116') {
        try {
          final response = await _client
              .from('prayer_requests_approved')
              .select()
              .order('approved_at', ascending: false)
              .limit(limit);
          final requests = (response as List)
              .map((e) =>
                  PrayerRequestModel.fromJson(e as Map<String, dynamic>),)
              .toList();
          return right(requests);
        } catch (e2) {
          return left(mapErrorForMember(e2));
        }
      }
      return left(mapErrorForMember(e));
    } catch (e) {
      return left(mapErrorForMember(e));
    }
  }

  @override
  Future<Either<String, void>> submitPrayerRequest(
    Map<String, dynamic> insertData,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return left('Please sign in to submit a prayer request.');
      }

      insertData['user_id'] = user.id;

      // Defensive: drop any moderation fields the client might try to
      // smuggle in. The DB trigger nulls them anyway, but failing here
      // makes a malicious client easier to spot in logs.
      insertData
        ..remove('status')
        ..remove('reviewed_by')
        ..remove('reviewed_at')
        ..remove('approved_at')
        ..remove('admin_note')
        ..remove('requester_name');

      await _client.from('prayer_requests').insert(insertData);
      return right(null);
    } on supabase.PostgrestException catch (e) {
      return left(mapErrorForMember(e));
    } catch (e) {
      return left(mapErrorForMember(e));
    }
  }

  @override
  Future<Either<String, void>> togglePrayerIntercession(
    String prayerRequestId, {
    required bool isPraying,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return left('Please sign in to pray for requests.');
      }

      if (isPraying) {
        await _client.from('prayer_intercessions').upsert(
          {
            'prayer_request_id': prayerRequestId,
            'user_id': user.id,
          },
          onConflict: 'prayer_request_id, user_id',
        );
      } else {
        await _client.from('prayer_intercessions').delete().match({
          'prayer_request_id': prayerRequestId,
          'user_id': user.id,
        });
      }
      return right(null);
    } on supabase.PostgrestException catch (e) {
      return left(mapErrorForMember(e));
    } catch (e) {
      return left(mapErrorForMember(e));
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamApprovedPrayerWall() {
    // We stream the underlying `prayer_requests` table because the
    // view is not directly subscribable in Supabase Realtime. The
    // client-side filter keeps only approved rows so the public wall
    // never shows pending or rejected.
    return _client
        .from('prayer_requests')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) => rows
            .where((r) =>
                (r['status'] as String? ?? 'pending') == 'approved' &&
                ((r['visibility'] as String?) ?? 'public') != 'private',)
            .toList(),);
  }

  @override
  Future<List<String>> getIntercededPrayerIds() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const [];

      final response = await _client
          .from('prayer_intercessions')
          .select('prayer_request_id')
          .eq('user_id', user.id);

      return (response as List<dynamic>)
          .map((dynamic e) {
            return (e as Map<String, dynamic>)['prayer_request_id'] as String;
          })
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Either<String, List<PrayerRequestModel>>> getMyPrayerRequests({
    int limit = 30,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Please sign in to continue.');

      final response = await _client
          .from('prayer_requests')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      final requests = (response as List)
          .map((e) => PrayerRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return right(requests);
    } on supabase.PostgrestException catch (e) {
      return left(mapErrorForMember(e));
    } catch (e) {
      return left(mapErrorForMember(e));
    }
  }

  // ── Admin moderation RPCs ────────────────────────────────────────

  @override
  Future<Either<String, List<PrayerRequestModel>>>
      getPendingPrayerRequestsForAdmin({int limit = 50}) =>
          _callAdminListRpc('get_pending_prayer_requests_for_admin', limit);

  @override
  Future<Either<String, List<PrayerRequestModel>>>
      getApprovedPrayerRequestsForAdmin({int limit = 50}) =>
          _callAdminListRpc('get_approved_prayer_requests_for_admin', limit);

  @override
  Future<Either<String, List<PrayerRequestModel>>>
      getRejectedPrayerRequestsForAdmin({int limit = 50}) =>
          _callAdminListRpc('get_rejected_prayer_requests_for_admin', limit);

  Future<Either<String, List<PrayerRequestModel>>> _callAdminListRpc(
    String rpcName,
    int limit,
  ) async {
    try {
      final response =
          await _client.rpc<List<dynamic>>(rpcName, params: {'p_limit': limit});
      final rows = response
          .cast<Map<String, dynamic>>()
          .map(PrayerRequestModel.fromJson)
          .toList();
      return right(rows);
    } on supabase.PostgrestException catch (e) {
      return left(mapErrorForAdmin(e));
    } catch (e) {
      return left(mapErrorForAdmin(e));
    }
  }

  @override
  Future<Either<String, void>> approvePrayerRequest({
    required String id,
    String? adminNote,
  }) =>
      _callModerationRpc('approve_prayer_request', id, adminNote);

  @override
  Future<Either<String, void>> rejectPrayerRequest({
    required String id,
    String? adminNote,
  }) =>
      _callModerationRpc('reject_prayer_request', id, adminNote);

  @override
  Future<Either<String, void>> returnPrayerRequestToPending({
    required String id,
  }) =>
      _callModerationRpc('set_prayer_request_pending', id, null);

  Future<Either<String, void>> _callModerationRpc(
    String rpcName,
    String id,
    String? adminNote,
  ) async {
    try {
      final params = <String, dynamic>{'p_request_id': id};
      if (adminNote != null) params['p_admin_note'] = adminNote;
      await _client.rpc<Object?>(rpcName, params: params);
      return right(null);
    } on supabase.PostgrestException catch (e) {
      return left(mapErrorForAdmin(e));
    } catch (e) {
      return left(mapErrorForAdmin(e));
    }
  }
}
