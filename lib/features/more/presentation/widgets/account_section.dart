// Kingdom Heir — Account Section (SECTION 8)
//
// Modern Apple-style settings list. Four rows:
//   • My Profile
//   • Language (current value displayed on the right; tap opens picker)
//   • Notifications
//   • Settings
//
// Layout:
//   • Each row is a `_AccountTile` rendering icon + label + (trailing
//     chip or chevron).
//   • Rows are stacked in a single rounded container with hairline
//     dividers between them — iOS Settings style.
//   • The container width is band-aware: on tablets it caps at ~640 dp
//     so rows stay readable and don't stretch edge-to-edge.
//
// Scrollability note: this section contains no vertical scrollables — it
// is a flat `Column` of static rows. The language picker dialog uses a
// `ListView(shrinkWrap: true)` inside an `AlertDialog.content`; the
// dialog's own intrinsic-height layout bounds the list, so the
// `shrinkWrap` is the correct choice here.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/localization/locale_provider.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/feature_catalog.dart';

class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            Insets.of(context).lg,
            Insets.of(context).lg,
            Insets.of(context).lg,
            Insets.of(context).sm,
          ),
          child: Text(
            'Account',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final insets = Insets.of(context);
            final band = layoutBandFromWidth(constraints.maxWidth);
            // Cap width on tablet so the row labels stay readable.
            final maxWidth = band.isAtLeast(LayoutBand.xl) ? 640.0 : null;
            return Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: maxWidth ?? double.infinity),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: insets.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _AccountTile(
                          feature: MoreFeature.myProfile,
                          onTap: () =>
                              GoRouter.of(context).push(RouteNames.myProfile),
                          delay: 0,
                        ),
                        const _Hairline(),
                        _AccountTile(
                          feature: MoreFeature.language,
                          trailing: _LanguageChip(
                            code: locale.languageCode,
                          ),
                          onTap: () => _showLanguageDialog(context, ref),
                          delay: 50,
                        ),
                        const _Hairline(),
                        _AccountTile(
                          feature: MoreFeature.notifications,
                          onTap: () =>
                              context.goToFeature(MoreFeature.notifications),
                          delay: 100,
                        ),
                        const _Hairline(),
                        _AccountTile(
                          feature: MoreFeature.settings,
                          onTap: () =>
                              GoRouter.of(context).push(RouteNames.settings),
                          delay: 150,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  static void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    const languages = [
      {'code': 'en', 'label': 'English'},
      {'code': 'fr', 'label': 'Français (French)'},
      {'code': 'es', 'label': 'Español (Spanish)'},
      {'code': 'pt', 'label': 'Português (Portuguese)'},
      {'code': 'sw', 'label': 'Kiswahili (Swahili)'},
      {'code': 'lg', 'label': 'Luganda'},
      {'code': 'yo', 'label': 'Yorùbá'},
      {'code': 'ha', 'label': 'Hausa'},
    ];
    final notifier = ref.read(localeProvider.notifier);
    final currentCode = ref.read(localeProvider).languageCode;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Select Language'),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<String>(
            groupValue: currentCode,
            onChanged: (v) {
              if (v != null) notifier.setLocale(v);
              Navigator.pop(dialogCtx);
            },
            child: ListView(
              shrinkWrap: true,
              children: languages.map((lang) {
                final code = lang['code']!;
                final isSelected = code == currentCode;
                return RadioListTile<String>(
                  value: code,
                  activeColor: AppColors.gold,
                  title: Text(lang['label']!),
                  secondary: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.gold,
                        )
                      : null,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.feature,
    required this.onTap,
    required this.delay,
    this.trailing,
    this.isLast = false,
  });

  final MoreFeature feature;
  final VoidCallback onTap;
  final int delay;
  final Widget? trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final spec = FeatureCatalog.of(feature);
    final palette = AccentPalette.of(spec.accent, isDark: false);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: palette.fg.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(spec.icon, color: palette.fg, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  spec.feature.label,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: AppMotion.standard,
          delay: Duration(milliseconds: delay),
        )
        .slideX(begin: 0.04, end: 0);
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 62),
      child: Divider(
        height: 0.5,
        thickness: 0.5,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.code});

  final String code;

  static const _map = {
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'pt': 'Português',
    'sw': 'Kiswahili',
    'lg': 'Luganda',
    'yo': 'Yorùbá',
    'ha': 'Hausa',
  };

  @override
  Widget build(BuildContext context) {
    final label = _map[code] ?? 'English';
    return Text(
      label,
      style: AppTypography.textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
