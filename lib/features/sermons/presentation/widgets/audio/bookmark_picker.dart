// Kingdom Heir — Bookmark Picker
//
// Inline action that shows the user's saved bookmarks for the current
// sermon. Tap to seek. Held-position long-press to add a new bookmark.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkPicker extends ConsumerWidget {
  const BookmarkPicker({required this.sermon, super.key});
  final Sermon sermon;

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(audioPlayerServiceProvider);
    return StreamBuilder<Duration>(
      stream: service.positionStream,
      builder: (context, snap) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.dividerLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Bookmarks',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      final pos = snap.data ?? Duration.zero;
                      await service.addBookmark(pos);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Bookmarked at ${_format(pos.inSeconds)}',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Mark current'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              FutureBuilder<List<int>>(
                future: _loadBookmarks(sermon.id),
                builder: (context, bookmarkSnap) {
                  final list = bookmarkSnap.data ?? const <int>[];
                  if (list.isEmpty) {
                    return Text(
                      'No bookmarks yet — tap "Mark current" to save this spot.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: list
                        .map(
                          (s) => ActionChip(
                            label: Text(_format(s)),
                            backgroundColor:
                                AppColors.gold.withValues(alpha: 0.12),
                            side: const BorderSide(color: AppColors.gold),
                            labelStyle: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w800,
                            ),
                            onPressed: () => service.seek(Duration(seconds: s)),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<int>> _loadBookmarks(String sermonId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('sermon_bookmarks_$sermonId') ?? <String>[];
    final list = raw.map(int.tryParse).whereType<int>().toList()..sort();
    return list;
  }
}
