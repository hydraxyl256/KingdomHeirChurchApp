import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/admin/data/repositories/admin_content_repository.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

final adminEventsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminContentRepositoryProvider);
  return repo.getEvents();
});

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(adminEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.eventManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminEventsProvider),
          ),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        AppLocalizations.of(context)!.createEventComingSoon,),),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.newEvent),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (events) {
          if (events.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noEventsFound),);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final event = events[index];
              final status = event['status'] as String? ?? 'draft';
              final isPublished = status == 'published';
              final startAtStr = event['start_at'] as String?;
              final startAt = startAtStr != null
                  ? DateTime.parse(startAtStr).toLocal()
                  : DateTime.now();
              final eventId = event['id'] as String? ?? '';
              final title = event['title'] as String? ?? 'Untitled';
              final rsvpCount = event['rsvp_count'] as int? ?? 0;

              return ListTile(
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${startAt.toString().split('.')[0]} • RSVPs: $rsvpCount',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(status.toUpperCase()),
                      backgroundColor: isPublished
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.warning.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color:
                            isPublished ? AppColors.success : AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    PopupMenuButton<String>(
                      onSelected: (val) async {
                        final repo = ref.read(adminContentRepositoryProvider);
                        if (val == 'toggle_status') {
                          final newStatus = isPublished ? 'draft' : 'published';
                          await repo.toggleEventStatus(eventId, newStatus);
                          ref.invalidate(adminEventsProvider);
                        } else if (val == 'delete') {
                          await repo.deleteEvent(eventId);
                          ref.invalidate(adminEventsProvider);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle_status',
                          child: Text(isPublished ? 'Unpublish' : 'Publish'),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(AppLocalizations.of(context)!.edit),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
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
