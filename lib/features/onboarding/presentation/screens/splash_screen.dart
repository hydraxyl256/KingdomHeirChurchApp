import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
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
        gradient: RadialGradient(
          center: Alignment(0, -0.8), // Top center lighting
          radius: 1.5,
          colors: [
            Color(0xFF141B2D), // Subtle top lighting
            Color(0xFF0E1323), // Deep background
          ],
          stops: [0.0, 1.0],
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
    final mq = MediaQuery.of(context);
    // 110–140dp per spec: large enough to read clearly, never oversized.
    final logoSize = (mq.size.shortestSide * 0.28).clamp(110.0, 140.0);
    const reservedBottom = AppSpacing.huge + AppSpacing.xxxl;
    final logoContainer = Semantics(
      label: 'Kingdom Heirs',
      image: true,
      child: Container(
        width: logoSize,
        height: logoSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.warmWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.35),
              blurRadius: 40,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/app_icon.png',
            fit: BoxFit.cover,
            semanticLabel: 'Kingdom Heirs logo',
            errorBuilder: (_, __, ___) => _LogoFallback(size: logoSize),
          ),
        ),
      ),
    );

    final title = Text(
      'KINGDOM HEIRS',
      style: AppTypography.textTheme.headlineSmall?.copyWith(
        color: AppColors.gold,
        fontWeight: FontWeight.w800,
        letterSpacing: 4,
      ),
    );

    final subtitle = Text(
      'INHERITING EXCELLENCE',
      style: AppTypography.textTheme.labelMedium?.copyWith(
        color: AppColors.goldLight.withValues(alpha: 0.8),
        letterSpacing: 3,
        fontWeight: FontWeight.w600,
      ),
    );

    // One-shot logo entrance: scale 0.9→1.0 + fadeIn (600ms).
    // No repeating pulse — per spec: no bouncing, no oversized scaling.
    final animatedLogo = reduceMotion
        ? logoContainer
        : logoContainer
            .animate()
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: 500.ms, curve: AppMotion.decelerate);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        animatedLogo,
        const SizedBox(height: AppSpacing.xxxl),
        title,
        const SizedBox(height: AppSpacing.sm),
        subtitle,
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: reservedBottom),
      child: content,
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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.goldDark, AppColors.gold, AppColors.goldLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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

    // Bar width is responsive — clamped between 150 and 240 logical pixels.
    final barWidth = (screenWidth * 0.4).clamp(150.0, 240.0);

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
                minHeight: 2.5,
                backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.gold,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: AppMotion.standard, duration: AppMotion.standard),
        ],
      ),
    );
  }
}
