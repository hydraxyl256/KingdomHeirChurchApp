// Kingdom Heir — GlassCard
//
// A frosted, premium hero shell. Built on:
//   • BackdropFilter (with sigma tuned per layout band)
//   • Subtle linear gradient overlay (gold tint on navy in light, deeper navy in dark)
//   • Hairline gold border
//   • Rounded corners following the AppRadius scale
//
// Use cases:
//   • PersonalizedHero (the immersive top-of-dashboard section)
//   • Today's Spiritual Focus card (gold-tinted glass)
//   • Bottom Inspiration card
//
// The widget adapts its blur sigma by band — higher on tablets/desktops where
// there's more behind-the-card context to blur, lighter on small phones to
// stay cheap.

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/more_section_theme.dart';
import 'package:kingdom_heir/core/theme/radius.dart';

enum GlassCardTone { navyGold, warm, pure }

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.tone = GlassCardTone.navyGold,
    this.padding,
    this.radius,
    this.borderColor,
    this.onTap,
    this.elevation = 4,
    this.blurSigma,
  });

  final Widget child;
  final GlassCardTone tone;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? radius;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double elevation;

  /// Override the default per-band blur sigma. Useful for hero modals where
  /// the backdrop is heavily populated.
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final sectionTheme = MoreSectionTheme.of(context);
    final metrics = MediaQuery.of(context);
    final band = layoutBandFromWidth(metrics.size.width);

    final effectiveRadius = radius ?? BorderRadius.circular(AppRadius.xxl);
    final effectiveSigma = blurSigma ?? _defaultSigma(band);

    final baseColor = _baseColor(tone, isDark, sectionTheme);
    final highlightColor = _highlightColor(tone, isDark, sectionTheme);
    final effectiveBorder = borderColor ??
        (isDark
            ? AppColors.gold.withValues(alpha: 0.32)
            : AppColors.goldDark.withValues(alpha: 0.22));

    final card = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: effectiveSigma, sigmaY: effectiveSigma),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                baseColor.withValues(alpha: isDark ? 0.55 : 0.85),
                highlightColor.withValues(alpha: isDark ? 0.42 : 0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: effectiveRadius,
            border: Border.all(color: effectiveBorder),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.08),
                blurRadius: elevation * 4,
                offset: Offset(0, elevation),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: effectiveRadius,
              child: Padding(
                padding: padding ??
                    EdgeInsets.all(
                        Insets.of(context).lg + Insets.of(context).xs,),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    return card;
  }

  static double _defaultSigma(LayoutBand band) => switch (band) {
        LayoutBand.xs => 10,
        LayoutBand.sm => 12,
        LayoutBand.md => 14,
        LayoutBand.lg => 18,
        LayoutBand.xl => 22,
        LayoutBand.xxl => 26,
      };

  static Color _baseColor(
    GlassCardTone tone,
    bool isDark,
    MoreSectionTheme section,
  ) =>
      switch (tone) {
        GlassCardTone.navyGold => section.heroBackgroundTop,
        GlassCardTone.warm => isDark ? AppColors.navyAccent : AppColors.goldContainer,
        GlassCardTone.pure =>
          isDark ? AppColors.surfaceContainerHighLight : AppColors.warmWhite,
      };

  static Color _highlightColor(
    GlassCardTone tone,
    bool isDark,
    MoreSectionTheme section,
  ) =>
      switch (tone) {
        GlassCardTone.navyGold =>
          isDark ? AppColors.goldDark.withValues(alpha: 0.55) : AppColors.gold,
        GlassCardTone.warm => isDark
            ? AppColors.goldDark.withValues(alpha: 0.65)
            : AppColors.goldLight,
        GlassCardTone.pure =>
          isDark ? AppColors.surfaceContainerDark : AppColors.surfaceLight,
      };
}
