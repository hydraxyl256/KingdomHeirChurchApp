// Kingdom Heir — Sermon Downloads Provider
//
// AsyncNotifier backed by SharedPreferences. Reads / writes the
// `sermon_downloads_v1` list and exposes add / remove mutations.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/features/sermons/domain/entities/sermon_download.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

final downloadsListProvider =
    AsyncNotifierProvider<DownloadsNotifier, List<SermonDownload>>(
  DownloadsNotifier.new,
);

class DownloadsNotifier extends AsyncNotifier<List<SermonDownload>> {
  @override
  Future<List<SermonDownload>> build() async {
    final result = await ref.read(sermonsRepositoryProvider).getDownloads();
    return result.fold((_) => <SermonDownload>[], (r) => r);
  }

  Future<void> addDownload({
    required String sermonId,
    required String localPath,
    required int sizeBytes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(sermonsRepositoryProvider).registerDownload(
            sermonId: sermonId,
            localPath: localPath,
            sizeBytes: sizeBytes,
          );
      final result = await ref.read(sermonsRepositoryProvider).getDownloads();
      return result.fold((_) => <SermonDownload>[], (r) => r);
    });
  }

  Future<void> removeDownload(String sermonId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(sermonsRepositoryProvider).removeDownload(sermonId);
      final result = await ref.read(sermonsRepositoryProvider).getDownloads();
      return result.fold((_) => <SermonDownload>[], (r) => r);
    });
  }
}

/// Top-N downloads (used by the Home shortcut row).
final downloadsShortcutProvider = Provider<List<SermonDownload>>((ref) {
  final list = ref.watch(downloadsListProvider).value ?? const [];
  return list.take(3).toList();
});
