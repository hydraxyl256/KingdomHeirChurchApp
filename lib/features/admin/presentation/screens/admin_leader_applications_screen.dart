import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/admin/data/repositories/admin_leader_apps_repository.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

final adminLeaderAppsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminLeaderAppsRepositoryProvider);
  return repo.getPendingApplications();
});

class AdminLeaderApplicationsScreen extends ConsumerWidget {
  const AdminLeaderApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(adminLeaderAppsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.leaderApplications),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminLeaderAppsProvider),
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
                child:
                    Text(AppLocalizations.of(context)!.noPendingApplications),);
          }
          return ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              final profile = app['profiles'] as Map<String, dynamic>?;
              final applicantName =
                  profile?['full_name'] as String? ?? 'Unknown Applicant';
              final submittedAt = app['submitted_at']?.toString() ?? 'Unknown';
              final appId = app['id'] as String? ?? '';
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    applicantName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Submitted: $submittedAt'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) async {
                      final repo = ref.read(adminLeaderAppsRepositoryProvider);
                      await repo.reviewApplication(appId, val);
                      ref.invalidate(adminLeaderAppsProvider);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'APPROVED',
                        child: Text(
                          'Approve',
                          style: TextStyle(color: AppColors.success),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'REJECTED',
                        child: Text(
                          'Reject',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
