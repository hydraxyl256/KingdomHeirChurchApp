import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

/// Bottom-sheet filter panel for the sermon library.
class SermonFilterBar extends StatefulWidget {
  const SermonFilterBar({required this.onApply, super.key});

  final void Function(SermonFilter filter) onApply;

  @override
  State<SermonFilterBar> createState() => _SermonFilterBarState();
}

class _SermonFilterBarState extends State<SermonFilterBar> {
  SermonMediaType? _mediaType;
  String? _speaker;
  String? _series;
  bool _favoritesOnly = false;
  bool _downloadsOnly = false;

  static const _speakers = [
    'Bishop J. Mensah',
    'Pastor Grace N.',
    'Rev. Sarah A.',
    'Elder Kwame D.',
  ];

  static const _seriesList = [
    'Kingdom Living',
    'Grace & Truth',
    'Prayer School',
    'Identity in Christ',
    'Fruits of the Spirit',
    'The Book of John',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyMid : AppColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              0,
            ),
            child: Row(
              children: [
                Text(
                  'Filter Sermons',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    _mediaType = null;
                    _speaker = null;
                    _series = null;
                    _favoritesOnly = false;
                    _downloadsOnly = false;
                  }),
                  child: Text(
                    'Clear All',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Media Type ────────────────────────────────────────
                  const _Label('Media Type'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _mediaType == null,
                        onTap: () => setState(() => _mediaType = null),
                      ),
                      _FilterChip(
                        label: 'Video',
                        selected: _mediaType == SermonMediaType.video,
                        onTap: () => setState(
                          () => _mediaType = SermonMediaType.video,
                        ),
                      ),
                      _FilterChip(
                        label: 'Audio',
                        selected: _mediaType == SermonMediaType.audio,
                        onTap: () => setState(
                          () => _mediaType = SermonMediaType.audio,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Speaker ───────────────────────────────────────────
                  const _Label('Speaker'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _FilterChip(
                        label: 'Any',
                        selected: _speaker == null,
                        onTap: () => setState(() => _speaker = null),
                      ),
                      ..._speakers.map(
                        (s) => _FilterChip(
                          label: s,
                          selected: _speaker == s,
                          onTap: () => setState(() => _speaker = s),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Series ────────────────────────────────────────────
                  const _Label('Series'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _FilterChip(
                        label: 'Any',
                        selected: _series == null,
                        onTap: () => setState(() => _series = null),
                      ),
                      ..._seriesList.map(
                        (s) => _FilterChip(
                          label: s,
                          selected: _series == s,
                          onTap: () => setState(() => _series = s),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Quick Toggles ─────────────────────────────────────
                  const _Label('Quick Filters'),
                  const SizedBox(height: AppSpacing.sm),
                  _ToggleRow(
                    icon: Icons.bookmark_rounded,
                    label: 'Saved Only',
                    value: _favoritesOnly,
                    onChanged: ({required bool value}) => setState(() {
                      _favoritesOnly = value;
                      if (value) _downloadsOnly = false;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ToggleRow(
                    icon: Icons.download_done_rounded,
                    label: 'Downloaded Only',
                    value: _downloadsOnly,
                    onChanged: ({required bool value}) => setState(() {
                      _downloadsOnly = value;
                      if (value) _favoritesOnly = false;
                    }),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  AppButton(
                    label: 'Apply Filters',
                    icon: Icons.tune_rounded,
                    onPressed: () => widget.onApply(
                      SermonFilter(
                        mediaType: _mediaType,
                        speakerName: _speaker,
                        seriesName: _series,
                        favoritesOnly: _favoritesOnly,
                        downloadsOnly: _downloadsOnly,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: selected
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.ink : AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final void Function({required bool value}) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(value: !value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: value
              ? AppColors.gold.withValues(alpha: 0.1)
              : isDark
                  ? AppColors.navy
                  : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: value ? AppColors.gold : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSpacing.iconSm,
              color: value ? AppColors.gold : Colors.grey,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                color: value
                    ? AppColors.gold
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Switch(
              value: value,
              onChanged: (v) => onChanged(value: v),
              activeThumbColor: AppColors.gold,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
