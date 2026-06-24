import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/news/domain/entities/news_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class NewsSupabaseService {
  NewsSupabaseService(this._client);
  final supabase.SupabaseClient _client;

  Future<Either<String, List<NewsCategory>>> getCategories() async {
    try {
      final data = await _client.from('news_categories').select().order('name');
      return right((data as List<dynamic>)
          .map((e) => NewsCategory.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, List<NewsArticle>>> getArticles(
      {String? categoryId, bool? isPinned, bool? isFeatured,}) async {
    try {
      var query = _client
          .from('news_articles')
          .select('*, news_categories(name)')
          .eq('status', 'published');

      if (categoryId != null) query = query.eq('category_id', categoryId);
      if (isPinned != null) query = query.eq('is_pinned', isPinned);
      if (isFeatured != null) query = query.eq('is_featured', isFeatured);

      final data = await query.order('published_at', ascending: false);
      return right((data as List<dynamic>)
          .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, NewsArticle?>> getPinnedAnnouncement() async {
    try {
      final data = await _client
          .from('news_articles')
          .select('*, news_categories(name)')
          .eq('status', 'published')
          .eq('is_pinned', true)
          .order('published_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (data == null) return right(null);
      return right(NewsArticle.fromJson(data));
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> recordArticleView(String articleId) async {
    try {
      await _client.rpc<void>('increment_article_view',
          params: {'article_uuid': articleId},);
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> recordArticleShare(String articleId) async {
    try {
      await _client.rpc<void>('increment_article_share',
          params: {'article_uuid': articleId},);
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }
}
