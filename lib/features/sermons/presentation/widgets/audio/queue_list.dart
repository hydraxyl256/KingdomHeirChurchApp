// Kingdom Heir — Queue List
//
// Collapsible list of the AudioPlayerService's up-next queue. Tap a row
// to jump to that item. Hidden entirely when the queue has zero items.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

class QueueList extends ConsumerWidget {
  const QueueList({super.key, this.collapsed = false});

  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(audioPlayerServiceProvider);
    return ValueListenableBuilder<List<Sermon>>(
      valueListenable: service.queue,
      builder: (context, queue, _) {
        if (queue.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.dividerLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.queue_music_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Up next',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${queue.length} in queue',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ...queue.asMap().entries.map(
                    (e) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: e.key == 0
                              ? AppColors.gold
                              : AppColors.surfaceContainerHighLight,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${e.key + 1}',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: e.key == 0 ? AppColors.ink : AppColors.gold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        e.value.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${e.value.speakerName} · ${e.value.durationLabel}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
