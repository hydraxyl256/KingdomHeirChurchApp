import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminMembersRepositoryProvider = Provider((ref) {
  return AdminMembersRepository(ref.watch(supabaseClientProvider));
});

class AdminMembersRepository {
  AdminMembersRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<Map<String, dynamic>>> getMembers() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('is_deleted', false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateRole(String userId, String newRole) async {
    await _supabase.from('profiles').update({'role': newRole}).eq('id', userId);

    await _logAction('UPDATE_ROLE', userId, {'new_role': newRole});
  }

  Future<void> suspendUser(String userId) async {
    // Soft delete
    await _supabase
        .from('profiles')
        .update({'is_deleted': true}).eq('id', userId);

    await _logAction('SUSPEND_USER', userId, {});
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
    } catch (_) {} // Fail silently for audit logs
  }
}
