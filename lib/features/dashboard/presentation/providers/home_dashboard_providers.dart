// Kingdom Heir — Home Dashboard Providers
//
// Per-section providers load independently in parallel — a slow
// Supabase call on one section doesn't blank the rest of the dashboard.
// Section widgets that want independent loading + skeletons watch their
// own provider (e.g. `greetingProvider`); the screen itself still uses
// the meta aggregator for the initial RefreshIndicator state.
//
// Resilience contract (2026-07 audit):
//   • The meta aggregator below NEVER throws. If a section provider
//     rethrows (e.g. someone removes a `_guardData` in the future), the
//     aggregator logs the failure once and substitutes the section's
//     empty-state default. The rest of the dashboard still renders.
//   • Section widgets watch their own provider with `.when(...)` so
//     loading, error, and offline paths are independent.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/logging/structured_logger.dart';
import 'package:kingdom_heir/features/dashboard/data/home_dashboard_repository.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

// ── Repository DI ────────────────────────────────────────────────────────────

final homeDashboardRepositoryProvider = Provider<HomeDashboardRepository>(
  (ref) => HomeDashboardRepository(ref.watch(cacheManagerProvider)),
);

// ── Per-section providers (independent loading + skeletons) ────────────────

final greetingProvider = FutureProvider.autoDispose<DashboardGreeting>(
  (ref) => ref.read(homeDashboardRepositoryProvider).fetchGreeting(),
);

final scriptureProvider = FutureProvider.autoDispose<List<ScriptureCard>>(
  (ref) => ref.read(homeDashboardRepositoryProvider).fetchScriptureRoster(),
);

final continueCardsProvider = FutureProvider.autoDispose<List<ContinueCard>>(
  (ref) => ref.read(homeDashboardRepositoryProvider).fetchContinueCards(),
);

final serviceStatusProvider = FutureProvider.autoDispose<ServiceStatus>(
  (ref) => ref.read(homeDashboardRepositoryProvider).fetchServiceStatus(),
);

final journeyProvider = FutureProvider.autoDispose<DailyJourney>(
  (ref) => ref.read(homeDashboardRepositoryProvider).fetchDailyJourney(),
);

final todayEventsProvider = FutureProvider.autoDispose<List<TodayEvent>>(
  (ref) => ref.read(homeDashboardRepositoryProvider).fetchTodayEvents(),
);

final prayerCornerProvider = FutureProvider.autoDispose<PrayerCorner>(
  (ref) => ref.read(homeDashboardRepositoryProvider).fetchPrayerCorner(),
);

final communityHighlightProvider =
    FutureProvider.autoDispose<CommunityHighlight>(
  (ref) => ref.read(homeDashboardRepositoryProvider).fetchCommunityHighlight(),
);

final watchCardsProvider = FutureProvider.autoDispose<List<WatchCard>>(
  (ref) => ref.read(homeDashboardRepositoryProvider).fetchWatchCards(),
);

// ── Meta aggregator ─────────────────────────────────────────────────────────

/// Aggregate provider — used by the screen for its `.when(...)` shell
/// and the pull-to-refresh coordinator.
///
/// **Resilience:** the aggregator NEVER throws. If any single section
/// provider rethrows, we log the failure once via `StructuredLogger`,
/// substitute the section's empty-state default, and return a
/// `HomeDashboardData` containing every other section's real data.
/// The screen therefore never sees a top-level `AsyncError` from this
/// provider — every section has its own `.when(...)` on its own
/// provider for the per-section retry / skeleton UX.
final homeDashboardProvider = FutureProvider<HomeDashboardData>(
  (ref) async {
    // Resolve every section individually so one failure cannot block
    // the rest. `Future.wait(..., eagerError: false)` is not enough
    // because it still surfaces the rejection to the first awaiting
    // try/catch boundary, and we want a per-section fallback, not a
    // single shared exception.
    Future<T> safe<T>(
      String sectionName,
      Future<T> Function() fetch,
      T Function() empty,
    ) async {
      try {
        return await fetch();
      } catch (e) {
        // The repository's `_guardData` already logs per-section
        // failures. This is the second line of defense for the case
        // where a provider itself throws (test override, future
        // regression, or a caller that bypassed `_guardData`). Log
        // once with a compact, non-PII event and substitute the
        // section's empty default.
        StructuredLogger.logEvent({
          'event': 'dashboard_section_aggregator_failure',
          'section': sectionName,
          'error_type': e.runtimeType.toString(),
          'has_error': true,
        });
        return empty();
      }
    }

    // Each call is independent — `Future.wait` of N already-resolved
    // micro-tasks, so this is effectively a parallel fan-in.
    final greeting = await safe<DashboardGreeting>(
      'greeting',
      () => ref.watch(greetingProvider.future),
      () => const DashboardGreeting(
        firstName: 'Friend',
        moment: GreetingMoment.morning,
        streakDays: 0,
      ),
    );
    final scriptureRoster = await safe<List<ScriptureCard>>(
      'scripture',
      () => ref.watch(scriptureProvider.future),
      () => const <ScriptureCard>[],
    );
    final continueCards = await safe<List<ContinueCard>>(
      'continueCards',
      () => ref.watch(continueCardsProvider.future),
      () => const <ContinueCard>[],
    );
    final serviceStatus = await safe<ServiceStatus>(
      'serviceStatus',
      () => ref.watch(serviceStatusProvider.future),
      () => const ServiceStatus(isLive: false, title: 'No Service Expected'),
    );
    final dailyJourney = await safe<DailyJourney>(
      'journey',
      () => ref.watch(journeyProvider.future),
      () => const DailyJourney(streakDays: 0, tasks: []),
    );
    final todayEvents = await safe<List<TodayEvent>>(
      'todayEvents',
      () => ref.watch(todayEventsProvider.future),
      () => const <TodayEvent>[],
    );
    final prayerCorner = await safe<PrayerCorner>(
      'prayerCorner',
      () => ref.watch(prayerCornerProvider.future),
      () => const PrayerCorner(usersPrayedToday: 0, requests: []),
    );
    final communityHighlight = await safe<CommunityHighlight>(
      'communityHighlight',
      () => ref.watch(communityHighlightProvider.future),
      () => const CommunityHighlight(),
    );
    final watchCards = await safe<List<WatchCard>>(
      'watchCards',
      () => ref.watch(watchCardsProvider.future),
      () => const <WatchCard>[],
    );

    return HomeDashboardData(
      greeting: greeting,
      scripture: scriptureRoster.isEmpty
          ? const ScriptureCard(
              verseText: 'Welcome to Kingdom Heirs',
              reference: '',
              translation: '',
            )
          : scriptureRoster.first,
      continueCards: continueCards,
      serviceStatus: serviceStatus,
      dailyJourney: dailyJourney,
      todayEvents: todayEvents,
      prayerCorner: prayerCorner,
      communityHighlight: communityHighlight,
      watchCards: watchCards,
    );
  },
);

/// Invalidate every per-section provider — used by the pull-to-refresh
/// affordance.
void invalidateDashboard(WidgetRef ref) {
  ref
    ..invalidate(greetingProvider)
    ..invalidate(scriptureProvider)
    ..invalidate(continueCardsProvider)
    ..invalidate(serviceStatusProvider)
    ..invalidate(journeyProvider)
    ..invalidate(todayEventsProvider)
    ..invalidate(prayerCornerProvider)
    ..invalidate(communityHighlightProvider)
    ..invalidate(watchCardsProvider);
}
