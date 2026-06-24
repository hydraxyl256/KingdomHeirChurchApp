// Kingdom Heir — Sleep Timer Sheet
//
// Modal bottom sheet for choosing a sleep timer duration: Off, 5 / 15 /
// 30 / 45 / 60 minutes, End of message. Updates the AudioPlayerService.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

Future<void> showSleepTimerSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const _SleepTimerSheet(),
  );
}

class _SleepTimerSheet extends ConsumerWidget {
  const _SleepTimerSheet();

  static const _presets = <Duration?>[
    null,
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(minutes: 60),
  ];

  String _label(Duration? d) {
    if (d == null) return 'Off';
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    return '${d.inMinutes ~/ 60}h';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(audioPlayerServiceProvider);
    return ValueListenableBuilder<DateTime?>(
      valueListenable: service.sleepTimerEndsAt,
      builder: (context, endsAt, _) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep timer',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              endsAt == null
                  ? 'Pick a duration to auto-pause playback.'
                  : 'Stops at ${TimeOfDay.fromDateTime(endsAt).format(context)}',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _presets.map((d) {
                final isActive = (endsAt == null && d == null) ||
                    (d != null && endsAt != null);
                return ChoiceChip(
                  label: Text(_label(d)),
                  selected: isActive,
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.surfaceContainerLight,
                  labelStyle: TextStyle(
                    color: isActive
                        ? AppColors.ink
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    side: BorderSide(
                      color: isActive ? AppColors.gold : AppColors.dividerLight,
                    ),
                  ),
                  onSelected: (_) {
                    if (d == null) {
                      service.cancelSleepTimer();
                    } else {
                      service.sleepTimer(d);
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
