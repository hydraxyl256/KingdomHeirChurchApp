import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/bookstore/domain/entities/bookstore_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class BookstoreSupabaseService {
  BookstoreSupabaseService(this._client);
  final supabase.SupabaseClient _client;

  Future<Either<String, List<BookstoreCategory>>> getCategories() async {
    try {
      final data = await _client
          .from('bookstore_categories')
          .select()
          .order('sort_order', ascending: true);
      return right(
        (data as List<dynamic>)
            .map((e) => BookstoreCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<BookstoreProduct>>> getProducts({
    String? categoryId,
  }) async {
    try {
      var query =
          _client.from('bookstore_products').select().eq('is_active', true);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      final data = await query;
      return right(
        (data as List<dynamic>)
            .map((e) => BookstoreProduct.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return left(e.toString());
    }
  }
}
