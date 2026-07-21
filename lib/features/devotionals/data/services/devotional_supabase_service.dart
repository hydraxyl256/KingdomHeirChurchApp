import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class DevotionalSupabaseService {
  DevotionalSupabaseService(this._client);
  final supabase.SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  Future<Either<String, Devotional?>> getDailyDevotional(
      {String languageCode = 'en',}) async {
    try {
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final data = await _client.rpc<List<dynamic>>('get_devotionals_localized',
          params: {'p_lang': languageCode},);

      if (data.isNotEmpty) {
        // Find the one for today
        final todayDevotional = data.firstWhere(
          (d) => (d as Map<String, dynamic>)['scheduled_for'] == todayStr,
          orElse: () => null,
        );

        if (todayDevotional != null) {
          return right(
              Devotional.fromJson(todayDevotional as Map<String, dynamic>),);
        }

        // Fallback to latest published if none scheduled for today
        final latest = data.first;
        return right(Devotional.fromJson(latest as Map<String, dynamic>));
      }
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<Devotional>>> getPreviousDevotionals(
      {String languageCode = 'en',}) async {
    try {
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final data = await _client.rpc<List<dynamic>>('get_devotionals_localized',
          params: {'p_lang': languageCode},);

      final previous = data
          .map((e) => Devotional.fromJson(e as Map<String, dynamic>))
          .where((d) => d.scheduledFor.compareTo(DateTime.parse(todayStr)) < 0)
          .take(20)
          .toList();
      return right(previous);

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
      return right(
        (data as List<dynamic>)
            .map(
                (e) => DevotionalReflection.fromJson(e as Map<String, dynamic>),)
            .toList(),
      );
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> addReflection(
    String body, {
    String? devotionalId,
  }) async {
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
