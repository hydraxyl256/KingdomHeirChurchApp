import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/volunteers/domain/entities/volunteer_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class VolunteerSupabaseService {
  VolunteerSupabaseService(this._client);
  final supabase.SupabaseClient _client;

  Future<Either<String, List<VolunteerOpportunity>>> getOpportunities() async {
    try {
      final data = await _client
          .from('volunteer_opportunities')
          .select()
          .eq('is_active', true)
          .order('created_at');
      return right((data as List<dynamic>)
          .map((e) => VolunteerOpportunity.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<VolunteerApplication>>> getMyApplications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Not authenticated.');

      final data = await _client
          .from('volunteer_applications')
          .select()
          .eq('user_id', user.id);
      return right((data as List<dynamic>)
          .map((e) => VolunteerApplication.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, VolunteerApplication>> applyForOpportunity(
      String opportunityId,) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Not authenticated.');

      final data = await _client
          .from('volunteer_applications')
          .insert({
            'opportunity_id': opportunityId,
            'user_id': user.id,
          })
          .select()
          .single();

      return right(VolunteerApplication.fromJson(data));
    } catch (e) {
      return left(e.toString());
    }
  }
}
