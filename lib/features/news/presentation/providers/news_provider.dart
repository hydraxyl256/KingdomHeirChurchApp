import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/news/data/repositories/news_repository.dart';
import 'package:kingdom_heir/features/news/data/services/news_supabase_service.dart';
import 'package:kingdom_heir/features/news/domain/entities/news_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Services
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(NewsSupabaseService(Supabase.instance.client));
});

// Providers
final pinnedAnnouncementProvider = FutureProvider<NewsArticle?>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  final result = await repo.getPinnedAnnouncement();
  return result.fold((l) => throw Exception(l), (r) => r);
});

final newsArticlesProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  final result = await repo.getArticles(
      isPinned: false,); // Fetch everything but the pinned one
  return result.fold((l) => throw Exception(l), (r) => r);
});
