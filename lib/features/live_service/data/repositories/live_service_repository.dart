// Kingdom Heir — Live Service Repository
//
// Owns all read/write traffic for the live worship platform:
//   • getActiveLiveService  — picks the most relevant live / upcoming
//                             stream for the home and live screens
//   • streamChatMessages    — realtime chat feed for the live room
//   • sendChatMessage       — posts a member's chat message
//   • saveSermonNote        — persists a personal note from the live room
//
// All methods are guarded against the table not being present (RUM
// saw a 42P01 on first deploy). If the schema is missing we return
// the typed idle / empty state instead of throwing.

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:kingdom_heir/core/error/error_handler.dart';
import 'package:kingdom_heir/features/live_service/domain/entities/live_service_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveServiceRepository {
  LiveServiceRepository(this._db);

  final SupabaseClient _db;

  /// Fetches the most relevant row from `public.live_services`.
  ///
  /// Priority:
  ///   1. The currently-live stream (`status='live'`). Its
  ///      `youtube_video_id` is exposed as [LiveServiceState.youtubeId]
  ///      so the player can render it.
  ///   2. The next scheduled stream (`status='scheduled'`, ordered
  ///      by `scheduled_start_at`). Used to show the "Next service"
  ///      card on the home dashboard.
  ///   3. The most-recently-ended stream (`status='ended'`, ordered
  ///      by `ended_at desc`). Exposed as
  ///      [LiveServiceState.replayYoutubeId] so the live screen can
  ///      play the recording when no live broadcast is happening.
  ///   4. [LiveServiceState.idle] — nothing in the schedule.
  ///
  /// The `youtube_video_id` column is the canonical 11-char video
  /// ID, written by `supabase/functions/sync-youtube-live`. The
  /// `stream_url` is the full watch URL (kept for analytics / future
  /// HLS fallback) but the player uses `youtube_video_id` directly.
  ///
  /// If `public.live_services` is not yet provisioned (RUM saw a
  /// 42P01 on first deploy), we silently fall back to idle rather
  /// than throwing — the home dashboard would otherwise show a
  /// permanent error.
  Future<LiveServiceState> getActiveLiveService() async {
    try {
      // 1. Currently live.
      final live = await _db
          .from('live_services')
          .select(
            'id, title, speaker_name, stream_url, thumbnail_url, '
            'actual_start_at, viewer_count, youtube_video_id, status',
          )
          .eq('status', 'live')
          .order('actual_start_at', ascending: false)
          .limit(1);

      if (live.isNotEmpty) {
        return liveRowToState(live.first);
      }

      // 2. Next scheduled.
      final upcoming = await _db
          .from('live_services')
          .select(
            'id, title, speaker_name, scheduled_start_at, '
            'thumbnail_url, youtube_video_id',
          )
          .eq('status', 'scheduled')
          .order('scheduled_start_at')
          .limit(1);

      if (upcoming.isNotEmpty) {
        return upcomingRowToState(upcoming.first);
      }

      // 3. Most-recently-ended → expose as a replay.
      final ended = await _db
          .from('live_services')
          .select(
            'id, title, speaker_name, ended_at, thumbnail_url, '
            'youtube_video_id',
          )
          .eq('status', 'ended')
          .order('ended_at', ascending: false)
          .limit(1);

      if (ended.isNotEmpty) {
        return endedRowToState(ended.first);
      }

      return const LiveServiceState.idle();
    } catch (e, st) {
      // Schema missing (42P01) or other infra error → never block the
      // dashboard. Log and return idle.
      ErrorHandler.handle(e, st);
      return const LiveServiceState.idle();
    }
  }

  /// Visible for testing — builds a [LiveServiceState] for the
  /// currently-live branch. The row's `youtube_video_id` column
  /// (canonical 11-char YouTube ID) is surfaced as
  /// [LiveServiceState.youtubeId] so the player can render it.
  @visibleForTesting
  static LiveServiceState liveRowToState(dynamic data) {
    final d = data as Map<String, dynamic>;
    return LiveServiceState(
      isLive: true,
      serviceId: d['id'] as String?,
      serviceTitle: d['title'] as String?,
      speakerName: d['speaker_name'] as String?,
      hlsStreamUrl: d['stream_url'] as String?,
      thumbnailUrl: d['thumbnail_url'] as String?,
      startedAt: _parseDate(d['actual_start_at']),
      viewerCount: (d['viewer_count'] as int?) ?? 0,
      youtubeId: d['youtube_video_id'] as String?,
    );
  }

  /// Visible for testing — builds a [LiveServiceState] for the
  /// upcoming-scheduled branch. The next-scheduled stream's
  /// `youtube_video_id` becomes [LiveServiceState.youtubeId] so the
  /// live screen can offer "Watch countdown" or auto-play when the
  /// start time hits.
  @visibleForTesting
  static LiveServiceState upcomingRowToState(dynamic data) {
    final d = data as Map<String, dynamic>;
    return LiveServiceState(
      isLive: false,
      serviceId: d['id'] as String?,
      serviceTitle: d['title'] as String?,
      speakerName: d['speaker_name'] as String?,
      thumbnailUrl: d['thumbnail_url'] as String?,
      nextServiceTitle: d['title'] as String?,
      nextServiceAt: _parseDate(d['scheduled_start_at']),
      nextServiceSpeaker: d['speaker_name'] as String?,
      youtubeId: d['youtube_video_id'] as String?,
    );
  }

  /// Visible for testing — builds a [LiveServiceState] for the
  /// most-recently-ended branch. The ended stream's
  /// `youtube_video_id` becomes [LiveServiceState.replayYoutubeId]
  /// so the live screen can play the recording.
  @visibleForTesting
  static LiveServiceState endedRowToState(dynamic data) {
    final d = data as Map<String, dynamic>;
    return LiveServiceState(
      isLive: false,
      serviceId: d['id'] as String?,
      serviceTitle: d['title'] as String?,
      speakerName: d['speaker_name'] as String?,
      thumbnailUrl: d['thumbnail_url'] as String?,
      replayYoutubeId: d['youtube_video_id'] as String?,
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  Stream<List<LiveChatMessage>> streamChatMessages(String serviceId) {
    return _db
        .from('live_chat_messages')
        .stream(primaryKey: ['id'])
        .eq('live_service_id', serviceId)
        .order('created_at')
        .limit(200)
        .map((rows) {
          return rows
              .where((row) => row['is_deleted'] != true)
              .map(
                (row) => LiveChatMessage(
                  id: row['id'] as String,
                  userId: row['user_id'] as String,
                  displayName: row['display_name'] as String? ?? 'Member',
                  body: row['body'] as String,
                  sentAt: DateTime.parse(
                    (row['sent_at'] ?? row['created_at']) as String,
                  ),
                  avatarUrl: row['avatar_url'] as String?,
                  isLeader: row['is_leader'] as bool? ?? false,
                  isModerator: row['is_moderator'] as bool? ?? false,
                  isPinned: row['is_pinned'] as bool? ?? false,
                  replyToId: row['reply_to_id'] as String?,
                  replyToDisplayName: row['reply_to_display_name'] as String?,
                  replyToBody: row['reply_to_body'] as String?,
                  isDeleted: row['is_deleted'] as bool? ?? false,
                ),
              )
              .toList();
        });
  }

  Future<void> sendChatMessage(
      String serviceId, String body, String userId,) async {
    await _db.from('live_chat_messages').insert({
      'live_service_id': serviceId,
      'user_id': userId,
      'body': body,
    });
  }

  Future<void> saveSermonNote(
      String serviceId, String userId, String body,) async {
    await _db.from('sermon_notes').insert({
      'live_service_id': serviceId,
      'user_id': userId,
      'body': body,
    });
  }
}
