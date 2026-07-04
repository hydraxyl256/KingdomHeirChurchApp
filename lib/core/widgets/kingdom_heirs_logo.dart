import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

/// Canonical Kingdom Heirs brand logo widget.
///
/// Used on every screen that needs the logo: Splash, Login, Register,
/// About, and any future auth/onboarding screens.
///
/// Rendering rules (must never be changed in isolation on one screen):
/// - Adaptive size: `MediaQuery.of(context).size.shortestSide * sizeFactor`,
///   clamped between [minSize] and [maxSize].
/// - White circle background with gold shadow.
/// - `ClipOval` → `Image.asset` with `BoxFit.contain` preserves aspect ratio.
/// - Text fallback ("KH") when the asset is missing (CI environments, etc.).
class KingdomHeirsLogo extends StatelessWidget {
  const KingdomHeirsLogo({
    super.key,
    this.sizeFactor = 0.22,
    this.minSize = 56.0,
    this.maxSize = 96.0,
  });

  /// Fraction of `shortestSide` used to compute the logo diameter.
  /// Login uses 0.22. Splash uses a larger value (computed inline there
  /// because the splash size is intentionally much larger).
  final double sizeFactor;

  /// Minimum clamp for the computed size (logical pixels).
  final double minSize;

  /// Maximum clamp for the computed size (logical pixels).
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = (mq.size.shortestSide * sizeFactor).clamp(minSize, maxSize);

    return Semantics(
      label: 'Kingdom Heirs Ministry',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.warmWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.all(size * 0.16),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.jpeg',
            fit: BoxFit.contain,
            semanticLabel: 'Kingdom Heirs logo',
            errorBuilder: (_, __, ___) => _LogoFallback(size: size),
          ),
        ),
      ),
    );
  }
}

/// Text fallback displayed when the logo asset cannot be loaded.
/// Matches the `KingdomHeirsLogo` container's look so the fallback is
/// always correctly sized relative to its parent.
class LogoFallback extends StatelessWidget {
  const LogoFallback({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'KH',
        style: AppTypography.textTheme.displayMedium?.copyWith(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w800,
          color: AppColors.gold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// Private alias kept for internal use within this file.
class _LogoFallback extends LogoFallback {
  const _LogoFallback({required super.size});
}

/// Full brand header: logo + wordmark + tagline.
///
/// Extracted here so Login, Register, and any future screens all share
/// exactly the same header treatment without duplication.
///
/// [subtitleColor] defaults to warmWhite at 55% opacity — suitable for
/// dark (navy) backgrounds.  Override for light backgrounds.
class KingdomHeirsBrandHeader extends StatelessWidget {
  const KingdomHeirsBrandHeader({
    super.key,
    this.sizeFactor = 0.22,
    this.minSize = 56.0,
    this.maxSize = 96.0,
    this.subtitleColor,
  });

  final double sizeFactor;
  final double minSize;
  final double maxSize;

  /// Color for the tagline text. Falls back to warmWhite at 55% opacity.
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final effectiveSubtitleColor =
        subtitleColor ?? AppColors.warmWhite.withValues(alpha: 0.55);

    return Column(
      children: [
        KingdomHeirsLogo(
          sizeFactor: sizeFactor,
          minSize: minSize,
          maxSize: maxSize,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'KINGDOM HEIRS',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'INHERITING EXCELLENCE',
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: effectiveSubtitleColor,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
