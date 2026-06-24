// Kingdom Heir — Playback Speed Picker
//
// Modal bottom sheet that lets the user pick a playback speed for the
// video / audio player. Updates the AudioPlayerService.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

Future<void> showPlaybackSpeedPicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const _PlaybackSpeedSheet(),
  );
}

class _PlaybackSpeedSheet extends ConsumerWidget {
  const _PlaybackSpeedSheet();

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(audioPlayerServiceProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Playback speed',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _speeds
                  .map(
                    (s) => ChoiceChip(
                      label: Text('${s}x'),
                      selected: service.currentSpeed == s,
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.surfaceContainerLight,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        side: const BorderSide(color: AppColors.dividerLight),
                      ),
                      labelStyle: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                      onSelected: (_) {
                        service.setSpeed(s);
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
