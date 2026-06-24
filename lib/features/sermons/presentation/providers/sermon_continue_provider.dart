// Kingdom Heir — Continue Watching Provider
//
// AsyncNotifier backed by SharedPreferences. Reads / writes the
// `sermon_continue_v1` continue-watching list.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/features/sermons/domain/entities/sermon_continue_item.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

final continueWatchingListProvider =
    AsyncNotifierProvider<ContinueWatchingNotifier, List<SermonContinueItem>>(
  ContinueWatchingNotifier.new,
);

class ContinueWatchingNotifier extends AsyncNotifier<List<SermonContinueItem>> {
  @override
  Future<List<SermonContinueItem>> build() async {
    final result =
        await ref.read(sermonsRepositoryProvider).getContinueWatching();
    return result.fold((_) => <SermonContinueItem>[], (r) => r);
  }

  /// Record the latest playback position. Inserts a new entry or
  /// updates the existing one in-place.
  Future<void> recordProgress({
    required String sermonId,
    required int positionSeconds,
    required bool isCompleted,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(sermonsRepositoryProvider).recordWatchProgress(
            sermonId: sermonId,
            positionSeconds: positionSeconds,
            isCompleted: isCompleted,
          );
      final result =
          await ref.read(sermonsRepositoryProvider).getContinueWatching();
      return result.fold((_) => <SermonContinueItem>[], (r) => r);
    });
  }

  Future<void> removeItem(String sermonId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Persist by recording zero position — repo removes the entry.
      await ref.read(sermonsRepositoryProvider).recordWatchProgress(
            sermonId: sermonId,
            positionSeconds: 0,
            isCompleted: true,
          );
      final result =
          await ref.read(sermonsRepositoryProvider).getContinueWatching();
      return result.fold((_) => <SermonContinueItem>[], (r) => r);
    });
  }
}
