// Kingdom Heir — Sermon Downloads Screen
//
// Full list of downloaded audio sermons. Top: storage indicator. Below:
// a list of download tiles. Empty state nudges the user to the library.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/sermons/data/mock/mock_sermons_seed.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_download.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_downloads_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/downloads/download_storage_indicator.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/downloads/download_tile.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermons_empty_state.dart';

class SermonDownloadsScreen extends ConsumerWidget {
  const SermonDownloadsScreen({super.key});

  int _totalBytes(List<SermonDownload> list) =>
      list.fold(0, (sum, d) => sum + d.sizeBytes);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadsListProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: downloadsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return SermonsEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'No downloads yet',
              description:
                  'Save sermons for offline listening — perfect for travel or no signal.',
              actionLabel: 'Browse library',
              onAction: () => context.push('/home/sermons/library'),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DownloadStorageIndicator(
                  totalBytes: _totalBytes(list),
                  downloadCount: list.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final d = list[i];
                      final sermon = MockSermonSeed.findSermon(d.sermonId);
                      return DownloadTile(
                        download: d,
                        sermon: sermon,
                        onRemove: () => ref
                            .read(downloadsListProvider.notifier)
                            .removeDownload(d.sermonId),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(downloadsListProvider),
        ),
      ),
    );
  }
}
