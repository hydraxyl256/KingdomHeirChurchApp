import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/theme/spacing.dart';

/// Kingdom Heirs — Start Here (redesigned)
///
/// A modern onboarding experience, not a card list.
/// Sections (top → bottom):
///   1. Hero — full-bleed navy gradient, gold accent line, animated headline.
///   2. Vision preview — Netflix-style horizontal scroll of pillar tiles.
///   3. Founder story — editorial layout: portrait card + pull-quote + CTA.
///   4. Statement of Faith — numbered accordion of pillars (YouVersion feel).
///   5. Church impact — animated stat tiles (Apple HIG counter presentation).
///   6. Join community CTA — full-bleed gold gradient panel + dual actions.
class StartHereHubScreen extends ConsumerWidget {
  const StartHereHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const _StartHereAppBar(),
          const SliverToBoxAdapter(
            child: _HeroSection(),
          ),
          const SliverToBoxAdapter(
            child: _SectionHeader(
              eyebrow: '01 — OUR VISION',
              title: 'A future worth inheriting.',
            ),
          ),
          SliverToBoxAdapter(
            child: _VisionPreviewSection(reduceMotion: reduceMotion),
          ),
          const SliverToBoxAdapter(
            child: _SectionHeader(
              eyebrow: '02 — THE FOUNDER',
              title: 'A letter from our father in faith.',
            ),
          ),
          const SliverToBoxAdapter(child: _FounderStorySection()),
          const SliverToBoxAdapter(
            child: _SectionHeader(
              eyebrow: '03 — STATEMENT OF FAITH',
              title: 'What we believe.',
            ),
          ),
          const SliverToBoxAdapter(child: _StatementOfFaithSection()),
          const SliverToBoxAdapter(
            child: _SectionHeader(
              eyebrow: '04 — OUR IMPACT',
              title: 'Kingdom across the nations.',
            ),
          ),
          const SliverToBoxAdapter(child: _ImpactSection()),
          const SliverToBoxAdapter(child: _JoinCommunityCta()),
          const SliverToBoxAdapter(child: _FooterMark()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar — transparent, scrolls under content
// ─────────────────────────────────────────────────────────────────────────────

class _StartHereAppBar extends StatelessWidget {
  const _StartHereAppBar();

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
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: AppSpacing.lg,
          bottom: AppSpacing.md,
          right: AppSpacing.lg,
        ),
        title: Text(
          'Kingdom Heirs',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. HERO
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final heroHeight = (mq.size.height * 0.7).clamp(420.0, 720.0);

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.massive,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Eyebrow
          const _Eyebrow(label: 'WELCOME TO KINGDOM HEIRS')
              .animate(key: const ValueKey('hero-eyebrow'))
              .fadeIn(
                duration: AppMotion.standard,
                curve: AppMotion.decelerate,
              ),
          const SizedBox(height: AppSpacing.md),

          // Headline — Playfair display
          Text(
            'Inheriting a legacy of\nexcellence.',
            style: AppTypography.textTheme.displaySmall?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 100),
                duration: AppMotion.emphasized,
                curve: AppMotion.decelerate,
              )
              .slideY(
                begin: 0.08,
                end: 0,
                duration: AppMotion.emphasized,
                curve: AppMotion.decelerate,
              ),

          const SizedBox(height: AppSpacing.lg),

          // Subtitle
          Text(
            'A modern community built on timeless truth — discover who we '
            'are, what we believe, and where we are going.',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.warmWhite.withValues(alpha: 0.78),
              height: 1.55,
            ),
          ).animate().fadeIn(
                delay: const Duration(milliseconds: 250),
                duration: AppMotion.emphasized,
                curve: AppMotion.decelerate,
              ),

          const SizedBox(height: AppSpacing.xxl),

          // CTA cluster
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _PrimaryPillButton(
                label: 'Begin the journey',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.push(RouteNames.startHereVision),
              ),
              _GhostPillButton(
                label: 'I already have an account',
                onPressed: () => context.push(RouteNames.login),
              ),
            ],
          ).animate().fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: AppMotion.emphasized,
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
          // Layered background
          const _HeroBackdrop(),
          // Soft vignette + top fade for app bar legibility
          const _HeroVignette(),
          // Content
          content,
        ],
      ),
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
            Color(0xFF0B1120), // deepest navy
            Color(0xFF0F172A), // mid navy
            Color(0xFF162033), // softer navy
          ],
          stops: [0.0, 0.5, 1.0],
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
// Section header — used between hero and content sections
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.massive,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(label: eyebrow, onDark: false),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    if (reducedMotion) return header;

    return header
        .animate()
        .fadeIn(duration: AppMotion.standard, curve: AppMotion.decelerate)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label, this.onDark = true});

  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? AppColors.gold : AppColors.goldDark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSpacing.xl,
          height: 1.5,
          color: color,
        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// 2. VISION PREVIEW — horizontal scroll of pillar tiles
// ─────────────────────────────────────────────────────────────────────────────

class _VisionPreviewSection extends StatelessWidget {
  const _VisionPreviewSection({required this.reduceMotion});

  final bool reduceMotion;

  static const _pillars = <_PillarData>[
    _PillarData(
      index: '01',
      title: 'Kingdom',
      body: 'Building lives that advance God’s rule on earth.',
      icon: Icons.account_balance_rounded,
      tint: AppColors.gold,
    ),
    _PillarData(
      index: '02',
      title: 'Excellence',
      body: 'Worship rendered with skill, beauty, and integrity.',
      icon: Icons.auto_awesome_rounded,
      tint: AppColors.goldLight,
    ),
    _PillarData(
      index: '03',
      title: 'Reverence',
      body: 'Awe for the Holy that shapes everything we do.',
      icon: Icons.local_fire_department_rounded,
      tint: AppColors.goldDark,
    ),
    _PillarData(
      index: '04',
      title: 'Modernity',
      body: 'Timeless truth, expressed through contemporary design.',
      icon: Icons.bolt_rounded,
      tint: AppColors.gold,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _pillars.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final p = _pillars[i];
          return _PillarTile(
            data: p,
            onTap: () => context.push(RouteNames.startHereVision),
            delay: Duration(milliseconds: 60 * i),
            reduceMotion: reduceMotion,
          );
        },
      ),
    );
  }
}

class _PillarData {
  const _PillarData({
    required this.index,
    required this.title,
    required this.body,
    required this.icon,
    required this.tint,
  });

  final String index;
  final String title;
  final String body;
  final IconData icon;
  final Color tint;
}

class _PillarTile extends StatelessWidget {
  const _PillarTile({
    required this.data,
    required this.onTap,
    required this.delay,
    required this.reduceMotion,
  });

  final _PillarData data;
  final VoidCallback onTap;
  final Duration delay;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final tileWidth =
        (MediaQuery.of(context).size.width * 0.74).clamp(240.0, 320.0);

    final Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brXl,
        splashColor: data.tint.withValues(alpha: 0.10),
        highlightColor: data.tint.withValues(alpha: 0.06),
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
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Index pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: data.tint.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brFull,
                  border: Border.all(
                    color: data.tint.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  data.index,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: data.tint,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Icon medallion
              Container(
                width: AppSpacing.iconLg,
                height: AppSpacing.iconLg,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.tint.withValues(alpha: 0.18),
                  border: Border.all(
                    color: data.tint.withValues(alpha: 0.6),
                  ),
                ),
                child:
                    Icon(data.icon, color: data.tint, size: AppSpacing.iconMd),
              ),
              // Title + body
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.warmWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    data.body,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmWhite.withValues(alpha: 0.72),
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
      ),
    );

    final sized = SizedBox(
      width: tileWidth,
      height: 280,
      child: card,
    );

    if (reduceMotion) return sized;
    return sized
        .animate()
        .fadeIn(delay: delay, duration: AppMotion.standard)
        .slideX(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. FOUNDER STORY — editorial layout
// ─────────────────────────────────────────────────────────────────────────────

class _FounderStorySection extends StatelessWidget {
  const _FounderStorySection();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width >= 720;
    const padding = EdgeInsets.symmetric(horizontal: AppSpacing.lg);

    const portrait = _FounderPortrait();
    final body = _FounderBody(
      onReadLetter: () => context.push(RouteNames.startHereFounder),
    );

    final children = isWide
        ? <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: portrait),
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: body),
              ],
            ),
          ]
        : <Widget>[
            portrait,
            const SizedBox(height: AppSpacing.xl),
            body,
          ];

    return Padding(
      padding: padding.add(const EdgeInsets.only(bottom: AppSpacing.massive)),
      child: Column(children: children),
    );
  }
}

class _FounderPortrait extends StatelessWidget {
  const _FounderPortrait();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.brXl,
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Stack(
          children: [
            // Decorative gold frame
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.brXl,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
              ),
            ),
            // Center content (placeholder until asset exists)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: AppSpacing.avatarXl,
                    height: AppSpacing.avatarXl,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppColors.gold,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: AppSpacing.iconXl,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Pastor J. Mwila',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.warmWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'FOUNDER & SENIOR PASTOR',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.gold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FounderBody extends StatelessWidget {
  const _FounderBody({required this.onReadLetter});

  final VoidCallback onReadLetter;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pull quote
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.goldContainer.withValues(alpha: 0.6),
            border: const Border(
              left: BorderSide(
                color: AppColors.gold,
                width: 3,
              ),
            ),
            borderRadius: AppRadius.brSm,
          ),
          child: Text(
            '"We did not build this for ourselves — we built it for the next '
            'generation of heirs."',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.navy,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        Text(
          'Kingdom Heirs began with a single conviction: that excellence is a '
          'form of worship. From a small Bible study in 2014 to a global '
          'family across continents, our story is one of faith, craft, and '
          'covenant.',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.navy.withValues(alpha: 0.85),
            height: 1.6,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          'Today, we continue that work — discipling leaders, planting '
          'communities, and stewarding the inheritance passed to us.',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.navy.withValues(alpha: 0.85),
            height: 1.6,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        _GhostPillButton(
          label: 'Read the full letter',
          icon: Icons.arrow_forward_rounded,
          onPressed: onReadLetter,
        ),
      ],
    );

    if (reducedMotion) return content;

    return content
        .animate()
        .fadeIn(duration: AppMotion.standard, curve: AppMotion.decelerate)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. STATEMENT OF FAITH — numbered accordion
// ─────────────────────────────────────────────────────────────────────────────

class _StatementOfFaithSection extends StatefulWidget {
  const _StatementOfFaithSection();

  @override
  State<_StatementOfFaithSection> createState() =>
      _StatementOfFaithSectionState();
}

class _StatementOfFaithSectionState extends State<_StatementOfFaithSection> {
  int? _expanded;

  static const _pillars = <_FaithPillar>[
    _FaithPillar(
      number: 'I',
      title: 'The Bible',
      body: 'We believe the Scriptures are God-breathed, infallible, and the '
          'final authority for faith and practice.',
      icon: Icons.menu_book_rounded,
    ),
    _FaithPillar(
      number: 'II',
      title: 'The Triune God',
      body: 'One God, eternally existent in three Persons — Father, Son, and '
          'Holy Spirit — co-equal and co-eternal.',
      icon: Icons.workspace_premium_rounded,
    ),
    _FaithPillar(
      number: 'III',
      title: 'Salvation by Grace',
      body: 'Salvation is the gift of grace, received through faith in Jesus '
          'Christ — not by works, but unto good works.',
      icon: Icons.favorite_rounded,
    ),
    _FaithPillar(
      number: 'IV',
      title: 'The Church',
      body: 'The Church is the body of Christ, called to worship, to disciple '
          'the nations, and to serve the poor.',
      icon: Icons.diversity_3_rounded,
    ),
    _FaithPillar(
      number: 'V',
      title: 'The Return of Christ',
      body: 'We await the glorious return of our Lord, the resurrection of the '
          'dead, and the renewal of all things.',
      icon: Icons.public_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Material(
        color: AppColors.white,
        elevation: AppElevation.level1,
        shadowColor: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: AppRadius.brXl,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < _pillars.length; i++) ...[
              _FaithRow(
                pillar: _pillars[i],
                expanded: _expanded == i,
                onTap: () =>
                    setState(() => _expanded = _expanded == i ? null : i),
                reduceMotion: reduceMotion,
                delay: Duration(milliseconds: 40 * i),
              ),
              if (i != _pillars.length - 1)
                const Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                  color: AppColors.dividerLight,
                ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: AppMotion.standard, curve: AppMotion.decelerate)
        .slideY(begin: 0.04, end: 0, duration: AppMotion.standard);
  }
}

class _FaithPillar {
  const _FaithPillar({
    required this.number,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String number;
  final String title;
  final String body;
  final IconData icon;
}

class _FaithRow extends StatelessWidget {
  const _FaithRow({
    required this.pillar,
    required this.expanded,
    required this.onTap,
    required this.reduceMotion,
    required this.delay,
  });

  final _FaithPillar pillar;
  final bool expanded;
  final VoidCallback onTap;
  final bool reduceMotion;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final Widget content = InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.iconXl,
              height: AppSpacing.iconXl,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldContainer,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(pillar.icon,
                  color: AppColors.goldDark, size: AppSpacing.iconMd,),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pillar.number,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.goldDark,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    pillar.title,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: AppMotion.standard,
              curve: AppMotion.standardCurve,
              child: const Icon(
                Icons.expand_more_rounded,
                color: AppColors.goldDark,
                size: AppSpacing.iconMd,
              ),
            ),
          ],
        ),
      ),
    );

    final Widget wrapped = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        content,
        AnimatedSize(
          duration: AppMotion.standard,
          curve: AppMotion.standardCurve,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(
                    // 24 (icon) + 12 (gap) + 16 (lg) = icon + gap + screen lg
                    AppSpacing.iconXl + AppSpacing.md + AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Text(
                    pillar.body,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.navy.withValues(alpha: 0.78),
                      height: 1.55,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );

    if (reduceMotion) return wrapped;
    return wrapped
        .animate()
        .fadeIn(delay: delay, duration: AppMotion.standard)
        .slideX(begin: 0.04, end: 0, duration: AppMotion.standard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. IMPACT — animated stat tiles
// ─────────────────────────────────────────────────────────────────────────────

class _ImpactSection extends StatelessWidget {
  const _ImpactSection();

  static const _stats = <_StatData>[
    _StatData(
        label: 'Nations', value: '42', suffix: '+', icon: Icons.public_rounded,),
    _StatData(
        label: 'Members',
        value: '12K',
        suffix: '',
        icon: Icons.people_alt_rounded,),
    _StatData(
        label: 'Lives Changed',
        value: '8.4',
        suffix: 'K',
        icon: Icons.favorite_rounded,),
    _StatData(
        label: 'Years of Faith',
        value: '11',
        suffix: '',
        icon: Icons.calendar_month_rounded,),
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final crossAxisCount = mq.size.width >= 720 ? 4 : 2;

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
        itemCount: _stats.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, i) {
          final s = _stats[i];
          return _StatTile(
            data: s,
            delay: Duration(milliseconds: 80 * i),
          );
        },
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
  });

  final String label;
  final String value;
  final String suffix;
  final IconData icon;
}

class _StatTile extends StatefulWidget {
  const _StatTile({required this.data, required this.delay});

  final _StatData data;
  final Duration delay;

  @override
  State<_StatTile> createState() => _StatTileState();
}

class _StatTileState extends State<_StatTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.expressive,
    );
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return RepaintBoundary(
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
              child: Icon(widget.data.icon,
                  color: AppColors.gold, size: AppSpacing.iconSm,),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (reduceMotion)
                      Text(
                        widget.data.value,
                        style: AppTypography.textTheme.displaySmall?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      )
                    else
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (_, __) {
                          // Eased count from 0 → target value.
                          final t =
                              Curves.easeOutCubic.transform(_controller.value);
                          final displayed = _formatValue(widget.data.value, t);
                          return Text(
                            displayed,
                            style:
                                AppTypography.textTheme.displaySmall?.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          );
                        },
                      ),
                    if (widget.data.suffix.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 2, bottom: AppSpacing.xs,),
                        child: Text(
                          widget.data.suffix,
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
                  widget.data.label.toUpperCase(),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.warmWhite.withValues(alpha: 0.7),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: widget.delay, duration: AppMotion.standard).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: AppMotion.standard,
          curve: AppMotion.overshoot,
        );
  }

  /// Interpolates the displayed text from the empty string to the target
  /// value as [t] progresses 0→1.
  String _formatValue(String target, double t) {
    // Try to parse as a number with optional decimal.
    final numeric = double.tryParse(target);
    if (numeric == null) {
      // Non-numeric (e.g. "12K") — reveal at the end of the animation.
      if (t > 0.85) return target;
      // Show a placeholder fade-in.
      return target.replaceAll(RegExp('[A-Za-z]'), '·');
    }
    final v = numeric * t;
    if (target.contains('.')) {
      return v.toStringAsFixed(1);
    }
    return v.round().toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. JOIN COMMUNITY CTA — gold gradient panel
// ─────────────────────────────────────────────────────────────────────────────

class _JoinCommunityCta extends StatelessWidget {
  const _JoinCommunityCta();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width >= 720;

    final children = <Widget>[
      const _Eyebrow(label: '05 — JOIN US'),
      const SizedBox(height: AppSpacing.md),
      Text(
        'Become part of\nthe story.',
        style: AppTypography.textTheme.displaySmall?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
        textAlign: TextAlign.left,
      ),
      const SizedBox(height: AppSpacing.lg),
      Text(
        'Create your account in under a minute. We will walk with you through '
        'every next step — community, prayer, Bible, and growth.',
        style: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.ink.withValues(alpha: 0.78),
          height: 1.55,
        ),
      ),
      const SizedBox(height: AppSpacing.xxl),
      Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          _PrimaryPillButton(
            label: 'Create account',
            icon: Icons.person_add_rounded,
            onPressed: () => context.push(RouteNames.register),
            dark: true,
          ),
          _GhostPillButton(
            label: 'Sign in',
            dark: true,
            onPressed: () => context.push(RouteNames.login),
          ),
        ],
      ),
    ];

    final Widget panel = Container(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                const _CtaOrnament(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
    );

    return panel
        .animate()
        .fadeIn(duration: AppMotion.standard, curve: AppMotion.decelerate)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.standard);
  }
}

class _CtaOrnament extends StatelessWidget {
  const _CtaOrnament();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.ink.withValues(alpha: 0.10),
          border: Border.all(
            color: AppColors.ink.withValues(alpha: 0.25),
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.church_rounded,
            size: AppSpacing.iconXl * 1.4,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer mark
// ─────────────────────────────────────────────────────────────────────────────

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
            '© KINGDOM HEIRS',
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
// Shared buttons
// ─────────────────────────────────────────────────────────────────────────────

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
