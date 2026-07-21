import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_local_state.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_engagement_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/theme/bible_reader_palette.dart';

/// Bottom sheet for adjusting reader appearance (font, line height, theme,
/// family, verse numbers, justify).
class BibleReaderSettingsSheet extends ConsumerWidget {
  const BibleReaderSettingsSheet({required this.palette, super.key});

  final BibleReaderPalette palette;

  static Future<void> show({
    required BuildContext context,
    required BibleReaderPalette palette,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BibleReaderSettingsSheet(palette: palette),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readerSettingsProvider);
    final notifier = ref.read(readerSettingsProvider.notifier);
    final mq = MediaQuery.of(context);

    return AnimatedPadding(
      duration: AppMotion.standard,
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xxl),
              ),
              border: Border(
                top: BorderSide(color: palette.accentSoft),
              ),
            ),
            child: ListView(
              controller: controller,
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.xs,
                  ),
                  child: Center(
                    child: Container(
                      width: AppSpacing.sheetHandleWidth,
                      height: AppSpacing.sheetHandleHeight,
                      decoration: BoxDecoration(
                        color: palette.divider,
                        borderRadius: AppRadius.brFull,
                      ),
                    ),
                  ),
                ),
                _Header(
                  palette: palette,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SectionTitle(palette: palette, text: 'Theme'),
                _ThemePicker(
                  palette: palette,
                  current: settings.theme,
                  onPicked: (t) => notifier.update(settings.copyWith(theme: t)),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(palette: palette, text: 'Typeface'),
                _FontFamilyPicker(
                  palette: palette,
                  current: settings.fontFamily,
                  onPicked: (f) =>
                      notifier.update(settings.copyWith(fontFamily: f)),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(
                  palette: palette,
                  text: 'Font size · ${(settings.fontScale * 100).round()}%',
                ),
                _StepperSlider(
                  palette: palette,
                  value: settings.fontScale,
                  min: 0.85,
                  max: 1.6,
                  divisions: 15,
                  onChanged: (v) =>
                      notifier.update(settings.copyWith(fontScale: v)),
                  onPreview: settings.fontFamily,
                  previewTheme: settings.theme,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(
                  palette: palette,
                  text:
                      'Line height · ${settings.lineHeight.toStringAsFixed(1)}',
                ),
                _StepperSlider(
                  palette: palette,
                  value: settings.lineHeight,
                  min: 1.4,
                  max: 2,
                  divisions: 6,
                  onChanged: (v) =>
                      notifier.update(settings.copyWith(lineHeight: v)),
                  onPreview: settings.fontFamily,
                  previewTheme: settings.theme,
                  previewLineHeight: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(palette: palette, text: 'Reading options'),
                _ToggleRow(
                  palette: palette,
                  icon: Icons.format_list_numbered_rounded,
                  title: 'Verse numbers',
                  subtitle: 'Show verse number badges in-line',
                  value: settings.verseNumbers,
                  onChanged: (v) => notifier.update(
                    settings.copyWith(verseNumbers: v ?? true),
                  ),
                ),
                _ToggleRow(
                  palette: palette,
                  icon: Icons.format_align_justify_rounded,
                  title: 'Justified text',
                  subtitle: 'Even out line lengths (sermon style)',
                  value: settings.justify,
                  onChanged: (v) => notifier.update(
                    settings.copyWith(justify: v ?? false),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.palette, required this.onClose});

  final BibleReaderPalette palette;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: AppRadius.brFull,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READER',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: palette.accent,
                    letterSpacing: 2,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reading preferences',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: palette.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: palette.foregroundMuted),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.palette, required this.text});

  final BibleReaderPalette palette;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: palette.foregroundMuted,
          letterSpacing: 2,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({
    required this.palette,
    required this.current,
    required this.onPicked,
  });

  final BibleReaderPalette palette;
  final ReaderTheme current;
  final ValueChanged<ReaderTheme> onPicked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: ReaderTheme.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final t = ReaderTheme.values[i];
          final p = BibleReaderPalette.of(t);
          final isSel = t == current;
          return _ThemeSwatch(
            label: t.label,
            description: t.description,
            palette: p,
            selected: isSel,
            onTap: () => onPicked(t),
          );
        },
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.label,
    required this.description,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final BibleReaderPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label theme',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brLg,
          child: AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.decelerate,
            width: 120,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: AppRadius.brLg,
              border: Border.all(
                color: selected ? palette.accent : palette.divider,
                width: selected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: palette.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: palette.surfaceMuted,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.divider,
                          width: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Aa',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: palette.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: palette.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: palette.foregroundMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FontFamilyPicker extends StatelessWidget {
  const _FontFamilyPicker({
    required this.palette,
    required this.current,
    required this.onPicked,
  });

  final BibleReaderPalette palette;
  final ReaderFontFamily current;
  final ValueChanged<ReaderFontFamily> onPicked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: ReaderFontFamily.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final f = ReaderFontFamily.values[i];
          final isSel = f == current;
          return _FontFamilyCard(
            palette: palette,
            family: f,
            selected: isSel,
            onTap: () => onPicked(f),
          );
        },
      ),
    );
  }
}

class _FontFamilyCard extends StatelessWidget {
  const _FontFamilyCard({
    required this.palette,
    required this.family,
    required this.selected,
    required this.onTap,
  });

  final BibleReaderPalette palette;
  final ReaderFontFamily family;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = AppTypography.textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: family.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brLg,
          child: AnimatedContainer(
            duration: AppMotion.standard,
            width: 140,
            decoration: BoxDecoration(
              color: selected ? palette.accentSoft : palette.surfaceMuted,
              borderRadius: AppRadius.brLg,
              border: Border.all(
                color: selected ? palette.accent : palette.divider,
                width: selected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  family.label,
                  style: textTheme.titleLarge?.copyWith(
                    color: selected ? palette.accent : palette.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  family.description,
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.foregroundMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperSlider extends StatelessWidget {
  const _StepperSlider({
    required this.palette,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.onPreview,
    required this.previewTheme,
    this.previewLineHeight = false,
  });

  final BibleReaderPalette palette;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final ReaderFontFamily onPreview;
  final ReaderTheme previewTheme;
  final bool previewLineHeight;

  @override
  Widget build(BuildContext context) {
    final previewPalette = BibleReaderPalette.of(previewTheme);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: palette.accent,
              inactiveTrackColor: palette.divider,
              thumbColor: palette.accent,
              overlayColor: palette.accentSoft,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: previewPalette.surfaceMuted,
              borderRadius: AppRadius.brMd,
              border: Border.all(color: previewPalette.divider),
            ),
            child: Text(
              previewLineHeight
                  ? 'In the beginning was the Word, and the Word was with God.'
                  : 'In the beginning was the Word, and the Word was with God, '
                      'and the Word was God.',
              style: _previewStyle(
                previewPalette,
                previewLineHeight ? 16.0 : value * 18.0,
                previewLineHeight ? value : 1.6,
                onPreview,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _previewStyle(
    BibleReaderPalette p,
    double fontSize,
    double lineHeight,
    ReaderFontFamily family,
  ) {
    final base = AppTypography.textTheme.bodyMedium!.copyWith(
      color: p.foreground,
      fontSize: fontSize,
      height: lineHeight,
    );
    return base;
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final BibleReaderPalette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.iconMd,
            height: AppSpacing.iconMd,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: palette.accent, size: 14),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: palette.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: palette.foregroundMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: palette.accent,
            activeTrackColor: palette.accent.withValues(alpha: 0.45),
            inactiveThumbColor: palette.foregroundMuted,
            inactiveTrackColor: palette.divider,
          ),
        ],
      ),
    );
  }
}
