// Kingdom Heir — Global Search Domain Models
//
// Pure Dart value types — no Flutter, no Supabase.

import 'package:flutter/foundation.dart';

enum SearchResultKind {
  sermon,
  event,
  devotional,
  prayer,
  news,
  member,
  page,
}

@immutable
class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.description,
    this.imageUrl,
  });

  final String id;
  final SearchResultKind kind;
  final String title;
  final String subtitle;
  final String description;
  final String? imageUrl;
}

@immutable
class GlobalSearchResults {
  const GlobalSearchResults({
    required this.items,
    required this.query,
  });

  factory GlobalSearchResults.empty() =>
      const GlobalSearchResults(items: [], query: '');

  final List<SearchResultItem> items;
  final String query;

  bool get isEmpty => items.isEmpty;
  int get total => items.length;

  /// Group items by kind in the order they should be shown in the UI.
  Map<SearchResultKind, List<SearchResultItem>> grouped() {
    final map = <SearchResultKind, List<SearchResultItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.kind, () => []).add(item);
    }
    return map;
  }
}
