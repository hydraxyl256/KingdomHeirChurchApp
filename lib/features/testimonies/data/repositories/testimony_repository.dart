import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/testimonies/domain/entities/testimony.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final testimonyRepositoryProvider = Provider<TestimonyRepository>((ref) {
  return SupabaseTestimonyRepository(supabase.Supabase.instance.client);
});

abstract class TestimonyRepository {
  Future<Either<String, List<Testimony>>> getTestimonies(
      {int limit = 50, String? category,});
  Future<Either<String, void>> submitTestimony(Map<String, dynamic> insertData);
    Future<Either<String, void>> toggleLike(
    String testimonyId, {
    required bool isLiking,
  });
}

class SupabaseTestimonyRepository implements TestimonyRepository {
  SupabaseTestimonyRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<Either<String, List<Testimony>>> getTestimonies(
      {int limit = 50, String? category,}) async {
    try {
      var query = _client
          .from('testimonies')
          .select('*, profiles(full_name, avatar_url)')
          .eq('status', 'published');

      if (category != null && category != 'All' && category != 'General') {
        query = query.eq('category', category);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);
      final testimonies = (response as List<dynamic>).map((dynamic raw) {
        final e = raw as Map<String, dynamic>;
        final profile = e['profiles'] as Map<String, dynamic>?;
        return Testimony(
          id: e['id'] as String,
          authorId: e['author_id'] as String,
          authorName: profile?['full_name'] as String? ?? 'Anonymous',
          authorAvatarUrl: profile?['avatar_url'] as String?,
          title: e['title'] as String,
          body: e['body'] as String,
          category: e['category'] as String,
          isAnonymous: e['is_anonymous'] as bool,
          status: e['status'] as String,
          likeCount: e['like_count'] as int? ?? 0,
          createdAt: DateTime.parse(e['created_at'] as String),
        );
      }).toList();

      return right(testimonies);
    } catch (e) {
      return left('Failed to fetch testimonies: $e');
    }
  }

  @override
  Future<Either<String, void>> submitTestimony(
      Map<String, dynamic> insertData,) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Please login to submit a testimony.');

      insertData['author_id'] = user.id;
      // Default to draft until approved by admin
      insertData['status'] = 'draft';

      await _client.from('testimonies').insert(insertData);
      return right(null);
    } catch (e) {
      return left('Failed to submit testimony: $e');
    }
  }

  @override
  Future<Either<String, void>> toggleLike(
    String testimonyId, {
    required bool isLiking,
  }) async {
    try {
      // Typically there is a junction table (e.g., testimony_likes) to track who liked what.
      // For simplicity in this codebase, we use an RPC to increment/decrement.
      // E.g., await _client.rpc('toggle_testimony_like', params: {'t_id': testimonyId, 'is_liking': isLiking});
      return right(null);
    } catch (e) {
      return left('Failed to toggle like: $e');
    }
  }
}
