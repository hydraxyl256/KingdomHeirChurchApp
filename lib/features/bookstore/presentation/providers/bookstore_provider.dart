import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/bookstore/data/repositories/bookstore_repository.dart';
import 'package:kingdom_heir/features/bookstore/data/services/bookstore_supabase_service.dart';
import 'package:kingdom_heir/features/bookstore/domain/entities/bookstore_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final bookstoreRepositoryProvider = Provider<BookstoreRepository>((ref) {
  return BookstoreRepositoryImpl(
      BookstoreSupabaseService(Supabase.instance.client),);
});

final bookstoreCategoriesProvider =
    FutureProvider<List<BookstoreCategory>>((ref) async {
  final repo = ref.watch(bookstoreRepositoryProvider);
  final result = await repo.getCategories();
  return result.fold((l) => throw Exception(l), (r) => r);
});

final bookstoreSelectedCategoryProvider = StateProvider<String?>((ref) => null);

final bookstoreProductsProvider =
    FutureProvider<List<BookstoreProduct>>((ref) async {
  final categoryId = ref.watch(bookstoreSelectedCategoryProvider);
  final repo = ref.watch(bookstoreRepositoryProvider);
  final result = await repo.getProducts(categoryId: categoryId);
  return result.fold((l) => throw Exception(l), (r) => r);
});
