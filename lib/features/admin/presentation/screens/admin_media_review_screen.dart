// Kingdom Heir — Admin Media Review Screen
//
// Lists media_content rows with status='pending_review'.
// Admin actions: set content_type, speaker, series, is_featured, publish/archive.
// "Sync YouTube Channel" button invokes the sync-youtube-content Edge Function.
// Shows last sync run status.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _supabase = Supabase.instance.client;

final pendingMediaProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final data = await _supabase
      .from('media_content')
      .select()
      .order('published_at', ascending: false);
  return (data as List<dynamic>).cast<Map<String, dynamic>>();
});

final lastSyncRunProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final data = await _supabase.rpc<dynamic>('get_latest_sync_run');
  if (data == null) return null;
  return data as Map<String, dynamic>;
});

final _isSyncingProvider = StateProvider<bool>((ref) => false);

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdminMediaReviewScreen extends ConsumerWidget {
  const AdminMediaReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(pendingMediaProvider);
    final syncAsync = ref.watch(lastSyncRunProvider);
    final isSyncing = ref.watch(_isSyncingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mediaReviewQueue),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                ..invalidate(pendingMediaProvider)
                ..invalidate(lastSyncRunProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Sync bar ─────────────────────────────────────────────
          _SyncBar(
            syncAsync: syncAsync,
            isSyncing: isSyncing,
            onSync: () => _triggerSync(context, ref),
          ),

          // ── Media list ───────────────────────────────────────────
          Expanded(
            child: mediaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(child: Text('Error: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _MediaItemTile(item: items[i], ref: ref),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSync(BuildContext context, WidgetRef ref) async {
    ref.read(_isSyncingProvider.notifier).state = true;
    try {
      await _supabase.functions.invoke('sync-youtube-content');
      ref
        ..invalidate(pendingMediaProvider)
        ..invalidate(lastSyncRunProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.youtubeSyncCompleted),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      ref.read(_isSyncingProvider.notifier).state = false;
    }
  }
}

// ─── Sync bar ─────────────────────────────────────────────────────────────────

class _SyncBar extends StatelessWidget {
  const _SyncBar({
    required this.syncAsync,
    required this.isSyncing,
    required this.onSync,
  });

  final AsyncValue<Map<String, dynamic>?> syncAsync;
  final bool isSyncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: syncAsync.when(
              loading: () =>
                  Text(AppLocalizations.of(context)!.loadingSyncInfo),
              error: (_, __) =>
                  Text(AppLocalizations.of(context)!.syncInfoUnavailable),
              data: (run) {
                if (run == null) {
                  return Text(
                    'No sync runs yet',
                    style: AppTypography.textTheme.bodySmall,
                  );
                }
                final status = run['status'] as String? ?? 'unknown';
                final found = run['videos_found'] as int? ?? 0;
                final created = run['videos_created'] as int? ?? 0;
                final updated = run['videos_updated'] as int? ?? 0;

                Color statusColor;
                switch (status) {
                  case 'completed':
                    statusColor = AppColors.success;
                  case 'failed':
                    statusColor = AppColors.error;
                  default:
                    statusColor = AppColors.warning;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Last sync: ${status.toUpperCase()}',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Found: $found  ·  Created: $created  ·  Updated: $updated',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (run['error_message'] != null)
                      Text(
                        run['error_message'] as String,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.error,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton.icon(
            onPressed: isSyncing ? null : onSync,
            icon: isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sync_rounded, size: 18),
            label: Text(isSyncing ? 'Syncing…' : 'Sync YouTube'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.navy,
              disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Media item tile ──────────────────────────────────────────────────────────

class _MediaItemTile extends StatelessWidget {
  const _MediaItemTile({required this.item, required this.ref});

  final Map<String, dynamic> item;
  final WidgetRef ref;

  String get _id => item['id'] as String;
  String get _title => item['title'] as String? ?? 'Untitled';
  String? get _thumbnail => item['thumbnail_url'] as String?;
  String? get _youtubeUrl => item['youtube_url'] as String?;
  String get _contentType => item['content_type'] as String? ?? 'sermon';
  String get _status => item['status'] as String? ?? 'pending_review';
  bool get _isFeatured => item['is_featured'] as bool? ?? false;

  Color _statusColor() => switch (_status) {
        'published' => AppColors.success,
        'pending_review' => AppColors.warning,
        'archived' => AppColors.error,
        _ => AppColors.navyLight,
      };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      leading: _thumbnail != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: CachedNetworkImage(
                imageUrl: _thumbnail!,
                width: 64,
                height: 48,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.videocam, size: 32),
              ),
            )
          : Container(
              width: 64,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.navyMid,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.videocam, color: AppColors.gold),
            ),
      title: Text(
        _title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          _TypeChip(type: _contentType),
          const SizedBox(width: 6),
          Chip(
            label: Text(_status.replaceAll('_', ' ').toUpperCase()),
            backgroundColor: _statusColor().withValues(alpha: 0.12),
            labelStyle: TextStyle(
              color: _statusColor(),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          if (_isFeatured) ...[
            const SizedBox(width: 4),
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_youtubeUrl != null)
            IconButton(
              tooltip: AppLocalizations.of(context)!.viewOnYoutube,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              onPressed: () => launchUrl(
                Uri.parse(_youtubeUrl!),
                mode: LaunchMode.externalApplication,
              ),
            ),
          _ActionMenu(itemId: _id, status: _status, ref: ref),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(type.toUpperCase()),
      backgroundColor: AppColors.navyAccent.withValues(alpha: 0.15),
      labelStyle: const TextStyle(
        color: AppColors.navyLight,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ─── Action menu ──────────────────────────────────────────────────────────────

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({
    required this.itemId,
    required this.status,
    required this.ref,
  });
  final String itemId;
  final String status;
  final WidgetRef ref;

  Future<void> _setContentType(BuildContext context, String type) async {
    await _supabase
        .from('media_content')
        .update({'content_type': type}).eq('id', itemId);
    ref.invalidate(pendingMediaProvider);
  }

  Future<void> _setStatus(BuildContext context, String newStatus) async {
    await _supabase
        .from('media_content')
        .update({'status': newStatus}).eq('id', itemId);
    ref.invalidate(pendingMediaProvider);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (val) async {
        if (val == 'publish' && context.mounted) {
          await _setStatus(context, 'published');
        }
        if (val == 'archive' && context.mounted) {
          await _setStatus(context, 'archived');
        }
        if (val == 'pending' && context.mounted) {
          await _setStatus(context, 'pending_review');
        }
        if (val == 'sermon' && context.mounted) {
          await _setContentType(context, 'sermon');
        }
        if (val == 'podcast' && context.mounted) {
          await _setContentType(context, 'podcast');
        }
        if (val == 'teaching' && context.mounted) {
          await _setContentType(context, 'teaching');
        }
        if (val == 'testimony' && context.mounted) {
          await _setContentType(context, 'testimony');
        }
        if (val == 'announcement' && context.mounted) {
          await _setContentType(context, 'announcement');
        }
      },
      itemBuilder: (_) => [
        _sectionLabel('STATUS'),
        if (status != 'published')
          PopupMenuItem(
              value: 'publish',
              child: Text(AppLocalizations.of(context)!.publish),),
        if (status != 'pending_review')
          PopupMenuItem(
              value: 'pending',
              child: Text(AppLocalizations.of(context)!.setPending),),
        if (status != 'archived')
          PopupMenuItem(
              value: 'archive',
              child: Text(AppLocalizations.of(context)!.archive),),
        const PopupMenuDivider(),
        _sectionLabel('TYPE'),
        PopupMenuItem(
            value: 'sermon', child: Text(AppLocalizations.of(context)!.sermon),),
        PopupMenuItem(
            value: 'podcast',
            child: Text(AppLocalizations.of(context)!.podcast),),
        PopupMenuItem(
            value: 'teaching',
            child: Text(AppLocalizations.of(context)!.teaching),),
        PopupMenuItem(
            value: 'testimony',
            child: Text(AppLocalizations.of(context)!.testimony),),
        PopupMenuItem(
            value: 'announcement',
            child: Text(AppLocalizations.of(context)!.announcement),),
      ],
    );
  }

  /// Non-selectable section header inside a PopupMenu.
  static PopupMenuItem<String> _sectionLabel(String text) =>
      PopupMenuItem<String>(
        enabled: false,
        height: 28,
        child: Text(
          text,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.video_library_rounded,
              size: 56,
              color: AppColors.gold,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No media content found.\nRun a YouTube sync to import videos.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
