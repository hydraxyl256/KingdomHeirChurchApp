import 'package:kingdom_heir/features/live_service/domain/entities/live_service_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveServiceRepository {
  LiveServiceRepository(this._db);

  final SupabaseClient _db;

  Future<LiveServiceState> getActiveLiveService() async {
    try {
      final rows = await _db
          .from('live_services')
          .select()
          .eq('status', 'live')
          .limit(1);

      if (rows.isNotEmpty) {
        final data = rows.first;
        return LiveServiceState(
          isLive: true,
          serviceId: data['id'] as String?,
          serviceTitle: data['title'] as String?,
          speakerName: data['speaker_name'] as String?,
          hlsStreamUrl: data['stream_url'] as String?,
          thumbnailUrl: data['thumbnail_url'] as String?,
          startedAt: DateTime.parse(data['actual_start_at'] as String),
          viewerCount: data['viewer_count'] as int,
        );
      }

      // Fetch next scheduled
      final upcoming = await _db
          .from('live_services')
          .select()
          .eq('status', 'scheduled')
          .order('scheduled_start_at')
          .limit(1);

      if (upcoming.isNotEmpty) {
        final data = upcoming.first;
        return LiveServiceState(
          isLive: false,
          nextServiceTitle: data['title'] as String?,
          nextServiceAt: DateTime.parse(data['scheduled_start_at'] as String),
          nextServiceSpeaker: data['speaker_name'] as String?,
        );
      }

      return const LiveServiceState.idle();
    } catch (e) {
      return const LiveServiceState.idle();
    }
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

  Future<void> sendChatMessage(String serviceId, String body, String userId) async {
    await _db.from('live_chat_messages').insert({
      'live_service_id': serviceId,
      'user_id': userId,
      'body': body,
    });
  }

  Future<void> saveSermonNote(String serviceId, String userId, String body) async {
    await _db.from('sermon_notes').insert({
      'live_service_id': serviceId,
      'user_id': userId,
      'body': body,
    });
  }
}
