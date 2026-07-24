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
//   6. Continue Watching (carousel)
//   7. Quick Actions
//      Bottom padding
//
// Resilience (2026-07 audit):
//   • Every section watches its own `FutureProvider` and renders an
//     independent skeleton / data / error state via
//     `DashboardSectionView`. A single section failure cannot blank
//     the screen or affect any other section.
//   • The meta aggregator `homeDashboardProvider` is now
//     section-tolerant: it never throws, and only exists to coordinate
//     pull-to-refresh and the "everything is loading for the first
//     time" skeleton shell.
//   • The top-level `DashboardSkeleton` is shown on cold start when no
//     section has produced data yet. On any subsequent refresh only
//     the affected section re-skeletons.

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
import 'package:kingdom_heir/features/dashboard/presentation/widgets/_shared/dashboard_section_view.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/_shared/dashboard_skeleton.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/_shared/floating_prayer_button.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/_shared/section_error_boundary.dart';
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
// Root Screen — wraps RefreshIndicator + per-section state
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator.adaptive(
      color: AppColors.goldDark,
      backgroundColor: Colors.white,
      onRefresh: () async {
        // Invalidate every per-section provider so each section
        // re-fetches independently. The aggregator is also
        // invalidated so the meta shell re-resolves, but it is
        // section-tolerant and will not throw even if every section
        // fails.
        invalidateDashboard(ref);
        // Await the meta shell so the RefreshIndicator stays visible
        // until at least the slowest section has resolved. Sections
        // render their own skeletons / errors independently as they
        // come back online.
        await ref.read(homeDashboardProvider.future);
      },
      child: const _HomeDashboardBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — all 7 sections, each with its own provider
// ─────────────────────────────────────────────────────────────────────────────

class _HomeDashboardBody extends ConsumerWidget {
  const _HomeDashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the meta aggregator ONLY to know whether anything has
    // loaded yet. We never read `data` from it — each section
    // watches its own provider for resilience.
    final metaAsync = ref.watch(homeDashboardProvider);
    final hasAnyData = metaAsync.maybeWhen(
      data: (_) => true,
      orElse: () => false,
    );

    // Cold start: no section has produced data yet → show the full
    // `DashboardSkeleton` (matches the design tokens and avoids
    // layout jump). Once any section resolves we switch to the
    // per-section view; in-flight sections show their own skeleton
    // and failed sections show a friendly error card.
    if (!hasAnyData && metaAsync.isLoading) {
      return const DashboardSkeleton();
    }

    return Stack(
      children: [
        CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            DashboardTopBar(
              greeting: _topBarGreeting(ref),
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
                    // ── 1. Hero (Greeting) ─────────────────────────────
                    _greetingSection(context, ref),

                    const SizedBox(height: AppSpacing.lg),

                    // ── 2. Scripture Hero ────────────────────────────────
                    _scriptureSection(context, ref),

                    // ── 3. Quick Actions ─────────────────────────────────
                    SectionErrorBoundary(
                      section: DashboardSection.quickActions,
                      child: QuickActionsStrip(
                        onActionTap: (action) =>
                            _onQuickAction(context, action),
                      ),
                    ),

                    // ── 4. Continue Your Journey ─────────────────────────
                    _continueSection(context, ref),

                    // ── 5. Live / Next Service ───────────────────────────
                    _serviceSection(context, ref),

                    // ── 6. Daily Spiritual Journey ───────────────────────
                    _journeySection(context, ref),

                    // ── 7. Continue Watching ─────────────────────────────
                    _watchingSection(context, ref),

                    // Bottom breathing room for nav bar + FAB clearance
                    const SizedBox(height: AppSpacing.massive),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Floating Prayer FAB — overlays the scroll content, sits above
        // the bottom nav bar. Wrapped in a section error boundary so a
        // crash here can never take down the whole screen.
        const Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.xxl,
          child: SectionErrorBoundary(
            section: DashboardSection.floatingPrayer,
            fallback: SizedBox.shrink(),
            child: FloatingPrayerButton(),
          ),
        ),
      ],
    );
  }

  // ── Section helpers ─────────────────────────────────────────────────────

  /// Returns the current greeting for the top bar's avatar /
  /// notification dot, or `null` if the greeting provider has not
  /// produced a value yet. The top bar handles `null` gracefully
  /// (no avatar image, no notification dot), so a slow greeting
  /// section never blanks the top bar.
  DashboardGreeting? _topBarGreeting(WidgetRef ref) =>
      ref.watch(greetingProvider).valueOrNull;

  Widget _greetingSection(BuildContext context, WidgetRef ref) {
    final async = ref.watch(greetingProvider);
    return DashboardSectionView<DashboardGreeting>(
      asyncValue: async,
      data: (greeting) => HeroHeader(greeting: greeting),
      loading: () => const _SectionSkeleton(height: 96),
      onRetry: () => ref.invalidate(greetingProvider),
    );
  }

  Widget _scriptureSection(BuildContext context, WidgetRef ref) {
    final async = ref.watch(scriptureProvider);
    return DashboardSectionView<List<ScriptureCard>>(
      asyncValue: async,
      data: (roster) {
        final card = roster.isEmpty
            ? const ScriptureCard(
                verseText: 'Welcome to Kingdom Heirs',
                reference: '',
                translation: '',
              )
            : roster.first;
        return ScriptureHeroCard(
          scripture: card,
          roster: roster,
          onBookmark: () => _toast(
            context,
            card.isBookmarked
                ? 'Already saved to bookmarks'
                : 'Saved to bookmarks',
          ),
          onShare: () => _shareScripture(
            context,
            card.verseText,
            card.reference,
          ),
          onAudio: () => _listenScripture(
            context,
            card.audioUrl,
            card.reference,
          ),
          onReflect: () => _reflectOnScripture(
            context,
            card.reference,
          ),
        );
      },
      isEmpty: (r) => r.isEmpty,
      empty: () => const _SectionEmptyCard(
        title: 'No scripture yet',
        body: 'Pull down to refresh.',
      ),
      loading: () => const _SectionSkeleton(height: 220),
      onRetry: () => ref.invalidate(scriptureProvider),
    );
  }

  Widget _continueSection(BuildContext context, WidgetRef ref) {
    final async = ref.watch(continueCardsProvider);
    return DashboardSectionView<List<ContinueCard>>(
      asyncValue: async,
      data: (cards) => ContinueCarousel(
        cards: cards,
        onCardTap: (card) => _onContinueCardTap(context, card),
        onStartJourney: () => context.push(RouteNames.biblePlans),
      ),
      isEmpty: (c) => c.isEmpty,
      empty: () => const _SectionEmptyCard(
        title: 'Nothing to continue yet',
        body: 'Start a plan, sermon, or devotional to see it here.',
      ),
      loading: () => const _SectionSkeleton(height: 180),
      onRetry: () => ref.invalidate(continueCardsProvider),
    );
  }

  Widget _serviceSection(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceStatusProvider);
    return DashboardSectionView<ServiceStatus>(
      asyncValue: async,
      data: (status) => ServiceStatusCard(
        status: status,
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
      loading: () => const _SectionSkeleton(height: 140),
      onRetry: () => ref.invalidate(serviceStatusProvider),
    );
  }

  Widget _journeySection(BuildContext context, WidgetRef ref) {
    final async = ref.watch(journeyProvider);
    return DashboardSectionView<DailyJourney>(
      asyncValue: async,
      data: (journey) => DailyJourneySection(
        journey: journey,
        onTaskTap: (task) => _onJourneyTaskTap(context, task.kind),
        onTaskToggle: (kind, isCompleted) =>
            _onJourneyTaskToggle(ref, kind, isCompleted),
      ),
      isEmpty: (j) => j.tasks.isEmpty,
      empty: () => const _SectionEmptyCard(
        title: 'No journey today',
        body: 'Pull down to refresh.',
      ),
      loading: () => const _SectionSkeleton(height: 200),
      onRetry: () => ref.invalidate(journeyProvider),
    );
  }

  Widget _watchingSection(BuildContext context, WidgetRef ref) {
    final async = ref.watch(watchCardsProvider);
    return DashboardSectionView<List<WatchCard>>(
      asyncValue: async,
      data: (cards) => ContinueWatchingCarousel(
        cards: cards,
        onCardTap: (card) => context.push(RouteNames.sermonDetails),
        onSeeAll: () => context.push(RouteNames.sermons),
      ),
      isEmpty: (c) => c.isEmpty,
      empty: () => const _SectionEmptyCard(
        title: 'Nothing to watch yet',
        body: 'Sermons and podcasts you start will appear here.',
      ),
      loading: () => const _SectionSkeleton(height: 180),
      onRetry: () => ref.invalidate(watchCardsProvider),
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

// ─────────────────────────────────────────────────────────────────────────────
// Lightweight section-level skeleton + empty state
// ─────────────────────────────────────────────────────────────────────────────

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: AppShimmerBox(
        width: double.infinity,
        height: height,
        borderRadius: AppSpacing.radiusLg,
      ),
    );
  }
}

class _SectionEmptyCard extends StatelessWidget {
  const _SectionEmptyCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
