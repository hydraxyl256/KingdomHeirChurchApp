import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class DevotionalSupabaseService {
  DevotionalSupabaseService(this._client);
  final supabase.SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  Future<Either<String, Devotional?>> getDailyDevotional() async {
    try {
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final data = await _client
          .from('devotionals')
          .select()
          .eq('status', 'published')
          .eq('scheduled_for', todayStr)
          .maybeSingle();

      if (data == null) {
        // Fallback to the latest published devotional if none scheduled for today
        final latest = await _client
            .from('devotionals')
            .select()
            .eq('status', 'published')
            .order('scheduled_for', ascending: false)
            .limit(1)
            .maybeSingle();
        if (latest == null) return right(null);
        return right(Devotional.fromJson(latest));
      }
      return right(Devotional.fromJson(data));
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<Devotional>>> getPreviousDevotionals() async {
    try {
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final data = await _client
          .from('devotionals')
          .select()
          .eq('status', 'published')
          .lt('scheduled_for', todayStr)
          .order('scheduled_for', ascending: false)
          .limit(20);

      return right((data as List<dynamic>)
          .map((e) => Devotional.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<DevotionalReflection>>> getReflections() async {
    try {
      final data = await _client
          .from('devotional_reflections')
          .select()
          .order('created_at', ascending: false);
      return right((data as List<dynamic>)
          .map((e) => DevotionalReflection.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> addReflection(String body,
      {String? devotionalId,}) async {
    try {
      await _client.from('devotional_reflections').insert({
        'user_id': _userId,
        'body': body,
        if (devotionalId != null) 'devotional_id': devotionalId,
      });
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }
}
