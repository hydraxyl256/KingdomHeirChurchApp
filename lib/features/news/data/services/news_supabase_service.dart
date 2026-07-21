import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/news/domain/entities/news_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class NewsSupabaseService {
  NewsSupabaseService(this._client);
  final supabase.SupabaseClient _client;

  Future<Either<String, List<NewsCategory>>> getCategories() async {
    try {
      final data = await _client.from('news_categories').select().order('name');
      return right(
        (data as List<dynamic>)
            .map((e) => NewsCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<NewsArticle>>> getArticles({
    String? categoryId,
    bool? isPinned,
    bool? isFeatured,
    String languageCode = 'en',
  }) async {
    try {
      final data = await _client.rpc<List<dynamic>>(
        'get_news_articles_localized',
        params: {
          'p_lang': languageCode,
          'p_cat': categoryId,
          'p_pinned': isPinned,
          'p_featured': isFeatured,
        },
      );

      return right(
        data
            .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, NewsArticle?>> getPinnedAnnouncement(
      {String languageCode = 'en',}) async {
    try {
      final data = await _client.rpc<List<dynamic>>(
        'get_news_articles_localized',
        params: {
          'p_lang': languageCode,
          'p_pinned': true,
        },
      );

      if (data.isNotEmpty) {
        return right(NewsArticle.fromJson(data.first as Map<String, dynamic>));
      }
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> recordArticleView(String articleId) async {
    try {
      await _client.rpc<void>(
        'increment_article_view',
        params: {'article_uuid': articleId},
      );
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> recordArticleShare(String articleId) async {
    try {
      await _client.rpc<void>(
        'increment_article_share',
        params: {'article_uuid': articleId},
      );
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }
}
