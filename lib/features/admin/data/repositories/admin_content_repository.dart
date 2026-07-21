import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminContentRepositoryProvider = Provider((ref) {
  return AdminContentRepository(ref.watch(supabaseClientProvider));
});

class AdminContentRepository {
  AdminContentRepository(this._supabase);
  final SupabaseClient _supabase;

  // -- Sermons --
  Future<List<Map<String, dynamic>>> getSermons() async {
    final response = await _supabase
        .from('sermons')
        .select()
        .order('preached_on', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> toggleSermonStatus(String id, String newStatus) async {
    await _supabase.from('sermons').update({'status': newStatus}).eq('id', id);
    await _logAction('TOGGLE_SERMON_STATUS', id, {'new_status': newStatus});
  }

  Future<void> deleteSermon(String id) async {
    await _supabase.from('sermons').delete().eq('id', id);
    await _logAction('DELETE_SERMON', id, {});
  }

  // -- Events --
  Future<List<Map<String, dynamic>>> getEvents() async {
    final response = await _supabase
        .from('events')
        .select()
        .order('start_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> toggleEventStatus(String id, String newStatus) async {
    await _supabase.from('events').update({'status': newStatus}).eq('id', id);
    await _logAction('TOGGLE_EVENT_STATUS', id, {'new_status': newStatus});
  }

  Future<void> deleteEvent(String id) async {
    await _supabase.from('events').delete().eq('id', id);
    await _logAction('DELETE_EVENT', id, {});
  }

  Future<void> _logAction(
    String action,
    String targetId,
    Map<String, dynamic> details,
  ) async {
    try {
      final adminId = _supabase.auth.currentUser?.id;
      if (adminId == null) return;

      await _supabase.from('admin_audit_logs').insert({
        'admin_id': adminId,
        'action': action,
        'target_id': targetId,
        'details': details,
      });
    } catch (_) {}
  }
}
