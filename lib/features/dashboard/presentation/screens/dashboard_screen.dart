// Kingdom Heir — Dashboard Screen (REWRITTEN)
//
// The single home screen that composes all 11 sections. The widget tree is:
//
//   SliverPadding
//     SliverToBoxAdapter → PersonalizedHero
//     SliverToBoxAdapter → TodaysFocusCard
//     SliverToBoxAdapter → ContinueJourneySection
//     SliverToBoxAdapter → QuickActionsGrid
//     SliverToBoxAdapter → LiveAndUpcomingSection
//     SliverToBoxAdapter → KingdomImpactSection
//     SliverToBoxAdapter → FinancialStewardshipSection
//     SliverToBoxAdapter → CommunityMomentsSection
//     SliverToBoxAdapter → UpcomingEventsSection
//     SliverToBoxAdapter → AnnouncementsSection
//     SliverToBoxAdapter → BottomInspiration
//
// Why slivers (not nested ListViews):
//   • A single scroll controller owns the entire scroll position.
//   • No nested ListView means no scroll-physics conflicts and no
//     viewport-size miscalculations.
//   • SliverToBoxAdapter gives each section its own box that the framework
//     measures independently — the section's LayoutBuilder reads the actual
//     available width and adapts column counts accordingly.
//
// Loading / empty / error states:
//   • When the dashboardDataProvider is loading for the first time, the
//     screen renders the layout-matched shimmer skeleton.
//   • If the aggregate provider throws, the screen shows a beautiful retry
//     widget instead of a red error.
//   • Individual sections (impact, events, community, announcements) fall
//     back to their own empty state if the list is empty.
//
// Performance:
//   • Each section is wrapped in a RepaintBoundary where useful (hero, live).
//   • No fixed dimensions anywhere in this file or its children.
//   • Sections are built lazily — the framework only paints what is on screen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';
import 'package:kingdom_heir/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/announcements/announcements_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/community/community_moments_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/continue_journey/continue_journey_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/events/upcoming_events_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/focus/todays_focus_card.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/giving/financial_stewardship_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/hero/personalized_hero.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/impact/kingdom_impact_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/inspiration/bottom_inspiration.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/live/live_and_upcoming_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/quick_actions/quick_actions_grid.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/states/dashboard_error_state.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/states/dashboard_skeleton.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator.adaptive(
          color: AppColors.goldDark,
          backgroundColor: Theme.of(context).colorScheme.surface,
          onRefresh: () async {
            ref.invalidate(dashboardDataProvider);
            // Wait for the fresh value so the indicator stays until data lands.
            await ref.read(dashboardDataProvider.future);
          },
          child: asyncData.when(
            data: (data) => _DashboardBody(data: data),
            loading: () => const _DashboardLoading(),
            error: (err, st) => _DashboardError(error: err),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — composed slivers
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insets = Insets.of(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // Top breathing room so the hero gradient meets the screen edge
        SliverPadding(
          padding: EdgeInsets.only(top: insets.xs),
          sliver: SliverToBoxAdapter(
            child: RepaintBoundary(
              child: PersonalizedHero(data: data.hero),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: TodaysFocusCard(
            data: data.dailyFocus,
            onContinue: () => _showComingSoon(context, 'Daily Focus'),
          )
              .animate()
              .fadeIn(
                duration: AppMotion.emphasized,
                delay: const Duration(milliseconds: 80),
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
        ),
        SliverToBoxAdapter(
          child: ContinueJourneySection(
            items: data.continueItems,
            onSeeAll: () => _showComingSoon(context, 'Continue Journey'),
            onItemTap: (item) => _showComingSoon(context, item.kindLabel),
          )
              .animate()
              .fadeIn(
                duration: AppMotion.emphasized,
                delay: const Duration(milliseconds: 160),
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
        ),
        SliverToBoxAdapter(
          child: QuickActionsGrid(
            actions: QuickAction.values.toList(),
            onActionTap: (a) => _showComingSoon(context, a.label),
          )
              .animate()
              .fadeIn(
                duration: AppMotion.emphasized,
                delay: const Duration(milliseconds: 240),
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
        ),
        SliverToBoxAdapter(
          child: LiveAndUpcomingSection(
            live: data.liveService,
            upcoming: data.upcomingService,
            onWatchLive: () => _showComingSoon(context, 'Live Service'),
            onRsvp: () => _showComingSoon(context, 'RSVP'),
          )
              .animate()
              .fadeIn(
                duration: AppMotion.emphasized,
                delay: const Duration(milliseconds: 320),
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
        ),
        SliverToBoxAdapter(
          child: KingdomImpactSection(
            stats: data.impact,
            onSeeAll: () => _showComingSoon(context, 'Kingdom Impact'),
          )
              .animate()
              .fadeIn(
                duration: AppMotion.emphasized,
                delay: const Duration(milliseconds: 400),
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
        ),
        SliverToBoxAdapter(
          child: FinancialStewardshipSection(
            summary: data.giving,
            onSeeAll: () => _showComingSoon(context, 'Giving History'),
            onGive: () => _showComingSoon(context, 'Give'),
            onPresetTap: (amount) => _showComingSoon(context, 'Give \$$amount'),
          )
              .animate()
              .fadeIn(
                duration: AppMotion.emphasized,
                delay: const Duration(milliseconds: 480),
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
        ),
        SliverToBoxAdapter(
          child: CommunityMomentsSection(
            moments: data.community,
            onSeeAll: () => _showComingSoon(context, 'Community'),
            onMomentTap: (m) => _showComingSoon(context, m.kindLabel),
          )
              .animate()
              .fadeIn(
                duration: AppMotion.emphasized,
                delay: const Duration(milliseconds: 560),
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
        ),
        SliverToBoxAdapter(
          child: UpcomingEventsSection(
            events: data.events,
            onSeeAll: () => _showComingSoon(context, 'Events'),
            onEventTap: (e) => _showComingSoon(context, e.title),
          )
              .animate()
              .fadeIn(
                duration: AppMotion.emphasized,
                delay: const Duration(milliseconds: 640),
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
        ),
        SliverToBoxAdapter(
          child: AnnouncementsSection(
            announcements: data.announcements,
            onSeeAll: () => _showComingSoon(context, 'Announcements'),
            onAnnouncementTap: (a) => _showComingSoon(context, a.title),
          )
              .animate()
              .fadeIn(
                duration: AppMotion.emphasized,
                delay: const Duration(milliseconds: 720),
                curve: AppMotion.decelerate,
              )
              .slideY(begin: 0.05, end: 0, duration: AppMotion.emphasized),
        ),
        SliverToBoxAdapter(
          child: BottomInspiration(quotes: data.inspirations),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          content: Text(
            '$label · coming soon',
            style: const TextStyle(color: AppColors.warmWhite),
          ),
          duration: const Duration(milliseconds: 1600),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: insets.sm),
      children: const [
        DashboardSkeleton(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardError extends ConsumerWidget {
  const _DashboardError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insets = Insets.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: insets.lg,
        vertical: insets.huge,
      ),
      children: [
        DashboardErrorState(
          onRetry: () => ref.invalidate(dashboardDataProvider),
        ),
      ],
    );
  }
}
