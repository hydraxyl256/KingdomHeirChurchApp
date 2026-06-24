import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/kids/domain/entities/kids_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class KidsSupabaseService {
  KidsSupabaseService(this._client);
  final supabase.SupabaseClient _client;

  Future<Either<String, List<Kid>>> getMyKids() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Not authenticated.');
      final data = await _client.from('kids').select().order('first_name');
      return right((data as List<dynamic>)
          .map((e) => Kid.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, KidsSession?>> getActiveSession() async {
    try {
      final data = await _client
          .from('kids_sessions')
          .select()
          .eq('is_active', true)
          .eq('session_date', DateTime.now().toIso8601String().split('T')[0])
          .maybeSingle();
      if (data == null) return right(null);
      return right(KidsSession.fromJson(data));
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<KidsCheckin>>> getMyCheckins(
      String sessionId,) async {
    try {
      final data = await _client
          .from('kids_checkins')
          .select()
          .eq('session_id', sessionId);
      return right((data as List<dynamic>)
          .map((e) => KidsCheckin.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, KidsCheckin>> checkInKid(
      String kidId, String sessionId,) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Not authenticated.');

      // Generate a random 4-digit code (e.g. KH-4921)
      final code = 'KH-${Random().nextInt(9000) + 1000}';

      final data = await _client
          .from('kids_checkins')
          .insert({
            'kid_id': kidId,
            'session_id': sessionId,
            'checked_in_by': user.id,
            'safety_code': code,
          })
          .select()
          .single();

      return right(KidsCheckin.fromJson(data));
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, KidsCheckin>> checkOutKid(String checkinId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Not authenticated.');

      final data = await _client
          .from('kids_checkins')
          .update({
            'checked_out_at': DateTime.now().toIso8601String(),
            'checked_out_by': user.id,
          })
          .eq('id', checkinId)
          .select()
          .single();

      return right(KidsCheckin.fromJson(data));
    } catch (e) {
      return left(e.toString());
    }
  }
}
