// Kingdom Heir — Library Filter Sheet
//
// Modal bottom sheet that exposes the advanced filter set: speaker,
// series, scripture, ministry, date range, audio/video/favorites/
// downloads. Updates SermonLibraryFilters via Riverpod.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/data/mock/mock_sermons_seed.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_library_filters_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

Future<void> showLibraryFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const _LibraryFilterSheet(),
  );
}

class _LibraryFilterSheet extends ConsumerWidget {
  const _LibraryFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(sermonLibraryFiltersProvider);
    final topics = ref.watch(availableTopicsProvider);
    final ministries = ref.watch(availableMinistriesProvider);
    final speakers = MockSermonSeed.allSpeakers.map((s) => s.name).toList()
      ..sort();
    final series = MockSermonSeed.allSeries.map((s) => s.title).toList()
      ..sort();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filter sermons',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (filters.isActive)
                TextButton(
                  onPressed: () => ref
                      .read(sermonLibraryFiltersProvider.notifier)
                      .state = SermonLibraryFilters.empty,
                  child: Text(AppLocalizations.of(context)!.resetAll),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionLabel('Topic'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: topics.map((t) {
              final active = filters.topic == t;
              return _FilterChip(
                label: t,
                isActive: active,
                onTap: () {
                  ref.read(sermonLibraryFiltersProvider.notifier).state =
                      filters.copyWith(
                    topic: active ? null : t,
                    clearTopic: active,
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel('Speaker'),
          _Dropdown<String?>(
            value: filters.speakerName,
            hint: 'Any speaker',
            items: [null, ...speakers],
            labelOf: (v) => v ?? 'Any speaker',
            onChanged: (v) => ref
                .read(sermonLibraryFiltersProvider.notifier)
                .state = filters.copyWith(speakerName: v),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionLabel('Series'),
          _Dropdown<String?>(
            value: filters.seriesName,
            hint: 'Any series',
            items: [null, ...series],
            labelOf: (v) => v ?? 'Any series',
            onChanged: (v) => ref
                .read(sermonLibraryFiltersProvider.notifier)
                .state = filters.copyWith(seriesName: v),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionLabel('Ministry'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _FilterChip(
                label: 'Any',
                isActive: filters.ministry == null,
                onTap: () => ref
                    .read(sermonLibraryFiltersProvider.notifier)
                    .state = filters.copyWith(),
              ),
              ...ministries.map((m) {
                final active = filters.ministry == m;
                return _FilterChip(
                  label: m,
                  isActive: active,
                  onTap: () => ref
                      .read(sermonLibraryFiltersProvider.notifier)
                      .state = filters.copyWith(ministry: active ? null : m),
                );
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel('Date range'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: SermonDateRange.values.map((d) {
              final active = filters.dateRange == d;
              return _FilterChip(
                label: d.label,
                isActive: active,
                onTap: () => ref
                    .read(sermonLibraryFiltersProvider.notifier)
                    .state = filters.copyWith(
                  dateRange: active ? null : d,
                  clearDateRange: active,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel('Media type'),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _FilterChip(
                label: 'Audio only',
                isActive: filters.audioOnly,
                onTap: () => ref
                    .read(sermonLibraryFiltersProvider.notifier)
                    .state = filters.copyWith(audioOnly: !filters.audioOnly),
              ),
              _FilterChip(
                label: 'Video',
                isActive: filters.videoOnly,
                onTap: () => ref
                    .read(sermonLibraryFiltersProvider.notifier)
                    .state = filters.copyWith(videoOnly: !filters.videoOnly),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel('Library'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppLocalizations.of(context)!.favoritesOnly),
            value: filters.favoritesOnly,
            onChanged: (v) => ref
                .read(sermonLibraryFiltersProvider.notifier)
                .state = filters.copyWith(favoritesOnly: v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppLocalizations.of(context)!.downloadedOnly),
            value: filters.downloadsOnly,
            onChanged: (v) => ref
                .read(sermonLibraryFiltersProvider.notifier)
                .state = filters.copyWith(downloadsOnly: v),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.ink,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(AppLocalizations.of(context)!.showResults),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTypography.textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.dividerLight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: isActive
                ? AppColors.ink
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    required this.hint,
  });
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dividerLight),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          items: items
              .map(
                (v) => DropdownMenuItem<T>(
                  value: v,
                  child: Text(labelOf(v)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
