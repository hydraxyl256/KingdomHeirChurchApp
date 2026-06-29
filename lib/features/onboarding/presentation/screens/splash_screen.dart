import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/theme/spacing.dart';

/// Kingdom Heir — Splash Screen
///
/// Premium, elegant, modern Christian luxury.
///   • Deep navy background with subtle radial vignette.
///   • Gold animated logo reveal (fade + scale + halo).
///   • Soft rotating light rays behind logo (one-time entrance, no per-frame
///     state mutation — 60fps friendly).
///   • Loading progress at the base.
///   • Accessibility: Semantics, Reduce Motion, contrast-safe text colors.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // One controller for the light-rays sweep (a finite, one-shot, deterministic
  // animation — never repeating — so it costs nothing after entrance).
  late final AnimationController _raysController;

  @override
  void initState() {
    super.initState();

    // Light-rays: slow one-shot entrance over 1.6s, then static.
    _raysController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _raysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.navy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Base background (deep navy) ─────────────────────────
            const _SplashBackground(),

            // ── 2. Soft light rays (one-shot, 60fps) ───────────────────
            // Wrapped in a RepaintBoundary so its repaints never invalidate
            // the rest of the tree.
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _raysController,
                builder: (_, __) => CustomPaint(
                  painter: _LightRaysPainter(
                    progress: _raysController.value,
                  ),
                ),
              ),
            ),

            // ── 3. Halo behind logo (no per-frame rebuilds) ────────────
            const RepaintBoundary(child: _LogoHalo()),

            // ── 4. Centered logo + tagline ─────────────────────────────
            Center(
              child: _SplashHero(reduceMotion: reduceMotion),
            ),

            // ── 5. Bottom progress + label ──────────────────────────────
            const Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.huge,
              child: SafeArea(
                top: false,
                child: _SplashProgress(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background: deep navy + subtle radial vignette
// ─────────────────────────────────────────────────────────────────────────────

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        // Layered radial gradients give the screen a soft cinematic depth
        // without resorting to a per-frame animation.
        gradient: RadialGradient(
          radius: 1.2,
          colors: [
            Color(0xFF162033), // softer centre
            Color(0xFF0F172A), // mid navy
            Color(0xFF0B1120), // deepest edge
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Light rays — a single radial sweep, drawn once into a static CustomPainter
//─────────────────────────────────────────────────────────────────────────────

class _LightRaysPainter extends CustomPainter {
  _LightRaysPainter({required this.progress});

  /// 0..1, drives the rays' opacity + rotation ease-in.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    // Rays fill the screen and are clipped via the gradient, so we don't
    // need a custom clipper.
    final maxRadius = math.sqrt(
          size.width * size.width + size.height * size.height,
        ) /
        2;

    // Use a smooth-stepped opacity (eases in fast, settles gently).
    final t = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final baseOpacity = 0.18 * t; // cap at 0.18 — present but never gaudy

    // 8 rays, evenly spaced. Each is a thin radial gradient.
    const rayCount = 8;
    for (var i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * math.pi;
      final rayEnd = Offset(
        center.dx + math.cos(angle) * maxRadius,
        center.dy + math.sin(angle) * maxRadius,
      );

      // Subtle per-ray opacity falloff to suggest depth (alternating rays).
      final rayOpacity = baseOpacity * (i.isEven ? 1.0 : 0.6);

      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.center,
          end: Alignment(
            (rayEnd.dx - center.dx) / maxRadius,
            (rayEnd.dy - center.dy) / maxRadius,
          ),
          colors: [
            AppColors.gold.withValues(alpha: rayOpacity),
            AppColors.gold.withValues(alpha: 0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
        ..blendMode = BlendMode.plus
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.shortestSide * 0.06
        ..style = PaintingStyle.stroke;

      canvas.drawLine(center, rayEnd, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightRaysPainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Halo behind the logo — soft gold bloom
// ─────────────────────────────────────────────────────────────────────────────

class _LogoHalo extends StatelessWidget {
  const _LogoHalo();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final haloSize = size.shortestSide * 0.7;

    return Center(
      child: SizedBox(
        width: haloSize,
        height: haloSize,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x33F5DD7E), // gold-light bloom
                Color(0x14D4AF37), // gold mid
                Color(0x00000000), // transparent edge
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo + tagline
// ─────────────────────────────────────────────────────────────────────────────

class _SplashHero extends StatelessWidget {
  const _SplashHero({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    // Match the native splash screen dimensions exactly.
    const logoSize = 200.0;

    // Reserve vertical room above the bottom progress so nothing overlaps.
    const reservedBottom = AppSpacing.huge + AppSpacing.xxxl;

    final logo = Semantics(
      label: 'Kingdom Heirs logo',
      image: true,
      child: const SizedBox(
        width: logoSize,
        height: logoSize,
        child: _LogoMark(size: logoSize),
      ),
    );

    final tagline = Semantics(
      label: 'Inheriting Excellence',
      child: Text(
        'Inheriting Excellence',
        style: AppTypography.textTheme.titleMedium?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          color: AppColors.goldLight,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: AppColors.gold.withValues(alpha: 0.45),
              blurRadius: 16,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );

    final divider = Semantics(
      excludeSemantics: true,
      child: Container(
        width: AppSpacing.huge,
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0),
              AppColors.gold.withValues(alpha: 0.6),
              AppColors.gold.withValues(alpha: 0),
            ],
          ),
          borderRadius: AppRadius.brFull,
        ),
      ),
    );

    final children = <Widget>[
      logo,
      const SizedBox(height: AppSpacing.xl),
      divider,
      const SizedBox(height: AppSpacing.md),
      tagline,
    ];

    // Apply entrance animations (or skip them under reduce-motion).
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );

    if (reduceMotion) {
      return Padding(
        padding: const EdgeInsets.only(bottom: reservedBottom),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: reservedBottom),
      child: content.animate().fadeIn(
            duration: const Duration(milliseconds: 1200),
            curve: AppMotion.decelerate,
          ),
    );
  }
}

/// Logo mark — uses the brand asset when present, with an elegant vector
/// fallback (gold serif "K" in a gold ring) so the splash is never broken.
class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.jpeg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Kingdom Heirs',
      errorBuilder: (_, __, ___) => _LogoFallback(size: size),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.warmWhite,
        boxShadow: AppElevation.shadowFor(AppElevation.level3),
      ),
      padding: EdgeInsets.all(size * 0.18),
      child: FittedBox(
        child: Text(
          'K',
          style: AppTypography.textTheme.displayMedium?.copyWith(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom progress + label
// ─────────────────────────────────────────────────────────────────────────────

class _SplashProgress extends StatelessWidget {
  const _SplashProgress();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final reduceMotion = mq.disableAnimations;
    final screenWidth = mq.size.width;

    // Bar width is responsive — clamped between 200 and 320 logical pixels
    // for a tasteful, narrow progress strip (not a full-width loader).
    final barWidth = (screenWidth * 0.55).clamp(200.0, 320.0);

    return Semantics(
      label: 'Loading the Kingdom Heirs app',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: barWidth,
            child: ClipRRect(
              borderRadius: AppRadius.brFull,
              child: LinearProgressIndicator(
                value: reduceMotion ? 1 : null,
                minHeight: 2,
                backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.gold,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: AppMotion.standard, duration: AppMotion.standard),
          const SizedBox(height: AppSpacing.md),
          Text(
            'PREPARING KINGDOM ASSETS',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.warmWhite.withValues(alpha: 0.55),
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ).animate().fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: AppMotion.standard,
              ),
        ],
      ),
    );
  }
}
