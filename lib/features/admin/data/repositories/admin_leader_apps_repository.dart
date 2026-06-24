import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminLeaderAppsRepositoryProvider = Provider((ref) {
  return AdminLeaderAppsRepository(ref.watch(supabaseClientProvider));
});

class AdminLeaderAppsRepository {
  AdminLeaderAppsRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<Map<String, dynamic>>> getPendingApplications() async {
    final response = await _supabase
        .from('leader_applications')
        .select('*, profiles(full_name)')
        .eq('status', 'PENDING')
        .order('submitted_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> reviewApplication(String id, String newStatus) async {
    // newStatus: APPROVED, REJECTED
    await _supabase
        .from('leader_applications')
        .update({'status': newStatus}).eq('id', id);

    final adminId = _supabase.auth.currentUser?.id;
    if (adminId != null) {
      await _supabase.from('admin_audit_logs').insert({
        'admin_id': adminId,
        'action': 'REVIEW_LEADER_APP_$newStatus',
        'target_id': id,
        'details': <String, dynamic>{},
      });
    }
  }
}
