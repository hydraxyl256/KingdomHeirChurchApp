import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/admin/data/repositories/admin_content_repository.dart';

final adminSermonsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminContentRepositoryProvider);
  return repo.getSermons();
});

class AdminSermonsScreen extends ConsumerWidget {
  const AdminSermonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonsAsync = ref.watch(adminSermonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermon Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminSermonsProvider),
          ),
          FilledButton.icon(
            onPressed: () {
              // TODO(kingdom-heir): Navigate to create sermon form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Sermon coming soon')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Sermon'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: sermonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (sermons) {
          if (sermons.isEmpty) {
            return const Center(child: Text('No sermons found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sermons.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final sermon = sermons[index];
              final status = sermon['status'] as String? ?? 'draft';
              final isPublished = status == 'published';
              final thumbnailUrl = sermon['thumbnail_url'] as String?;
              final title = sermon['title'] as String? ?? 'Untitled';
              final speakerName =
                  sermon['speaker_name']?.toString() ?? 'Unknown';
              final preachedOn =
                  sermon['preached_on']?.toString() ?? 'Unknown date';
              final sermonId = sermon['id'] as String? ?? '';

              return ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    image: thumbnailUrl != null
                        ? DecorationImage(
                            image: NetworkImage(thumbnailUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: thumbnailUrl == null
                      ? const Icon(Icons.video_library)
                      : null,
                ),
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold),),
                subtitle: Text('$speakerName • Preached: $preachedOn'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(status.toUpperCase()),
                      backgroundColor: isPublished
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.warning.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isPublished
                            ? AppColors.success
                            : AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    PopupMenuButton<String>(
                      onSelected: (val) async {
                        final repo = ref.read(adminContentRepositoryProvider);
                        if (val == 'toggle_status') {
                          final newStatus = isPublished ? 'draft' : 'published';
                          await repo.toggleSermonStatus(sermonId, newStatus);
                          ref.invalidate(adminSermonsProvider);
                        } else if (val == 'delete') {
                          // In a real app, show confirmation dialog
                          await repo.deleteSermon(sermonId);
                          ref.invalidate(adminSermonsProvider);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle_status',
                          child: Text(isPublished ? 'Unpublish' : 'Publish'),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: AppColors.error),),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
