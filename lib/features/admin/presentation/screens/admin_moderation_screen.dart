// Kingdom Heir — Admin Moderation Queue
//
// Testimonies-only moderation. Prayer moderation was lifted out of
// this screen and moved to its own route (`/admin/prayer-moderation`,
// see `AdminPrayerModerationScreen`) backed by SECURITY DEFINER RPCs
// (`approve_prayer_request` / `reject_prayer_request`).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/admin/data/repositories/admin_moderation_repository.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

final adminModerationProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, type) async {
  final repo = ref.watch(adminModerationRepositoryProvider);
  // Only testimonies remain on this screen. The 'prayers' family entry
  // is preserved for any in-flight call sites but returns an empty
  // list — the prayer moderation UI is the dedicated screen now.
  if (type == 'prayers') return [];
  return repo.getPendingTestimonies();
});

class AdminModerationScreen extends StatelessWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.testimonyModeration),
      ),
      body: const _TestimonyModerationTab(),
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
          return Center(
              child: Text(AppLocalizations.of(context)!.noPendingTestimonies),);
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
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
                              adminModerationProvider('testimonies'),
                            );
                          },
                          icon: const Icon(Icons.close, color: AppColors.error),
                          label: const Text(
                            'Reject',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () async {
                            final repo =
                                ref.read(adminModerationRepositoryProvider);
                            await repo.approveTestimony(itemId);
                            ref.invalidate(
                              adminModerationProvider('testimonies'),
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: Text(
                              AppLocalizations.of(context)!.approvePublish,),
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
