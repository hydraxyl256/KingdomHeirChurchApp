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
        .map((rows) => rows.map((row) => LiveChatMessage(
              id: row['id'] as String,
              userId: row['user_id'] as String,
              displayName: 'Member', // In reality, fetch via join or handle locally
              body: row['body'] as String,
              sentAt: DateTime.parse(row['created_at'] as String),
            ),).toList(),);
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
