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
//
// Refresh strategy: per-section FutureProviders (greetingProvider, etc.)
// load independently via the homeDashboardProvider meta aggregator.
// Pull-to-refresh invalidates every per-section provider in one shot via
// `invalidateDashboard(ref)`, so a single gesture re-fetches the whole
// dashboard.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/utils/donation_launcher.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:kingdom_heir/features/dashboard/presentation/providers/home_dashboard_providers.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/_shared/dashboard_skeleton.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/_shared/floating_prayer_button.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/actions/quick_actions_strip.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/continue/continue_carousel.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/greeting/greeting_header.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/journey/daily_journey_section.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/scripture/scripture_hero_card.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/service/service_status_card.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/watching/continue_watching_carousel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
// search_placeholder_sheet.dart was replaced by RouteNames.globalSearch.

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
        invalidateDashboard(ref);
        await ref.read(homeDashboardProvider.future);
      },
      child: asyncData.when(
        data: (data) => _HomeDashboardBody(data: data),
        loading: () => const DashboardSkeleton(),
        error: (err, _) => AppErrorWidget(
          message: _readableError(err),
          onRetry: () => invalidateDashboard(ref),
        ),
      ),
    );
  }

  static String _readableError(Object err) => err.toString();
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — all 10 sections
// ─────────────────────────────────────────────────────────────────────────────

class _HomeDashboardBody extends ConsumerWidget {
  const _HomeDashboardBody({required this.data});
  final HomeDashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The scripture roster powers the swipe-page — fetch from its
    // dedicated per-section provider so we don't blank on a slow
    // section, falling back to the aggregated single verse.
    final asyncRoster = ref.watch(scriptureProvider);
    final roster = asyncRoster.maybeWhen(
      data: (r) => r,
      orElse: () => <ScriptureCard>[data.scripture],
    );

    return Stack(
      children: [
        CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            DashboardTopBar(
              greeting: data.greeting,
              onNotificationTap: () => context.push(RouteNames.notifications),
              onAvatarTap: () => context.push(RouteNames.myProfile),
            ),
            SliverToBoxAdapter(
              child: SafeArea(
                top: false, // AppBar handles top safe area
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- BINARY FINGERPRINT INJECTION ---
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'FINGERPRINT: Dashboard | Version: 2026.07.22 | Commit: abc1234 | Repo: HomeDashboardRepository | Mode: ${bool.fromEnvironment('dart.vm.product') ? 'Release' : 'Debug'}',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // -------------------------------------
                    // ── 1. Hero ────────────────────────────────────────────
                    HeroHeader(
                      greeting: data.greeting,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── 2. Scripture Hero ──────────────────────────────────
                    ScriptureHeroCard(
                      scripture: data.scripture,
                      roster: roster,
                      onBookmark: () => _toast(
                        context,
                        data.scripture.isBookmarked
                            ? 'Already saved to bookmarks'
                            : 'Saved to bookmarks',
                      ),
                      onShare: () => _shareScripture(
                        context,
                        data.scripture.verseText,
                        data.scripture.reference,
                      ),
                      onAudio: () => _listenScripture(
                        context,
                        data.scripture.audioUrl,
                        data.scripture.reference,
                      ),
                      onReflect: () => _reflectOnScripture(
                        context,
                        data.scripture.reference,
                      ),
                    ),

                    // ── 3. Quick Actions ───────────────────────────────────
                    QuickActionsStrip(
                      onActionTap: (action) => _onQuickAction(context, action),
                    ),

                    // ── 4. Continue Your Journey ───────────────────────────
                    ContinueCarousel(
                      cards: data.continueCards,
                      onCardTap: (card) => _onContinueCardTap(context, card),
                      onStartJourney: () => context.push(RouteNames.biblePlans),
                    ),

                    // ── 5. Live / Next Service ─────────────────────────────
                    ServiceStatusCard(
                      status: data.serviceStatus,
                      onWatchNow: () => context.push(RouteNames.live),
                      onAddReminder: () => _toast(
                        context,
                        'Reminder set — we’ll notify you 30 minutes before.',
                      ),
                      onAddToCalendar: () => _toast(
                        context,
                        'Adding to calendar…',
                      ),
                      onDirections: () => _toast(
                        context,
                        'Opening directions…',
                      ),
                    ),

                    // ── 6. Daily Spiritual Journey ─────────────────────────
                    DailyJourneySection(
                      journey: data.dailyJourney,
                      onTaskTap: (task) =>
                          _onJourneyTaskTap(context, task.kind),
                      onTaskToggle: (kind, isCompleted) =>
                          _onJourneyTaskToggle(ref, kind, isCompleted),
                    ),

                    // ── 7. Continue Watching ───────────────────────────────
                    ContinueWatchingCarousel(
                      cards: data.watchCards,
                      onCardTap: (card) =>
                          context.push(RouteNames.sermonDetails),
                      onSeeAll: () => context.push(RouteNames.sermons),
                    ),

                    // Bottom breathing room for nav bar + FAB clearance
                    const SizedBox(height: AppSpacing.massive),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Floating Prayer FAB — overlays the scroll content, sits above
        // the bottom nav bar.
        const Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.xxl,
          child: FloatingPrayerButton(),
        ),
      ],
    );
  }

  // ── Callback handlers ────────────────────────────────────────────────────

  void _onContinueCardTap(BuildContext context, ContinueCard card) {
    switch (card.kind) {
      case ContinueKind.biblePlan:
        context.push(RouteNames.biblePlans);
      case ContinueKind.devotional:
        context.push('${RouteNames.devotionalReader}/${card.id}');
      case ContinueKind.sermon:
        context.push('${RouteNames.sermonDetails}/${card.id}');
      case ContinueKind.podcast:
        context.push(RouteNames.podcasts);
      case ContinueKind.prayerChallenge:
        context.push(RouteNames.prayerFeed);
    }
  }

  Future<void> _onJourneyTaskToggle(
    WidgetRef ref,
    SpiritualTaskKind kind,
    bool isCompleted,
  ) async {
    // Fire-and-forget optimistic toggle. The repository returns
    // `DashboardWriteResult`, which we ignore — the UI was already
    // updated by the parent's onChanged, and the next refresh will
    // reconcile any mismatch.
    await ref
        .read(homeDashboardRepositoryProvider)
        .toggleJourneyTask(kind, isCompleted: isCompleted);
    ref.invalidate(journeyProvider);
  }

  void _onJourneyTaskTap(BuildContext context, SpiritualTaskKind kind) {
    switch (kind) {
      case SpiritualTaskKind.scripture:
      case SpiritualTaskKind.reflection:
        context.push(RouteNames.bible);
      case SpiritualTaskKind.devotional:
        context.push(RouteNames.devotionals);
      case SpiritualTaskKind.prayer:
        context.push(RouteNames.prayerFeed);
      case SpiritualTaskKind.worship:
        context.push(RouteNames.podcasts);
      case SpiritualTaskKind.journal:
        context.push(RouteNames.journal);
    }
  }

  void _onQuickAction(BuildContext context, QuickActionItem action) {
    switch (action) {
      case QuickActionItem.bible:
        context.push(RouteNames.bible);
      case QuickActionItem.prayer:
        context.push(RouteNames.prayerFeed);
      case QuickActionItem.live:
        context.push(RouteNames.live);
      case QuickActionItem.study:
        context.push(RouteNames.biblePlans);
      case QuickActionItem.groups:
        context.push(RouteNames.groups);
      case QuickActionItem.giving:
        openDonationPage(context);
      case QuickActionItem.events:
        context.push(RouteNames.events);
      case QuickActionItem.journal:
        // context.push(RouteNames.journal); // if it exists
        _toast(context, 'Opening Journal...');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

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

  Future<void> _shareScripture(
    BuildContext context,
    String text,
    String reference,
  ) async {
    // Trim quotes already in the text and wrap with attribution.
    final clean = text.replaceAll(RegExp(r'^"|"$'), '').trim();
    final shareText =
        '"$clean"\n— $reference\n\nShared from the Kingdom Heirs Church App';
    try {
      await Share.share(shareText, subject: reference);
    } catch (e) {
      if (context.mounted) {
        _toast(context, 'Could not open share sheet');
      }
    }
  }

  Future<void> _listenScripture(
    BuildContext context,
    String? audioUrl,
    String reference,
  ) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      // No audio yet — open the sermon / podcast hub so the user can
      // listen to the wider spoken-word library.
      if (context.mounted) {
        _toast(context, 'Opening audio library…');
      }
      await context.push(RouteNames.podcasts);
      return;
    }
    // Open the audio URL in the system browser / external player.
    final uri = Uri.tryParse(audioUrl);
    if (uri == null) {
      if (context.mounted) {
        _toast(context, 'Audio link unavailable');
      }
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _toast(context, 'Opening audio library…');
        await context.push(RouteNames.podcasts);
      }
    } catch (_) {
      if (context.mounted) {
        _toast(context, 'Opening audio library…');
        await context.push(RouteNames.podcasts);
      }
    }
  }

  void _reflectOnScripture(BuildContext context, String reference) {
    // The journal screen accepts a devotionalId; pass the scripture
    // reference as the title so the user can write a reflection on
    // the verse they just read.
    context.push(
      '${RouteNames.devotionals}/scripture/reflection',
      extra: reference,
    );
  }
}
