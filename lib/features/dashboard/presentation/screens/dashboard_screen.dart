// Kingdom Heir — Premium Home Dashboard Screen (REDESIGNED)
//
// Daily Spiritual Companion. 10 sections, no Scaffold (shell provides it),
// no blank screens, no overflow, staggered entrance animations.
//
// Section order:
//   1. Greeting Header
//   2. Scripture Hero Card (centerpiece)
//   3. Continue Your Journey (carousel)
//   4. Live / Next Service
//   5. Daily Spiritual Journey (checklist + progress)
//   6. Church Today (events)
//   7. Prayer Corner
//   8. Community Highlights
//   9. Continue Watching (carousel)
//  10. Quick Actions
//      Bottom padding

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:kingdom_heir/features/dashboard/presentation/providers/home_dashboard_providers.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/actions/quick_actions_strip.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/community/community_highlight_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/continue/continue_carousel.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/events/church_today_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/greeting/greeting_header.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/journey/daily_journey_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/prayer/prayer_corner_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/scripture/scripture_hero_card.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/service/service_status_card.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/watching/continue_watching_carousel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root Screen — wraps RefreshIndicator + async state
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(homeDashboardProvider);

    return RefreshIndicator.adaptive(
      color: AppColors.goldDark,
      backgroundColor: Colors.white,
      onRefresh: () async {
        ref.invalidate(homeDashboardProvider);
        await ref.read(homeDashboardProvider.future);
      },
      child: asyncData.when(
        data: (data) => _HomeDashboardBody(data: data),
        loading: () => const _HomeDashboardSkeleton(),
        error: (err, _) => _HomeDashboardError(
          onRetry: () => ref.invalidate(homeDashboardProvider),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — all 10 sections
// ─────────────────────────────────────────────────────────────────────────────

class _HomeDashboardBody extends ConsumerWidget {
  const _HomeDashboardBody({required this.data});
  final HomeDashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── 1. Greeting ────────────────────────────────────────
                GreetingHeader(
                  greeting: data.greeting,
                  onNotificationTap: () =>
                      _toast(context, 'Notifications coming soon'),
                  onSearchTap: () => _toast(context, 'Search coming soon'),
                  onAvatarTap: () => context.push(RouteNames.myProfile),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── 2. Scripture Hero ──────────────────────────────────
                ScriptureHeroCard(
                  scripture: data.scripture,
                  onBookmark: () => _toast(context, 'Saved to bookmarks'),
                  onShare: () => _toast(context, 'Share coming soon'),
                  onAudio: () => _toast(context, 'Audio coming soon'),
                  onReflect: () => _toast(context, 'Reflection journal coming soon'),
                ),

                // ── 3. Continue Your Journey ───────────────────────────
                ContinueCarousel(
                  cards: data.continueCards,
                  onCardTap: (card) => _toast(context, 'Opening ${card.title}'),
                  onStartJourney: () => _toast(context, 'Explore coming soon'),
                ),

                // ── 4. Live / Next Service ─────────────────────────────
                ServiceStatusCard(
                  status: data.serviceStatus,
                  onWatchNow: () => _toast(context, 'Opening live stream'),
                  onAddReminder: () => _toast(context, 'Reminder set!'),
                ),

                // ── 5. Daily Spiritual Journey ─────────────────────────
                DailyJourneySection(
                  journey: data.dailyJourney,
                  onTaskTap: (task) =>
                      _toast(context, 'Opening ${task.displayLabel}'),
                ),

                // ── 6. Church Today ────────────────────────────────────
                ChurchTodaySection(
                  events: data.todayEvents,
                  onJoin: (e) => _toast(context, 'Joining ${e.title}'),
                  onReminder: (e) => _toast(context, 'Reminder set for ${e.title}'),
                  onSeeAll: () => context.push(RouteNames.events),
                ),

                // ── 7. Prayer Corner ───────────────────────────────────
                PrayerCornerSection(
                  corner: data.prayerCorner,
                  onPray: (req) =>
                      _toast(context, 'Praying for ${req.authorName}'),
                  onSubmit: () =>
                      _toast(context, 'Prayer submission coming soon'),
                  onSeeAll: () => context.push(RouteNames.prayerFeed),
                ),

                // ── 8. Community ───────────────────────────────────────
                CommunityHighlightSection(
                  highlight: data.communityHighlight,
                  onGroupsTap: () => context.push(RouteNames.groups),
                ),

                // ── 9. Continue Watching ───────────────────────────────
                ContinueWatchingCarousel(
                  cards: data.watchCards,
                  onCardTap: (card) =>
                      _toast(context, 'Opening ${card.title}'),
                  onSeeAll: () => context.push(RouteNames.sermons),
                ),

                // ── 10. Quick Actions ──────────────────────────────────
                QuickActionsStrip(
                  onActionTap: (action) => _onQuickAction(context, action),
                ),

                // Bottom breathing room for nav bar
                const SizedBox(height: AppSpacing.massive),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onQuickAction(BuildContext context, QuickActionItem action) {
    switch (action) {
      case QuickActionItem.bible:
        context.push(RouteNames.bible);
      case QuickActionItem.prayer:
        context.push(RouteNames.prayerFeed);
      case QuickActionItem.sermons:
        context.push(RouteNames.sermons);
      case QuickActionItem.give:
        context.push(RouteNames.giving);
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          content: Text(
            msg,
            style: const TextStyle(color: AppColors.warmWhite),
          ),
          duration: const Duration(milliseconds: 1600),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton Loading
// ─────────────────────────────────────────────────────────────────────────────

class _HomeDashboardSkeleton extends StatefulWidget {
  const _HomeDashboardSkeleton();

  @override
  State<_HomeDashboardSkeleton> createState() => _HomeDashboardSkeletonState();
}

class _HomeDashboardSkeletonState extends State<_HomeDashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Opacity(
              opacity: _anim.value,
              child: const SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: AppSpacing.lg),
                      // Greeting skeleton
                      Row(
                        children: [
                          _Bone(width: 64, height: 64, radius: 32),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _Bone(width: 80, height: 11),
                                SizedBox(height: 6),
                                _Bone(width: 140, height: 20),
                                SizedBox(height: 6),
                                _Bone(width: 200, height: 11),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),
                      // Scripture card skeleton
                      _Bone(width: double.infinity, height: 220, radius: 20),
                      SizedBox(height: AppSpacing.xl),
                      // Section header
                      _Bone(width: 180, height: 18),
                      SizedBox(height: AppSpacing.md),
                      // Carousel skeleton
                      Row(
                        children: [
                          _Bone(width: 148, height: 160, radius: 14),
                          SizedBox(width: AppSpacing.md),
                          _Bone(width: 148, height: 160, radius: 14),
                          SizedBox(width: AppSpacing.md),
                          _Bone(width: 60, height: 160, radius: 14),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),
                      // Card skeleton
                      _Bone(width: double.infinity, height: 80, radius: 14),
                      SizedBox(height: AppSpacing.xl),
                      // Daily journey skeleton
                      _Bone(width: double.infinity, height: 200, radius: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.dividerLight,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────────────────────────────────────

class _HomeDashboardError extends StatelessWidget {
  const _HomeDashboardError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.huge),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.goldContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.goldDark,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Could not load dashboard',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pull down to refresh or tap below to try again.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldDark, AppColors.gold],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'Try Again',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
