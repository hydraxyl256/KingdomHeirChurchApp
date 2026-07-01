// Kingdom Heir — Notifications repository
//
// Reads the user's notifications from the `public.notifications` Supabase
// table. RLS limits the SELECT to the caller's `user_id` so users can
// only see their own notifications.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/notifications/data/models/notification_model.dart';
import 'package:kingdom_heir/features/notifications/domain/entities/app_notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return SupabaseNotificationsRepository(supabase.Supabase.instance.client);
});

abstract class NotificationsRepository {
  /// Fetch the most recent [limit] notifications for the current user,
  /// newest first.
  Future<List<AppNotification>> getNotifications({int limit = 50});

  /// Mark a single notification as read.
  Future<void> markAsRead(String id);

  /// Mark all of the user's unread notifications as read.
  Future<void> markAllAsRead();

  /// Number of unread notifications. Returns 0 if no user is signed in.
  Future<int> unreadCount();
}

class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<List<AppNotification>> getNotifications({int limit = 50}) async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];

    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)
              .toEntity(),)
          .toList(growable: false);
    } catch (_) {
      // Network / RLS / unknown — return empty list so the UI shows
      // the empty state instead of an error.
      return const [];
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (_) {
      // Best-effort — the next reload will re-fetch the updated state.
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (_) {
      // Best-effort.
    }
  }

  @override
  Future<int> unreadCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false)
          .count();
      // PostgREST returns the count under either 'count' (raw count call)
      // or as a list. We use the `count` PostgrestFilterBuilder API which
      // returns an int directly when .select('id', CountOption.exact)
      // is used; here we get a PostgrestResponse<PostgrestList> for safety.
      return response.count;
    } catch (_) {
      return 0;
    }
  }
}
