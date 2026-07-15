// Kingdom Heir — Admin Devotional Series Screen
//
// CRUD for devotional_series rows. Admins can create, edit, publish,
// archive, and navigate to the day editor.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _adminSeriesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final data = await Supabase.instance.client
      .from('devotional_series')
      .select()
      .order('created_at', ascending: false);
  return (data as List<dynamic>).cast<Map<String, dynamic>>();
});

class AdminDevotionalSeriesScreen extends ConsumerWidget {
  const AdminDevotionalSeriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(_adminSeriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devotional Series'),
        actions: [
          FilledButton.icon(
            onPressed: () => _showCreateDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Series'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (series) {
          if (series.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded,
                      size: 56, color: AppColors.gold,),
                  const SizedBox(height: AppSpacing.md),
                  Text('No devotional series yet.',
                      style: AppTypography.textTheme.bodyMedium,),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: series.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) =>
                _SeriesRow(item: series[i], ref: ref),
          );
        },
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl   = TextEditingController();
    final authorCtrl  = TextEditingController();
    final daysCtrl    = TextEditingController(text: '90');
    final slugCtrl    = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Devotional Series'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(controller: titleCtrl,  label: 'Title'),
              const SizedBox(height: 12),
              _DialogField(controller: slugCtrl,   label: 'Slug (URL-safe)'),
              const SizedBox(height: 12),
              _DialogField(controller: authorCtrl, label: 'Author Name'),
              const SizedBox(height: 12),
              _DialogField(
                controller: daysCtrl,
                label: 'Total Days',
                keyboard: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty || slugCtrl.text.trim().isEmpty) return;
              await Supabase.instance.client.from('devotional_series').insert({
                'title':      titleCtrl.text.trim(),
                'slug':       slugCtrl.text.trim(),
                'author_name':authorCtrl.text.trim().isNotEmpty
                    ? authorCtrl.text.trim()
                    : null,
                'total_days': int.tryParse(daysCtrl.text.trim()) ?? 90,
                'status':     'draft',
              });
              ref.invalidate(_adminSeriesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// ─── Series row ───────────────────────────────────────────────────────────────

class _SeriesRow extends StatelessWidget {
  const _SeriesRow({required this.item, required this.ref});
  final Map<String, dynamic> item;
  final WidgetRef ref;

  String get _id       => item['id'] as String;
  String get _title    => item['title'] as String? ?? 'Untitled';
  String get _status   => item['status'] as String? ?? 'draft';
  int    get _days     => item['total_days'] as int? ?? 0;
  bool   get _primary  => item['is_primary_challenge_series'] as bool? ?? false;

  Color _statusColor() => switch (_status) {
        'published' => AppColors.success,
        'archived'  => AppColors.error,
        _           => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.navyMid,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: const Icon(Icons.menu_book_rounded,
            color: AppColors.gold, size: 24,),
      ),
      title: Row(
        children: [
          Text(_title, style: AppTypography.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),),
          if (_primary) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                '90-DAY',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text('$_days days · Status: ${_status.toUpperCase()}',
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: _statusColor(),
            fontWeight: FontWeight.w600,
          ),),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Open day editor
          IconButton(
            tooltip: 'Edit Days',
            icon: const Icon(Icons.edit_calendar_rounded, size: 20),
            onPressed: () => context.push(
              '/admin/devotional-series/$_id/days/1',
            ),
          ),
          // Status popup
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'publish')  await _updateStatus('published');
              if (val == 'draft')    await _updateStatus('draft');
              if (val == 'archive')  await _updateStatus('archived');
              if (val == 'primary')  await _togglePrimary();
              ref.invalidate(_adminSeriesProvider);
            },
            itemBuilder: (_) => [
              if (_status != 'published')
                const PopupMenuItem(value: 'publish', child: Text('✅ Publish')),
              if (_status != 'draft')
                const PopupMenuItem(value: 'draft', child: Text('📝 Set Draft')),
              if (_status != 'archived')
                const PopupMenuItem(value: 'archive', child: Text('🗄 Archive')),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'primary',
                child: Text(_primary
                    ? '⭐ Remove Primary'
                    : '⭐ Set as Primary Challenge',),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    await Supabase.instance.client
        .from('devotional_series')
        .update({'status': status})
        .eq('id', _id);
  }

  Future<void> _togglePrimary() async {
    await Supabase.instance.client
        .from('devotional_series')
        .update({'is_primary_challenge_series': !_primary})
        .eq('id', _id);
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.keyboard = TextInputType.text,
  });
  final TextEditingController controller;
  final String label;
  final TextInputType keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
