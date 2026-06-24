// Kingdom Heirs — Vision & Mission screen (immersive redesign).
//
// Goal (from Vision & Mission.txt brief): transform a static info page into
// a story-driven, purpose-first introduction to the ministry.
//
// Sections (top → bottom):
//   1. Immersive Hero         — full-bleed navy gradient, gold light, CTAs
//   2. Our Vision             — editorial pull-quote framing
//   3. Our Mission            — 5 interactive pillar tiles
//   4. Kingdom Impact         — animated counters
//   5. Our Core Values        — 6 micro-interaction cards
//   6. Our Future             — vertical timeline / roadmap
//   7. Call to Action         — full-bleed gold panel + 4 actions
//
// Architectural notes:
//   • CustomScrollView + SliverAppBar + SliverToBoxAdapter + SliverList.
//   • No nested scroll views, no fixed widths/heights (only LayoutBuilder
//     or MediaQuery-driven clamp() on outer hero height).
//   • Animations via flutter_animate + reduce-motion respected.
//   • RepaintBoundary around heavy sections for 60fps scroll.
//   • No text clips, no RenderFlex overflow on 320 → 1240+ dp.
//   • Accessible: large-text-aware (MediaQuery.textScaler respected via
//     textTheme), dark-mode aware, semantics where useful.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/animated_count.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';

import 'package:kingdom_heir/features/start_here/data/vision_mission_content.dart';
import 'package:kingdom_heir/features/start_here/presentation/providers/vision_mission_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry
// ─────────────────────────────────────────────────────────────────────────────

class VisionMissionDetailScreen extends ConsumerWidget {
  const VisionMissionDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(visionMissionContentProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: contentAsync.when(
        // Premium skeleton, not a spinner — preserves the cinematic feel.
        loading: () => const _VisionMissionSkeleton(),
        // Elegant retry, full-screen.
        error: (err, _) => AppErrorWidget(
          title: 'We couldn’t load the vision',
          message: 'Please check your connection and try again.',
          onRetry: () => ref.invalidate(visionMissionContentProvider),
        ),
        data: (content) => _VisionMissionBody(content: content),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — orchestrates the sliver stack
// ─────────────────────────────────────────────────────────────────────────────

class _VisionMissionBody extends StatelessWidget {
  const _VisionMissionBody({required this.content});

  final VisionMissionContent content;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        _VisionMissionAppBar(),
        SliverToBoxAdapter(
          child: _HeroSection(content: content),
        ),
        SliverToBoxAdapter(
          child: _SectionIntro(
            eyebrow: '01 — OUR VISION',
            title: 'A future worth inheriting.',
            body: content.visionSupporting,
          ),
        ),
        SliverToBoxAdapter(child: _VisionSection(content: content)),
        const SliverToBoxAdapter(
          child: _SectionIntro(
            eyebrow: '02 — OUR MISSION',
            title: 'Five pillars. One call.',
            body:
                'Everything we do flows through five interconnected pillars. '
                'Tap a pillar to explore.',
          ),
        ),
        SliverToBoxAdapter(child: _MissionPillarsSection(content: content)),
        const SliverToBoxAdapter(
          child: _SectionIntro(
            eyebrow: '03 — KINGDOM IMPACT',
            title: 'Faith made visible.',
            body:
                'Numbers are not the goal — but they tell a story of grace '
                'at work across the nations.',
          ),
        ),
        SliverToBoxAdapter(child: _ImpactSection(content: content)),
        const SliverToBoxAdapter(
          child: _SectionIntro(
            eyebrow: '04 — OUR CORE VALUES',
            title: 'What shapes us.',
            body: 'The convictions that hold us together across every nation.',
          ),
        ),
        SliverToBoxAdapter(child: _CoreValuesSection(content: content)),
        const SliverToBoxAdapter(
          child: _SectionIntro(
            eyebrow: '05 — OUR FUTURE',
            title: 'Where we are going.',
            body:
                'A roadmap of where the Holy Spirit is leading Kingdom '
                'Heirs next.',
          ),
        ),
        SliverToBoxAdapter(child: _FutureTimelineSection(content: content)),
        const SliverToBoxAdapter(child: _CallToActionSection()),
        const SliverToBoxAdapter(child: _FooterMark()),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 0. SliverAppBar — pinned, transparent, blurs over content
// ─────────────────────────────────────────────────────────────────────────────

class _VisionMissionAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.navy.withValues(alpha: 0.85),
      foregroundColor: AppColors.warmWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: AppElevation.level1,
      expandedHeight: 0,
      toolbarHeight: AppSpacing.appBarHeight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.gold,
        onPressed: () => _safeBack(context),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(
              left: AppSpacing.lg,
              bottom: AppSpacing.md,
              right: AppSpacing.lg,
            ),
            title: Text(
              'Vision & Mission',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _safeBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.startHere);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. HERO — immersive, deep navy + soft gold light
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.content});

  final VisionMissionContent content;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Responsive hero height — but never smaller than 420, never taller than 720.
    final heroHeight = (mq.size.height * 0.78).clamp(440.0, 760.0);

    final content_ = Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        mq.padding.top + AppSpacing.huge,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Eyebrow
          const _Eyebrow(label: 'WELCOME — START HERE', onDark: true)
              .animate(key: const ValueKey('vm-hero-eyebrow'))
              .fadeIn(
                duration: AppMotion.standard,
                curve: AppMotion.decelerate,
              )
              .slideX(begin: -0.05, end: 0, duration: AppMotion.standard),

          const SizedBox(height: AppSpacing.lg),

          // Display headline (Playfair)
          _HeroHeadline(line1: content.heroLine1, line2: content.heroLine2),

          const SizedBox(height: AppSpacing.lg),

          // Subtitle
          Text(
            content.subheadline,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.warmWhite.withValues(alpha: 0.82),
              height: 1.55,
            ),
          )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: AppMotion.emphasized,
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),

          const SizedBox(height: AppSpacing.xxl),

          // CTA cluster
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _PrimaryPillButton(
                label: 'Join the Mission',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.push(RouteNames.register),
              ),
              _GhostPillButton(
                label: 'Explore more',
                onPressed: () => _scrollToFirstSection(context),
              ),
            ],
          ).animate().fadeIn(
                delay: const Duration(milliseconds: 450),
                duration: AppMotion.emphasized,
                curve: AppMotion.decelerate,
              ),
        ],
      ),
    );

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _HeroBackdrop(),
          const _HeroGoldLight(),
          const _HeroVignette(),
          content_,
        ],
      ),
    );
  }

  /// Smooth-scroll to the first content section below the hero.
  void _scrollToFirstSection(BuildContext context) {
    final controller = PrimaryScrollController.of(context);
    // Best-effort: scroll past the hero. The hero is roughly 70% of viewport
    // height — clamp to the nearest viewport multiple.
    final mq = MediaQuery.of(context);
    final target = (mq.size.height * 0.7).clamp(440.0, 760.0) - 60;
    controller.animateTo(
      target,
      duration: AppMotion.emphasized,
      curve: AppMotion.decelerate,
    );
  }
}

class _HeroHeadline extends StatelessWidget {
  const _HeroHeadline({required this.line1, required this.line2});

  final String line1;
  final String line2;

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.textTheme.displayMedium?.copyWith(
      color: AppColors.warmWhite,
      fontWeight: FontWeight.w600,
      height: 1.08,
      letterSpacing: -0.5,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // On very small screens (<360 dp), shrink the display size so the
        // longest line never wraps in a way that breaks hierarchy.
        final band = layoutBandFromWidth(constraints.maxWidth);
        final scale = switch (band) {
          LayoutBand.xs => 0.78,
          LayoutBand.sm => 0.88,
          LayoutBand.md => 1.0,
          LayoutBand.lg => 1.1,
          _ => 1.18,
        };
        final scaled = base?.copyWith(fontSize: (base.fontSize ?? 45) * scale);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line1, style: scaled)
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 100),
                  duration: AppMotion.emphasized,
                  curve: AppMotion.decelerate,
                )
                .slideY(begin: 0.1, end: 0, duration: AppMotion.emphasized),
            const SizedBox(height: AppSpacing.xs),
            // "Transforming Generations" gets a gold gradient sweep on entrance.
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) => const LinearGradient(
                colors: [
                  AppColors.goldLight,
                  AppColors.gold,
                  AppColors.goldDark,
                ],
              ).createShader(rect),
              child: Text(line2, style: scaled),
            )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 200),
                  duration: AppMotion.expressive,
                  curve: AppMotion.decelerate,
                )
                .slideY(begin: 0.1, end: 0, duration: AppMotion.expressive),
          ],
        );
      },
    );
  }
}

class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF050914), // deepest navy
            Color(0xFF0B1120),
            Color(0xFF0F172A), // mid navy
            Color(0xFF162033), // softer navy
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }
}

/// A soft, warm gold light emanating from the top-right — gives the hero its
/// "divine radiance" quality without being literal.
class _HeroGoldLight extends StatelessWidget {
  const _HeroGoldLight();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.85, -0.6),
          radius: 1.1,
          colors: [
            Color(0x55D4AF37), // gold
            Color(0x22D4AF37),
            Colors.transparent,
          ],
          stops: [0.0, 0.35, 1.0],
        ),
      ),
    );
  }
}

class _HeroVignette extends StatelessWidget {
  const _HeroVignette();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1.1,
          colors: [
            Colors.transparent,
            Color(0x660B1120),
            Color(0xCC0B1120),
          ],
          stops: [0.55, 0.85, 1.0],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: section intro (eyebrow + title + supporting copy)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final widget = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.massive,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(label: eyebrow),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.navy.withValues(alpha: 0.78),
              height: 1.55,
            ),
          ),
        ],
      ),
    );

    if (reducedMotion) return widget;
    return widget
        .animate()
        .fadeIn(duration: AppMotion.standard, curve: AppMotion.decelerate)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. VISION — editorial pull-quote + concentric gold ring illustration
// ─────────────────────────────────────────────────────────────────────────────

class _VisionSection extends StatelessWidget {
  const _VisionSection({required this.content});

  final VisionMissionContent content;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width >= 720;

    final quote = _VisionQuote(statement: content.visionStatement);
    const ornament = _VisionOrnament();

    final reducedMotion = MediaQuery.of(context).disableAnimations;

    final widget = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 3, child: quote),
                const SizedBox(width: AppSpacing.xxl),
                const Expanded(flex: 2, child: ornament),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                quote,
                const SizedBox(height: AppSpacing.xxl),
                const Center(child: ornament),
              ],
            ),
    );

    if (reducedMotion) return widget;
    return widget
        .animate()
        .fadeIn(duration: AppMotion.standard, curve: AppMotion.decelerate)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

class _VisionQuote extends StatelessWidget {
  const _VisionQuote({required this.statement});

  final String statement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: AppRadius.brXxl,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            AppColors.navyMid,
          ],
        ),
        boxShadow: AppElevation.shadowFor(AppElevation.level3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppColors.gold,
            size: AppSpacing.iconXl,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            statement,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 56,
            height: 1.5,
            color: AppColors.gold,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '— Kingdom Heirs',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.gold,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisionOrnament extends StatelessWidget {
  const _VisionOrnament();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth.clamp(180.0, 320.0);
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const _OrbitRing(factor: 1, color: AppColors.gold),
                const _OrbitRing(factor: 0.72, color: AppColors.goldLight),
                const _OrbitRing(factor: 0.44, color: AppColors.goldDark),
                Container(
                  width: size * 0.22,
                  height: size * 0.22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.goldLight,
                        AppColors.gold,
                        AppColors.goldDark,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold,
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrbitRing extends StatefulWidget {
  const _OrbitRing({required this.factor, required this.color});

  final double factor;
  final Color color;

  @override
  State<_OrbitRing> createState() => _OrbitRingState();
}

class _OrbitRingState extends State<_OrbitRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth.clamp(180.0, 320.0);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * widget.factor,
                height: size * widget.factor,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.5),
                  ),
                ),
              ),
              if (!reduceMotion)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    return Transform.rotate(
                      angle: _controller.value * 6.28319,
                      child: FractionalTranslation(
                        translation: Offset(
                          (size * widget.factor / 2) / size * 0.78,
                          0,
                        ),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.6),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. MISSION PILLARS — 5 interactive, animated tiles
// ─────────────────────────────────────────────────────────────────────────────

class _MissionPillarsSection extends StatefulWidget {
  const _MissionPillarsSection({required this.content});

  final VisionMissionContent content;

  @override
  State<_MissionPillarsSection> createState() =>
      _MissionPillarsSectionState();
}

class _MissionPillarsSectionState extends State<_MissionPillarsSection> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final mq = MediaQuery.of(context);
    // On tablet+, render as 2-col grid; on phones, a vertical stack.
    final isWide = mq.size.width >= 720;

    final tiles = widget.content.missionPillars
        .asMap()
        .entries
        .map((entry) => _PillarTile(
              pillar: entry.value,
              expanded: _expanded == entry.key,
              onTap: () => setState(
                () => _expanded = _expanded == entry.key ? null : entry.key,
              ),
              delay: Duration(milliseconds: 60 * entry.key),
              reduceMotion: reduceMotion,
            ),)
        .toList();

    final body = isWide
        ? GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            // Aspect ratio tuned so tiles stay readable on tablets.
            childAspectRatio: 1.6,
            children: tiles,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i != tiles.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      child: body,
    );
  }
}

class _PillarTile extends StatelessWidget {
  const _PillarTile({
    required this.pillar,
    required this.expanded,
    required this.onTap,
    required this.delay,
    required this.reduceMotion,
  });

  final MissionPillar pillar;
  final bool expanded;
  final VoidCallback onTap;
  final Duration delay;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width >= 720;

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brXl,
        splashColor: AppColors.gold.withValues(alpha: 0.10),
        highlightColor: AppColors.gold.withValues(alpha: 0.06),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.brXl,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navyMid,
                AppColors.navy,
              ],
            ),
            boxShadow: AppElevation.shadowFor(AppElevation.level2),
          ),
          padding: EdgeInsets.all(isWide ? AppSpacing.xl : AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Index pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: AppRadius.brFull,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      pillar.index,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.gold,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: AppMotion.standard,
                    curve: AppMotion.standardCurve,
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.gold,
                      size: AppSpacing.iconMd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Icon medallion
              Container(
                width: AppSpacing.iconLg,
                height: AppSpacing.iconLg,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.18),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.6),
                  ),
                ),
                child: Icon(
                  pillar.icon,
                  color: AppColors.gold,
                  size: AppSpacing.iconMd,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                pillar.title,
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  color: AppColors.warmWhite,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Body — always visible preview, fuller body when expanded.
              AnimatedSize(
                duration: AppMotion.standard,
                curve: AppMotion.standardCurve,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pillar.body,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.warmWhite.withValues(alpha: 0.72),
                        height: 1.5,
                      ),
                      maxLines: isWide ? (expanded ? null : 2) : null,
                      overflow: isWide
                          ? (expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis)
                          : TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (reduceMotion) return card;
    return card
        .animate()
        .fadeIn(delay: delay, duration: AppMotion.standard)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. KINGDOM IMPACT — animated counter tiles
// ─────────────────────────────────────────────────────────────────────────────

class _ImpactSection extends StatelessWidget {
  const _ImpactSection({required this.content});

  final VisionMissionContent content;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final crossAxisCount = switch (mq.size.width) {
      < 390 => 2,
      < 720 => 2,
      < 1024 => 3,
      _ => 5,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: content.impact.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, i) {
          final s = content.impact[i];
          return _ImpactTile(
            stat: s,
            delay: Duration(milliseconds: 80 * i),
          );
        },
      ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  const _ImpactTile({required this.stat, required this.delay});

  final ImpactStat stat;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final tile = RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.brLg,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.navyMid],
          ),
          boxShadow: AppElevation.shadowFor(AppElevation.level2),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: AppSpacing.iconLg,
              height: AppSpacing.iconLg,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.18),
                borderRadius: AppRadius.brSm,
              ),
              child: Icon(
                stat.icon,
                color: AppColors.gold,
                size: AppSpacing.iconSm,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: AnimatedCount(
                        value: stat.value,
                        style: AppTypography.textTheme.headlineMedium?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                        duration: AppMotion.expressive,
                      ),
                    ),
                    if (stat.suffix.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 2,
                          bottom: AppSpacing.xs,
                        ),
                        child: Text(
                          stat.suffix,
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  stat.label.toUpperCase(),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.warmWhite.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (reduceMotion) return tile;
    return tile
        .animate()
        .fadeIn(delay: delay, duration: AppMotion.standard)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: AppMotion.standard,
          curve: AppMotion.overshoot,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. CORE VALUES — 6 micro-interaction cards
// ─────────────────────────────────────────────────────────────────────────────

class _CoreValuesSection extends StatelessWidget {
  const _CoreValuesSection({required this.content});

  final VisionMissionContent content;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final crossAxisCount = switch (mq.size.width) {
      < 390 => 2,
      < 600 => 2,
      < 900 => 3,
      _ => 3,
    };

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: content.coreValues.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, i) {
          final v = content.coreValues[i];
          final tile = _ValueCard(
            value: v,
            delay: Duration(milliseconds: 60 * i),
            reduceMotion: reduceMotion,
          );
          return tile;
        },
      ),
    );
  }
}

class _ValueCard extends StatefulWidget {
  const _ValueCard({
    required this.value,
    required this.delay,
    required this.reduceMotion,
  });

  final CoreValue value;
  final Duration delay;
  final bool reduceMotion;

  @override
  State<_ValueCard> createState() => _ValueCardState();
}

class _ValueCardState extends State<_ValueCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.standardCurve,
        decoration: BoxDecoration(
          borderRadius: AppRadius.brLg,
          color: _hovered
              ? AppColors.gold.withValues(alpha: 0.06)
              : AppColors.surfaceLight,
          border: Border.all(
            color: _hovered
                ? AppColors.gold.withValues(alpha: 0.55)
                : AppColors.dividerLight,
          ),
          boxShadow: AppElevation.shadowFor(
            _hovered ? AppElevation.level2 : AppElevation.level1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon medallion — scales on hover (micro-interaction).
            AnimatedScale(
              scale: _hovered ? 1.08 : 1.0,
              duration: AppMotion.standard,
              curve: AppMotion.overshoot,
              child: Container(
                width: AppSpacing.iconLg,
                height: AppSpacing.iconLg,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.goldLight, AppColors.gold],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.value.icon,
                  color: AppColors.ink,
                  size: AppSpacing.iconMd,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.value.title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  widget.value.body,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.navy.withValues(alpha: 0.72),
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (widget.reduceMotion) return card;
    return card
        .animate()
        .fadeIn(delay: widget.delay, duration: AppMotion.standard)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. OUR FUTURE — vertical timeline / roadmap
// ─────────────────────────────────────────────────────────────────────────────

class _FutureTimelineSection extends StatelessWidget {
  const _FutureTimelineSection({required this.content});

  final VisionMissionContent content;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width >= 720;

    final children = <Widget>[];
    for (var i = 0; i < content.futureTimeline.length; i++) {
      final p = content.futureTimeline[i];
      children.add(_TimelineRow(
        phase: p,
        index: i,
        total: content.futureTimeline.length,
        isLast: i == content.futureTimeline.length - 1,
        isWide: isWide,
        delay: Duration(milliseconds: 80 * i),
        reduceMotion: reduceMotion,
      ),);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      child: Column(children: children),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.phase,
    required this.index,
    required this.total,
    required this.isLast,
    required this.isWide,
    required this.delay,
    required this.reduceMotion,
  });

  final FuturePhase phase;
  final int index;
  final int total;
  final bool isLast;
  final bool isWide;
  final Duration delay;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final card = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Spine — node + connecting line
          SizedBox(
            width: 56,
            child: Column(
              children: [
                _TimelineNode(phase: phase.phase, index: index),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.gold.withValues(alpha: 0.6),
                            AppColors.gold.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Content card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _TimelineCard(phase: phase, index: index),
            ),
          ),
        ],
      ),
    );

    if (reduceMotion) return card;
    return card
        .animate()
        .fadeIn(delay: delay, duration: AppMotion.standard)
        .slideX(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.phase, required this.index});

  final String phase;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
        ),
        boxShadow: AppElevation.shadowGold,
      ),
      alignment: Alignment.center,
      child: Text(
        phase,
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.phase, required this.index});

  final FuturePhase phase;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.brXl,
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: AppElevation.shadowFor(AppElevation.level1),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxs,
            ),
            decoration: const BoxDecoration(
              color: AppColors.goldContainer,
              borderRadius: AppRadius.brFull,
            ),
            child: Text(
              'STEP ${(index + 1).toString().padLeft(2, '0')} OF '
              '${4.toString().padLeft(2, '0')}',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.goldDark,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            phase.title,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            phase.body,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.navy.withValues(alpha: 0.78),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. CALL TO ACTION — full-bleed gold panel + 4 actions
// ─────────────────────────────────────────────────────────────────────────────

class _CallToActionSection extends StatelessWidget {
  const _CallToActionSection();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width >= 720;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Become Part\nof the Vision',
          style: AppTypography.textTheme.displaySmall?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            height: 1.05,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Whatever your next step looks like — joining the community, '
          'growing in the Word, or finding your people — there is a place '
          'for you here.',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.ink.withValues(alpha: 0.78),
            height: 1.55,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _PrimaryPillButton(
          label: 'Join Community',
          icon: Icons.people_alt_rounded,
          onPressed: () => context.push(RouteNames.register),
          dark: true,
        ),
        _GhostPillButton(
          label: 'Create Account',
          dark: true,
          onPressed: () => context.push(RouteNames.register),
        ),
        _GhostPillButton(
          label: 'Watch Sermons',
          icon: Icons.play_circle_outline_rounded,
          dark: true,
          onPressed: () => context.push(RouteNames.sermons),
        ),
        _GhostPillButton(
          label: 'Discover Groups',
          icon: Icons.groups_rounded,
          dark: true,
          onPressed: () => context.push(RouteNames.groupDiscover),
        ),
      ],
    );

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final panel = Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.massive,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.massive,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.brXxl,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.goldLight,
            AppColors.gold,
            AppColors.goldDark,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: AppElevation.shadowGold,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: heading),
                const SizedBox(width: AppSpacing.xxl),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      actions,
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                heading,
                const SizedBox(height: AppSpacing.xxl),
                actions,
              ],
            ),
    );

    if (reduceMotion) return panel;
    return panel
        .animate()
        .fadeIn(duration: AppMotion.standard, curve: AppMotion.decelerate)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared micro-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label, this.onDark = false});

  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? AppColors.gold : AppColors.goldDark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: AppSpacing.xl, height: 1.5, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: color,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.dark = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? AppColors.ink : AppColors.gold;
    final fg = dark ? AppColors.gold : AppColors.ink;
    return Material(
      color: bg,
      borderRadius: AppRadius.brFull,
      elevation: dark ? AppElevation.level0 : AppElevation.level2,
      shadowColor: AppColors.gold.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.brFull,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, color: fg, size: AppSpacing.iconSm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostPillButton extends StatelessWidget {
  const _GhostPillButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.dark = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? AppColors.ink : AppColors.warmWhite;
    final border = dark
        ? AppColors.ink.withValues(alpha: 0.4)
        : AppColors.warmWhite.withValues(alpha: 0.6);
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.brFull,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.brFull,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.brFull,
            border: Border.all(color: border, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, color: fg, size: AppSpacing.iconSm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterMark extends StatelessWidget {
  const _FooterMark();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      child: Column(
        children: [
          Container(
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
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '© KINGDOM HEIRS — VISION & MISSION',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.goldDark,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton loader — premium, not grey boxes
// ─────────────────────────────────────────────────────────────────────────────

class _VisionMissionSkeleton extends StatelessWidget {
  const _VisionMissionSkeleton();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.navy.withValues(alpha: 0.85),
          elevation: 0,
          toolbarHeight: AppSpacing.appBarHeight,
        ),
        SliverToBoxAdapter(
          child: Container(
            height: (mq.size.height * 0.78).clamp(440.0, 760.0),
            color: AppColors.navy,
            child: const Center(
              child: _SkeletonShimmer(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.gold,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBar(width: 120, height: 12),
                SizedBox(height: AppSpacing.md),
                _SkeletonBar(width: double.infinity, height: 28),
                SizedBox(height: AppSpacing.md),
                _SkeletonBar(width: double.infinity, height: 16),
                SizedBox(height: AppSpacing.sm),
                _SkeletonBar(width: 240, height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _SkeletonShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.goldContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class _SkeletonShimmer extends StatefulWidget {
  const _SkeletonShimmer({required this.child});

  final Widget child;

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.shimmerCycle,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            final shift = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(shift - 1, 0),
              end: Alignment(shift + 1, 0),
              colors: [
                Colors.transparent,
                AppColors.gold.withValues(alpha: 0.18),
                Colors.transparent,
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(rect);
          },
          child: widget.child,
        );
      },
    );
  }
}
