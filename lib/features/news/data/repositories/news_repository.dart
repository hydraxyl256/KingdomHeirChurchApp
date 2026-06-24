import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/news/data/services/news_supabase_service.dart';
import 'package:kingdom_heir/features/news/domain/entities/news_models.dart';

abstract class NewsRepository {
  Future<Either<String, List<NewsCategory>>> getCategories();
  Future<Either<String, List<NewsArticle>>> getArticles(
      {String? categoryId, bool? isPinned, bool? isFeatured,});
  Future<Either<String, NewsArticle?>> getPinnedAnnouncement();
  Future<Either<String, void>> recordArticleView(String articleId);
  Future<Either<String, void>> recordArticleShare(String articleId);
}

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(this._service);
  final NewsSupabaseService _service;

  @override
  Future<Either<String, List<NewsCategory>>> getCategories() =>
      _service.getCategories();

  @override
  Future<Either<String, List<NewsArticle>>> getArticles(
          {String? categoryId, bool? isPinned, bool? isFeatured,}) =>
      _service.getArticles(
          categoryId: categoryId, isPinned: isPinned, isFeatured: isFeatured,);

  @override
  Future<Either<String, NewsArticle?>> getPinnedAnnouncement() =>
      _service.getPinnedAnnouncement();

  @override
  Future<Either<String, void>> recordArticleView(String articleId) =>
      _service.recordArticleView(articleId);

  @override
  Future<Either<String, void>> recordArticleShare(String articleId) =>
      _service.recordArticleShare(articleId);
}
