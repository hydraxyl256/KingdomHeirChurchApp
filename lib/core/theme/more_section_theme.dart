import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';

/// Semantic tokens for the "More" section of Kingdom Heirs.
///
/// The More section deliberately uses a *branded navy + gold* surface for
/// the profile hero, the Kingdom Giving card, and the smart-feature cards
/// so they read as premium "stewardship" surfaces. The brand identity must
/// survive both light and dark mode, so the navy surfaces become deeper in
/// light mode (deep navy) and slightly lighter in dark mode (mid navy),
/// while the gold accents stay constant.
///
/// All other More-section widgets that are not intentionally branded
/// (account list, settings, dividers, etc.) should use
/// [Theme.of(context).colorScheme] tokens. The tokens below exist only
/// for surfaces that **must** be gold-on-navy regardless of theme.
@immutable
class MoreSectionTheme extends ThemeExtension<MoreSectionTheme> {
  const MoreSectionTheme({
    required this.heroBackgroundTop,
    required this.heroBackgroundBottom,
    required this.heroAccent,
    required this.heroAccentOnSurface,
    required this.heroMutedOnSurface,
    required this.brandBorder,
    required this.brandShadow,
    required this.brandContainerSubtle,
    required this.brandChipBackground,
    required this.brandChipBorder,
  });

  /// Top gradient stop for the premium gold-on-navy surfaces
  /// (Profile Hero, Kingdom Giving, etc.).
  final Color heroBackgroundTop;

  /// Bottom gradient stop for the same surfaces.
  final Color heroBackgroundBottom;

  /// Gold accent rendered on top of [heroBackgroundTop] (icons, eyebrows,
  /// role chip, progress bars).
  final Color heroAccent;

  /// Primary text/icon colour rendered on top of the hero background.
  /// Ivory in light mode, warm-white in dark mode — both are high contrast
  /// against the navy family.
  final Color heroAccentOnSurface;

  /// Muted text rendered on top of the hero background (subtitles, %).
  final Color heroMutedOnSurface;

  /// Hairline border used on branded surfaces (e.g. gold border on the
  /// Giving card).
  final Color brandBorder;

  /// Shadow colour for branded surfaces.
  final Color brandShadow;

  /// Subtle tinted background used inside a branded surface for nested
  /// containers (e.g. sparkline background in Kingdom Giving).
  final Color brandContainerSubtle;

  /// Background colour of a small pill/chip rendered on top of the hero
  /// surface (e.g. role chip in Profile Hero).
  final Color brandChipBackground;

  /// Border colour of the same chip.
  final Color brandChipBorder;

  /// Light-mode token set — deep navy + restrained gold.
  static const MoreSectionTheme light = MoreSectionTheme(
    heroBackgroundTop: AppColors.navy,
    heroBackgroundBottom: AppColors.navyAccent,
    heroAccent: AppColors.gold,
    heroAccentOnSurface: AppColors.warmWhite,
    heroMutedOnSurface: AppColors.warmWhite,
    brandBorder: AppColors.gold,
    brandShadow: AppColors.navy,
    brandContainerSubtle: AppColors.warmWhite,
    brandChipBackground: AppColors.gold,
    brandChipBorder: AppColors.gold,
  );

  /// Dark-mode token set — slightly lifted navy so the surface still
  /// reads as "premium" against the deeper page background.
  static const MoreSectionTheme dark = MoreSectionTheme(
    heroBackgroundTop: AppColors.navyMid,
    heroBackgroundBottom: AppColors.navy,
    heroAccent: AppColors.gold,
    heroAccentOnSurface: AppColors.warmWhite,
    heroMutedOnSurface: AppColors.warmWhite,
    brandBorder: AppColors.gold,
    brandShadow: AppColors.navyMid,
    brandContainerSubtle: AppColors.warmWhite,
    brandChipBackground: AppColors.gold,
    brandChipBorder: AppColors.gold,
  );

  /// Convenience getter that picks the right [MoreSectionTheme] for the
  /// active [Brightness] without forcing every caller to import the
  /// theme or do an `isDark` check.
  static MoreSectionTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }

  @override
  MoreSectionTheme copyWith({
    Color? heroBackgroundTop,
    Color? heroBackgroundBottom,
    Color? heroAccent,
    Color? heroAccentOnSurface,
    Color? heroMutedOnSurface,
    Color? brandBorder,
    Color? brandShadow,
    Color? brandContainerSubtle,
    Color? brandChipBackground,
    Color? brandChipBorder,
  }) {
    return MoreSectionTheme(
      heroBackgroundTop: heroBackgroundTop ?? this.heroBackgroundTop,
      heroBackgroundBottom: heroBackgroundBottom ?? this.heroBackgroundBottom,
      heroAccent: heroAccent ?? this.heroAccent,
      heroAccentOnSurface: heroAccentOnSurface ?? this.heroAccentOnSurface,
      heroMutedOnSurface: heroMutedOnSurface ?? this.heroMutedOnSurface,
      brandBorder: brandBorder ?? this.brandBorder,
      brandShadow: brandShadow ?? this.brandShadow,
      brandContainerSubtle: brandContainerSubtle ?? this.brandContainerSubtle,
      brandChipBackground: brandChipBackground ?? this.brandChipBackground,
      brandChipBorder: brandChipBorder ?? this.brandChipBorder,
    );
  }

  @override
  MoreSectionTheme lerp(ThemeExtension<MoreSectionTheme>? other, double t) {
    if (other is! MoreSectionTheme) return this;
    return MoreSectionTheme(
      heroBackgroundTop:
          Color.lerp(heroBackgroundTop, other.heroBackgroundTop, t)!,
      heroBackgroundBottom:
          Color.lerp(heroBackgroundBottom, other.heroBackgroundBottom, t)!,
      heroAccent: Color.lerp(heroAccent, other.heroAccent, t)!,
      heroAccentOnSurface:
          Color.lerp(heroAccentOnSurface, other.heroAccentOnSurface, t)!,
      heroMutedOnSurface:
          Color.lerp(heroMutedOnSurface, other.heroMutedOnSurface, t)!,
      brandBorder: Color.lerp(brandBorder, other.brandBorder, t)!,
      brandShadow: Color.lerp(brandShadow, other.brandShadow, t)!,
      brandContainerSubtle:
          Color.lerp(brandContainerSubtle, other.brandContainerSubtle, t)!,
      brandChipBackground:
          Color.lerp(brandChipBackground, other.brandChipBackground, t)!,
      brandChipBorder: Color.lerp(brandChipBorder, other.brandChipBorder, t)!,
    );
  }
}
