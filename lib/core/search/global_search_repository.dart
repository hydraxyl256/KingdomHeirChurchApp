// Kingdom Heir — Global Search Repository
//
// Cross-feature search across the public content of the church app:
// sermons, events, devotionals, prayer requests, news and members.
// Each domain has its own query against Supabase; results are merged
// in the screen layer with kind tags so the UI can group them.
//
// All queries are read-only and respect the existing RLS policies:
//   * published content is public
//   * prayer requests are public (anon can read, RLS allows it)
//   * profiles are public (for member directory)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/search/global_search_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final globalSearchRepositoryProvider =
    Provider<SupabaseGlobalSearchRepository>((ref) {
  return SupabaseGlobalSearchRepository(
    ref.watch(supabaseClientProvider),
  );
});

class SupabaseGlobalSearchRepository {
  SupabaseGlobalSearchRepository(this._client);
  final supabase.SupabaseClient _client;

  /// Run a global search across all content domains.
  Future<GlobalSearchResults> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return GlobalSearchResults.empty();

    final pattern = '%${_escape(q)}%';
    final items = <SearchResultItem>[];

    // Run all five queries in parallel — each is its own RLS-gated
    // SELECT, so a slow table never blocks the rest of the result set.
    await Future.wait([
      _searchSermons(pattern, items),
      _searchEvents(pattern, items),
      _searchDevotionals(pattern, items),
      _searchPrayerRequests(pattern, items),
      _searchNews(pattern, items),
    ]);

    return GlobalSearchResults(items: items, query: q);
  }

  Future<void> _searchSermons(String pattern, List<SearchResultItem> out) async {
    try {
      final response = await _client
          .from('sermons')
          .select('id, title, speaker, summary, thumbnail_url, published_at')
          .or(
            'title.ilike.$pattern,speaker.ilike.$pattern,summary.ilike.$pattern',
          )
          .eq('is_published', true)
          .order('published_at', ascending: false)
          .limit(5);
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        out.add(SearchResultItem(
          id: map['id'] as String,
          kind: SearchResultKind.sermon,
          title: (map['title'] as String?) ?? '',
          subtitle: (map['speaker'] as String?) ?? '',
          description: (map['summary'] as String?) ?? '',
          imageUrl: map['thumbnail_url'] as String?,
        ),);
      }
    } catch (_) {
      // Best-effort — if sermons table or columns differ, skip silently.
    }
  }

  Future<void> _searchEvents(String pattern, List<SearchResultItem> out) async {
    try {
      final response = await _client
          .from('events')
          .select('id, title, description, location, hero_image_url, start_at')
          .or(
            'title.ilike.$pattern,description.ilike.$pattern,location.ilike.$pattern',
          )
          .eq('status', 'published')
          .order('start_at', ascending: true)
          .limit(5);
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        out.add(SearchResultItem(
          id: map['id'] as String,
          kind: SearchResultKind.event,
          title: (map['title'] as String?) ?? '',
          subtitle: (map['location'] as String?) ?? '',
          description: (map['description'] as String?) ?? '',
          imageUrl: map['hero_image_url'] as String?,
        ),);
      }
    } catch (_) {/* skip */}
  }

  Future<void> _searchDevotionals(
    String pattern,
    List<SearchResultItem> out,
  ) async {
    try {
      final response = await _client
          .from('devotionals')
          .select('id, title, scripture_reference, summary, cover_image_url')
          .or(
            'title.ilike.$pattern,scripture_reference.ilike.$pattern,summary.ilike.$pattern',
          )
          .eq('is_published', true)
          .order('published_at', ascending: false)
          .limit(5);
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        out.add(SearchResultItem(
          id: map['id'] as String,
          kind: SearchResultKind.devotional,
          title: (map['title'] as String?) ?? '',
          subtitle: (map['scripture_reference'] as String?) ?? '',
          description: (map['summary'] as String?) ?? '',
          imageUrl: map['cover_image_url'] as String?,
        ),);
      }
    } catch (_) {/* skip */}
  }

  Future<void> _searchPrayerRequests(
    String pattern,
    List<SearchResultItem> out,
  ) async {
    try {
      final response = await _client
          .from('prayer_requests')
          .select('id, title, body, profiles!author_id(full_name)')
          .or('title.ilike.$pattern,body.ilike.$pattern')
          .order('created_at', ascending: false)
          .limit(5);
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        final authorRaw = map['profiles'];
        final author = authorRaw is Map
            ? (authorRaw['full_name'] as String?)
            : null;
        out.add(SearchResultItem(
          id: map['id'] as String,
          kind: SearchResultKind.prayer,
          title: (map['title'] as String?) ?? '',
          subtitle: author == null || author.isEmpty
              ? 'Community prayer'
              : 'Prayed for by $author',
          description: (map['body'] as String?) ?? '',
        ),);
      }
    } catch (_) {/* skip */}
  }

  Future<void> _searchNews(String pattern, List<SearchResultItem> out) async {
    try {
      final response = await _client
          .from('news_articles')
          .select('id, title, preview, body, cover_image_url, published_at')
          .or('title.ilike.$pattern,preview.ilike.$pattern,body.ilike.$pattern')
          .eq('is_published', true)
          .order('published_at', ascending: false)
          .limit(5);
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        out.add(SearchResultItem(
          id: map['id'] as String,
          kind: SearchResultKind.news,
          title: (map['title'] as String?) ?? '',
          subtitle: (map['preview'] as String?) ?? '',
          description: '',
          imageUrl: map['cover_image_url'] as String?,
        ),);
      }
    } catch (_) {/* skip */}
  }

  /// Escape % and _ for PostgREST ilike patterns.
  String _escape(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
