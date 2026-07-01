// Kingdom Heir — Global Search Providers
//
// AsyncNotifier that runs a debounced query across all content domains
// via the [GlobalSearchRepository]. Re-runs on every `search()` call
// with the latest query string.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/search/global_search_models.dart';
import 'package:kingdom_heir/core/search/global_search_repository.dart';

final globalSearchQueryProvider = StateProvider<String>((_) => '');

final globalSearchProvider =
    AsyncNotifierProvider<GlobalSearchNotifier, GlobalSearchResults>(
  GlobalSearchNotifier.new,
);

class GlobalSearchNotifier extends AsyncNotifier<GlobalSearchResults> {
  Timer? _debounce;

  @override
  Future<GlobalSearchResults> build() async {
    // Invalidate the previous debounce on rebuild (e.g. provider disposal).
    ref.onDispose(() => _debounce?.cancel());
    return const GlobalSearchResults(items: [], query: '');
  }

  /// Run a search for [query]. Internal 250ms debounce coalesces typing.
  Future<void> search(String query) async {
    _debounce?.cancel();
    final completer = Completer<void>();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repo = ref.read(globalSearchRepositoryProvider);
        return repo.search(query);
      });
      completer.complete();
    });
    return completer.future;
  }

  Future<void> clear() async {
    _debounce?.cancel();
    state = const AsyncData(GlobalSearchResults(items: [], query: ''));
    ref.read(globalSearchQueryProvider.notifier).state = '';
  }
}
