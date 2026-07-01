import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/prayer_requests/data/models/prayer_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return SupabasePrayerRepository(supabase.Supabase.instance.client);
});

abstract class PrayerRepository {
  /// Fetches a paginated list of prayer requests.
  Future<Either<String, List<PrayerRequestModel>>> getPrayerRequests({
    int limit = 50,
  });

  /// Submits a new prayer request.
  Future<Either<String, void>> submitPrayerRequest(
    Map<String, dynamic> insertData,
  );

  /// Toggles the 'prayed' status for a specific request.
  Future<Either<String, void>> togglePrayerIntercession(
    String prayerRequestId, {
    required bool isPraying,
  });

  /// Subscribes to real-time changes on the prayer_requests table.
  Stream<List<Map<String, dynamic>>> streamPrayerRequests();

  /// Fetches the IDs of requests the current user has prayed for.
  Future<List<String>> getIntercededPrayerIds();
}

class SupabasePrayerRepository implements PrayerRepository {
  SupabasePrayerRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<Either<String, List<PrayerRequestModel>>> getPrayerRequests({
    int limit = 50,
  }) async {
    try {
      // Explicit relationship hint `profiles!author_id(...)` tells PostgREST
      // exactly which foreign key to use for the embedded join. Without the
      // hint, PostgREST can return "Could not find a relationship between
      // 'prayer_requests' and 'profiles' in the schema cache" if there are
      // any ambiguities (e.g. multiple FKs in the schema or the second
      // dashboard-only prayer_requests table shadowing the relationship).
      final response = await _client
          .from('prayer_requests')
          .select('*, profiles!author_id(full_name, avatar_url)')
          .order('created_at', ascending: false)
          .limit(limit);

      final requests = (response as List)
          .map((e) => PrayerRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return right(requests);
    } catch (e) {
      return left('Failed to load prayer requests: $e');
    }
  }

  @override
  Future<Either<String, void>> submitPrayerRequest(
    Map<String, dynamic> insertData,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return left('You must be logged in to submit a prayer request.');
      }

      insertData['author_id'] = user.id;

      await _client.from('prayer_requests').insert(insertData);

      // Note: Edge functions / Postgres triggers would handle the push notifications
      // for 'leaders_only' visibility.

      return right(null);
    } catch (e) {
      return left('Failed to submit prayer request: $e');
    }
  }

  @override
  Future<Either<String, void>> togglePrayerIntercession(
    String prayerRequestId, {
    required bool isPraying,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Please login to pray for requests.');

      if (isPraying) {
        await _client.from('prayer_intercessions').upsert(
          {
            'prayer_request_id': prayerRequestId,
            'user_id': user.id,
          },
          onConflict: 'prayer_request_id, user_id',
        );
      } else {
        await _client.from('prayer_intercessions').delete().match({
          'prayer_request_id': prayerRequestId,
          'user_id': user.id,
        });
      }

      return right(null);
    } catch (e) {
      return left('Failed to update prayer status: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamPrayerRequests() {
    return _client
        .from('prayer_requests')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .limit(50);
  }

  @override
  Future<List<String>> getIntercededPrayerIds() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('prayer_intercessions')
          .select('prayer_request_id')
          .eq('user_id', user.id);

      return (response as List<dynamic>)
          .map((dynamic e) {
            return (e as Map<String, dynamic>)['prayer_request_id'] as String;
          })
          .toList();
    } catch (e) {
      return [];
    }
  }
}
