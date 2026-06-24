import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/admin/data/repositories/admin_moderation_repository.dart';

final adminModerationProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, type) async {
  final repo = ref.watch(adminModerationRepositoryProvider);
  if (type == 'testimonies') {
    return repo.getPendingTestimonies();
  } else {
    return repo.getPendingPrayers();
  }
});

class AdminModerationScreen extends StatelessWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Moderation Queue'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Testimonies'),
              Tab(text: 'Pending Prayers'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TestimonyModerationTab(),
            _PrayerModerationTab(),
          ],
        ),
      ),
    );
  }
}

class _TestimonyModerationTab extends ConsumerWidget {
  const _TestimonyModerationTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(adminModerationProvider('testimonies'));

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No pending testimonies!'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final itemId = item['id'] as String? ?? '';
            final title = (item['title'] as String?) ?? '';
            final body = (item['body'] as String?) ?? '';
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18,),),
                    const SizedBox(height: 8),
                    Text(body),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final repo =
                                ref.read(adminModerationRepositoryProvider);
                            await repo.rejectTestimony(itemId);
                            ref.invalidate(
                                adminModerationProvider('testimonies'),);
                          },
                          icon: const Icon(Icons.close, color: AppColors.error),
                          label: const Text('Reject',
                              style: TextStyle(color: AppColors.error),),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () async {
                            final repo =
                                ref.read(adminModerationRepositoryProvider);
                            await repo.approveTestimony(itemId);
                            ref.invalidate(
                                adminModerationProvider('testimonies'),);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Approve & Publish'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PrayerModerationTab extends ConsumerWidget {
  const _PrayerModerationTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(adminModerationProvider('prayers'));

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No pending prayers.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final itemId = item['id'] as String? ?? '';
            final title = (item['title'] as String?) ?? 'No Title';
            final body = (item['body'] as String?) ?? '';
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold),),
                subtitle: Text(body),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) async {
                    final repo = ref.read(adminModerationRepositoryProvider);
                    if (val == 'approve') {
                      await repo.approvePrayer(itemId);
                      ref.invalidate(adminModerationProvider('prayers'));
                    } else if (val == 'reject') {
                      await repo.rejectPrayer(itemId);
                      ref.invalidate(adminModerationProvider('prayers'));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'approve',
                      child: Text('Approve & Publish',
                          style: TextStyle(color: AppColors.success),),
                    ),
                    const PopupMenuItem(
                      value: 'reject',
                      child: Text('Reject & Delete',
                          style: TextStyle(color: AppColors.error),),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
