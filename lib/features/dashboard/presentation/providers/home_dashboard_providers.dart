// Kingdom Heir — Home Dashboard Providers
//
// Per-section providers load independently in parallel — a slow
// Supabase call on one section doesn't blank the rest of the dashboard.
// Section widgets that want independent loading + skeletons watch their
// own provider (e.g. `greetingProvider`); the screen itself still uses
// the meta aggregator for the initial RefreshIndicator state.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/dashboard/data/home_dashboard_repository.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

// ── Repository DI ────────────────────────────────────────────────────────────

final homeDashboardRepositoryProvider = Provider<HomeDashboardRepository>(
  (ref) => HomeDashboardRepository(),
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

/// Aggregate provider — used by the screen for its `.when(...)` shell.
/// Each section is awaited in parallel via the underlying providers.
final homeDashboardProvider = FutureProvider<HomeDashboardData>(
  (ref) async {
    final results = await Future.wait(<Future<dynamic>>[
      ref.watch(greetingProvider.future),
      ref.watch(scriptureProvider.future),
      ref.watch(continueCardsProvider.future),
      ref.watch(serviceStatusProvider.future),
      ref.watch(journeyProvider.future),
      ref.watch(todayEventsProvider.future),
      ref.watch(prayerCornerProvider.future),
      ref.watch(communityHighlightProvider.future),
      ref.watch(watchCardsProvider.future),
    ]);
    return HomeDashboardData(
      greeting: results[0] as DashboardGreeting,
      scripture: (results[1] as List<ScriptureCard>).first,
      continueCards: results[2] as List<ContinueCard>,
      serviceStatus: results[3] as ServiceStatus,
      dailyJourney: results[4] as DailyJourney,
      todayEvents: results[5] as List<TodayEvent>,
      prayerCorner: results[6] as PrayerCorner,
      communityHighlight: results[7] as CommunityHighlight,
      watchCards: results[8] as List<WatchCard>,
    );
  },
);

/// Invalidate every per-section provider — used by the pull-to-refresh
/// affordance.
void invalidateDashboard(WidgetRef ref) {
  ref.invalidate(greetingProvider);
  ref.invalidate(scriptureProvider);
  ref.invalidate(continueCardsProvider);
  ref.invalidate(serviceStatusProvider);
  ref.invalidate(journeyProvider);
  ref.invalidate(todayEventsProvider);
  ref.invalidate(prayerCornerProvider);
  ref.invalidate(communityHighlightProvider);
  ref.invalidate(watchCardsProvider);
}