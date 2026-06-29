// Kingdom Heir — Start Here: Premium Onboarding Experience
//
// 4-page PageView flow that warmly welcomes first-time visitors and
// guides them naturally toward Register or Sign In.
//
//   Page 0 — Welcome        (hero, logo, CTAs)
//   Page 1 — Discover       (5 discovery cards with Learn More)
//   Page 2 — Experience     (6 church-life value rows)
//   Page 3 — Join the Family (closing CTA)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root — manages page state, progress indicator, navigation
// ─────────────────────────────────────────────────────────────────────────────

class StartHereHubScreen extends StatefulWidget {
  const StartHereHubScreen({super.key});

  @override
  State<StartHereHubScreen> createState() => _StartHereHubScreenState();
}

class _StartHereHubScreenState extends State<StartHereHubScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _pageCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: AppMotion.emphasized,
        curve: AppMotion.decelerate,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppMotion.emphasized,
        curve: AppMotion.decelerate,
      );
    }
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: AppMotion.emphasized,
      curve: AppMotion.decelerate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _currentPage == 0 || _currentPage == 3;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColors.navy,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColors.backgroundLight,
            ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Stack(
          children: [
            // ── Pages ──────────────────────────────────────────────────────
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _WelcomePage(onExplore: _nextPage),
                _DiscoverPage(
                  onNext: _nextPage,
                  onBack: _previousPage,
                ),
                _ExperiencePage(
                  onNext: _nextPage,
                  onBack: _previousPage,
                ),
                _JoinFamilyPage(onBack: _previousPage),
              ],
            ),

            // ── Progress dot indicator (center-bottom, only on pages 1-3) ──
            if (_currentPage > 0)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 0,
                right: 0,
                child: _DotIndicator(
                  count: _pageCount,
                  current: _currentPage,
                  onDotTap: _goToPage,
                  dark: _currentPage == 3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dot Progress Indicator
// ─────────────────────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.count,
    required this.current,
    required this.onDotTap,
    this.dark = false,
  });

  final int count;
  final int current;
  final void Function(int) onDotTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return GestureDetector(
          onTap: () => onDotTap(i),
          child: AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.decelerate,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? (dark ? AppColors.goldLight : AppColors.goldDark)
                  : (dark
                      ? Colors.white.withValues(alpha: 0.35)
                      : AppColors.navy.withValues(alpha: 0.2)),
              borderRadius: AppRadius.brCircle,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 0 — Welcome
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A1628), // deepest navy
            Color(0xFF0F172A), // navy
            Color(0xFF1E3A8A), // royal blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative radial glow behind logo
          Positioned(
            top: size.height * 0.18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                size.height * 0.08,
                AppSpacing.xl,
                safeBottom + 80,
              ),
              child: Column(
                children: [
                  // Church logo mark
                  _ChurchLogoMark()
                      .animate()
                      .fadeIn(duration: AppMotion.reverent)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: AppMotion.reverent,
                        curve: AppMotion.decelerate,
                      ),

                  SizedBox(height: size.height * 0.05),

                  // Headline
                  Text(
                    'Welcome to\nKingdom Heirs',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        delay: 300.ms,
                        duration: 500.ms,
                        curve: AppMotion.decelerate,
                      ),

                  const SizedBox(height: AppSpacing.lg),

                  // Mission statement
                  Text(
                    'A global family built on faith, love,\nand the Word of God.',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 480.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        delay: 480.ms,
                        duration: 500.ms,
                        curve: AppMotion.decelerate,
                      ),

                  const Spacer(),

                  // Gold separator
                  Container(
                    width: 48,
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.goldDark, AppColors.gold],
                      ),
                      borderRadius: AppRadius.brCircle,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 400.ms)
                      .scaleX(
                        begin: 0,
                        end: 1,
                        delay: 600.ms,
                        duration: 600.ms,
                        curve: AppMotion.decelerate,
                      ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Primary CTA — Explore
                  _GoldButton(
                    label: 'Explore Kingdom Heirs',
                    icon: Icons.arrow_forward_rounded,
                    onTap: onExplore,
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 700.ms,
                        duration: 400.ms,
                        curve: AppMotion.decelerate,
                      ),

                  const SizedBox(height: AppSpacing.md),

                  // Secondary CTA — Sign In
                  _OutlineButton(
                    label: 'Sign In',
                    onTap: () => context.push(RouteNames.login),
                  ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // Tertiary — Create Account
                  GestureDetector(
                    onTap: () => context.push(RouteNames.register),
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                        children: [
                          TextSpan(
                            text: 'Create one',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.goldLight,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 900.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // Swipe hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe_right_rounded,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Swipe to explore',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.35),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1100.ms, duration: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 1 — Discover Kingdom Heirs
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage({required this.onNext, required this.onBack});

  final VoidCallback onNext;
  final VoidCallback onBack;

  static const _cards = [
    _DiscoverCardData(
      icon: Icons.visibility_rounded,
      color: Color(0xFF1E3A8A),
      title: 'Our Vision',
      description: 'Raising Kingdom Heirs who carry the glory of God to every nation on earth.',
      route: RouteNames.startHereVision,
    ),
    _DiscoverCardData(
      icon: Icons.history_edu_rounded,
      color: Color(0xFFA88B1D),
      title: 'Our Story',
      description: "From a small prayer meeting to a global movement — God's faithfulness on display.",
      route: RouteNames.startHereStory,
    ),
    _DiscoverCardData(
      icon: Icons.auto_stories_rounded,
      color: Color(0xFF15803D),
      title: 'What We Believe',
      description: 'Rooted in Scripture. Our statement of faith defines who we are and how we live.',
      route: RouteNames.startHereStatementOfFaith,
    ),
    _DiscoverCardData(
      icon: Icons.person_rounded,
      color: Color(0xFF7C3AED),
      title: 'Meet Our Founder',
      description: 'A personal letter from the spiritual father of Kingdom Heirs Church.',
      route: RouteNames.startHereFounder,
    ),
    _DiscoverCardData(
      icon: Icons.church_rounded,
      color: Color(0xFFDC2626),
      title: 'Join Us This Sunday',
      description: 'Sunday Worship at 9 AM · In-person & Online. Come experience church family.',
      route: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            _PageTopBar(
              eyebrow: 'DISCOVER',
              title: 'Know who we are.',
              onBack: onBack,
            ),
            // Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  100, // space for dot indicator
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _cards.length,
                itemBuilder: (context, i) {
                  final card = _cards[i];
                  return _DiscoverCard(
                    data: card,
                    index: i,
                  );
                },
              ),
            ),
            // Next
            _BottomNav(onNext: onNext, onBack: onBack, label: 'Experience Life'),
          ],
        ),
      ),
    );
  }
}

class _DiscoverCardData {
  const _DiscoverCardData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.route,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String? route;
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({required this.data, required this.index});

  final _DiscoverCardData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.brLg,
        child: InkWell(
          onTap: data.route != null
              ? () => context.push(data.route!)
              : null,
          borderRadius: AppRadius.brLg,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.brLg,
              border: Border.all(color: AppColors.dividerLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Color accent bar
                Container(
                  width: 4,
                  height: 80,
                  decoration: BoxDecoration(
                    color: data.color,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.lg),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.brMd,
                  ),
                  child: Icon(data.icon, color: data.color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                // Text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.title,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.description,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // Arrow
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: data.route != null
                        ? data.color
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 80 + index * 70),
            duration: AppMotion.standard,
          )
          .slideX(
            begin: 0.06,
            end: 0,
            delay: Duration(milliseconds: 80 + index * 70),
            duration: AppMotion.standard,
            curve: AppMotion.decelerate,
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 2 — Experience Church Life
// ─────────────────────────────────────────────────────────────────────────────

class _ExperiencePage extends StatelessWidget {
  const _ExperiencePage({required this.onNext, required this.onBack});

  final VoidCallback onNext;
  final VoidCallback onBack;

  static const _features = [
    _FeatureData(
      emoji: '📖',
      color: Color(0xFF1E3A8A),
      title: 'Daily Bible Reading',
      benefit: 'Follow curated Bible plans and grow your knowledge of Scripture every day.',
    ),
    _FeatureData(
      emoji: '🎧',
      color: Color(0xFF7C3AED),
      title: 'Sermons & Podcasts',
      benefit: 'Access powerful messages from our pastors, anytime, anywhere.',
    ),
    _FeatureData(
      emoji: '🙏',
      color: Color(0xFF0EA5E9),
      title: 'Prayer Community',
      benefit: 'Submit requests and stand in faith with thousands who pray together.',
    ),
    _FeatureData(
      emoji: '👥',
      color: Color(0xFF15803D),
      title: 'Community Groups',
      benefit: 'Connect in small groups for deeper fellowship, growth, and accountability.',
    ),
    _FeatureData(
      emoji: '📅',
      color: Color(0xFFA88B1D),
      title: 'Church Events',
      benefit: 'Never miss a service, conference, or special gathering near you.',
    ),
    _FeatureData(
      emoji: '❤️',
      color: Color(0xFFDC2626),
      title: 'Giving & Stewardship',
      benefit: 'Give securely and track your faithfulness toward Kingdom purposes.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageTopBar(
              eyebrow: 'EXPERIENCE',
              title: 'What awaits you.',
              onBack: onBack,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  100,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _features.length,
                itemBuilder: (context, i) {
                  return _FeatureRow(data: _features[i], index: i);
                },
              ),
            ),
            _BottomNav(
              onNext: onNext,
              onBack: onBack,
              label: 'Join the Family',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.emoji,
    required this.color,
    required this.title,
    required this.benefit,
  });

  final String emoji;
  final Color color;
  final String title;
  final String benefit;
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.data, required this.index});

  final _FeatureData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.brLg,
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.08),
                borderRadius: AppRadius.brMd,
              ),
              child: Center(
                child: Text(
                  data.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.benefit,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 60 + index * 60),
            duration: AppMotion.standard,
          )
          .slideY(
            begin: 0.06,
            end: 0,
            delay: Duration(milliseconds: 60 + index * 60),
            duration: AppMotion.standard,
            curve: AppMotion.decelerate,
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 3 — Join the Family
// ─────────────────────────────────────────────────────────────────────────────

class _JoinFamilyPage extends StatelessWidget {
  const _JoinFamilyPage({required this.onBack});

  final VoidCallback onBack;

  static const _benefits = [
    (icon: Icons.menu_book_rounded, text: 'Save Bible progress'),
    (icon: Icons.groups_rounded, text: 'Join community groups'),
    (icon: Icons.wb_sunny_rounded, text: 'Daily devotionals'),
    (icon: Icons.live_tv_rounded, text: 'Watch live services'),
    (icon: Icons.self_improvement_rounded, text: 'Submit prayer requests'),
    (icon: Icons.handshake_rounded, text: 'Connect with leaders'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
            Color(0xFF1E40AF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Top decorative orb
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.07),
              ),
            ),
          ),
          // Bottom orb
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                safeBottom + 80,
              ),
              child: Column(
                children: [
                  // Back arrow
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: onBack,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: AppRadius.brCircle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Gold crown / cross mark
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldDark, AppColors.gold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      color: AppColors.ink,
                      size: 32,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: AppSpacing.xl),

                  // Headline
                  Text(
                    'Become Part of the\nKingdom Heirs Family',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 450.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        delay: 150.ms,
                        duration: 450.ms,
                        curve: AppMotion.decelerate,
                      ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Create an account to unlock everything God has prepared for you here.',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Benefits grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: _benefits.length,
                    itemBuilder: (context, i) {
                      final b = _benefits[i];
                      return _BenefitChip(
                        icon: b.icon,
                        text: b.text,
                        index: i,
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Divider
                  Container(
                    width: 48,
                    height: 1.5,
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Primary CTA — Create Account
                  _GoldButton(
                    label: 'Create Account',
                    icon: Icons.person_add_rounded,
                    onTap: () => context.push(RouteNames.register),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideY(
                        begin: 0.15,
                        end: 0,
                        delay: 700.ms,
                        duration: 400.ms,
                        curve: AppMotion.decelerate,
                      ),

                  const SizedBox(height: AppSpacing.md),

                  // Secondary CTA — Sign In
                  _OutlineButton(
                    label: 'Sign In',
                    onTap: () => context.push(RouteNames.login),
                  ).animate().fadeIn(delay: 820.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Already have an account? Sign in above.',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ).animate().fadeIn(delay: 950.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({
    required this.icon,
    required this.text,
    required this.index,
  });

  final IconData icon;
  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.goldLight, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 350 + index * 50),
          duration: AppMotion.standard,
        )
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          delay: Duration(milliseconds: 350 + index * 50),
          duration: AppMotion.standard,
          curve: Curves.easeOutBack,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Components
// ─────────────────────────────────────────────────────────────────────────────

/// Church logo mark (KH initials in gold serif on navy circle)
class _ChurchLogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        color: Colors.white.withValues(alpha: 0.06),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'KH',
              style: AppTypography.textTheme.displaySmall?.copyWith(
                color: AppColors.goldLight,
                fontWeight: FontWeight.w700,
                height: 1,
                fontSize: 38,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'KINGDOM HEIRS',
              style: AppTypography.scriptureRef.copyWith(
                color: AppColors.goldLight.withValues(alpha: 0.7),
                fontSize: 7,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold pill primary button
class _GoldButton extends StatefulWidget {
  const _GoldButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: AppMotion.instant,
      lowerBound: 0.95,
      value: 1,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onTap();
      },
      onTapCancel: () => _press.forward(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) => Transform.scale(
          scale: _press.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldDark, AppColors.gold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.brFull,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(widget.icon, color: AppColors.ink, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// White-outline secondary button
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.5,
          ),
          borderRadius: AppRadius.brFull,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared page top bar with eyebrow, headline, and back button
class _PageTopBar extends StatelessWidget {
  const _PageTopBar({
    required this.eyebrow,
    required this.title,
    required this.onBack,
  });

  final String eyebrow;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back button row
          GestureDetector(
            onTap: onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 14,
                  color: AppColors.goldDark,
                ),
                const SizedBox(width: 4),
                Text(
                  'Back',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Eyebrow
          Text(
            eyebrow,
            style: AppTypography.scriptureRef.copyWith(
              color: AppColors.goldDark,
              letterSpacing: 2,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            title,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: AppMotion.emphasized)
          .slideY(
            begin: -0.05,
            end: 0,
            duration: AppMotion.emphasized,
            curve: AppMotion.decelerate,
          ),
    );
  }
}

/// Bottom navigation bar for pages 1-2 (Next + Back shortcut)
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.onNext,
    required this.onBack,
    required this.label,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final String label;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        safeBottom + 56, // accounts for dot indicator
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          top: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Skip / Sign In shortcut
          GestureDetector(
            onTap: () => context.push(RouteNames.login),
            child: Text(
              'Sign In',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          // Next button
          GestureDetector(
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldDark, AppColors.gold],
                ),
                borderRadius: AppRadius.brFull,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.ink,
                    size: 16,
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
