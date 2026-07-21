import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/bookstore/data/services/bookstore_supabase_service.dart';
import 'package:kingdom_heir/features/bookstore/domain/entities/bookstore_models.dart';

abstract class BookstoreRepository {
  Future<Either<String, List<BookstoreCategory>>> getCategories();
  Future<Either<String, List<BookstoreProduct>>> getProducts({
    String? categoryId,
  });
}

class BookstoreRepositoryImpl implements BookstoreRepository {
  BookstoreRepositoryImpl(this._service);
  final BookstoreSupabaseService _service;

  @override
  Future<Either<String, List<BookstoreCategory>>> getCategories() =>
      _service.getCategories();

  @override
  Future<Either<String, List<BookstoreProduct>>> getProducts({
    String? categoryId,
  }) =>
      _service.getProducts(categoryId: categoryId);
}
