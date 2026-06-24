import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminModerationRepositoryProvider = Provider((ref) {
  return AdminModerationRepository(ref.watch(supabaseClientProvider));
});

class AdminModerationRepository {
  AdminModerationRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<Map<String, dynamic>>> getPendingTestimonies() async {
    final response = await _supabase
        .from('testimonies')
        .select('*, profiles(full_name)')
        .eq('is_approved', false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getPendingPrayers() async {
    final response = await _supabase
        .from('prayer_requests')
        .select('*, profiles(full_name)')
        .eq('is_approved', false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> approveTestimony(String id) async {
    await _supabase.from('testimonies').update({
      'is_approved': true,
      'status': 'published',
    }) // Sync both for legacy
        .eq('id', id);
    await _logAction('APPROVE_TESTIMONY', id, {});
  }

  Future<void> rejectTestimony(String id) async {
    await _supabase.from('testimonies').delete().eq('id', id);
    await _logAction('REJECT_TESTIMONY', id, {});
  }

  Future<void> approvePrayer(String id) async {
    await _supabase
        .from('prayer_requests')
        .update({'is_approved': true, 'status': 'active'}).eq('id', id);
    await _logAction('APPROVE_PRAYER', id, {});
  }

  Future<void> rejectPrayer(String id) async {
    await _supabase.from('prayer_requests').delete().eq('id', id);
    await _logAction('REJECT_PRAYER', id, {});
  }

  Future<void> _logAction(
      String action, String targetId, Map<String, dynamic> details,) async {
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
