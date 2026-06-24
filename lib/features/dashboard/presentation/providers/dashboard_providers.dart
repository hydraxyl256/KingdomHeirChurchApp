// Kingdom Heir — Dashboard Providers
//
// Each section of the dashboard has its own FutureProvider so they load in
// parallel and a slow/failing section does not block the rest. The top-level
// [dashboardDataProvider] still exists (for pull-to-refresh), but resolves
// by fanning out to the per-section providers.
//
// To trigger a refresh, call:
//   ref.invalidate(dashboardDataProvider);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/features/dashboard/data/dashboard_repository.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository — singleton DI handle.
// ─────────────────────────────────────────────────────────────────────────────

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) => DashboardRepository());

// ─────────────────────────────────────────────────────────────────────────────
// Aggregate provider — used by the dashboard screen to coordinate load / error
// states. Returns an AsyncValue<DashboardData>. The screen renders the
// skeleton when ANY section is loading for the first time, and falls back to
// per-section error widgets on failure (rather than nuking the whole screen).
// ─────────────────────────────────────────────────────────────────────────────

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final results = await Future.wait<dynamic>([
    repo.fetchHero(),
    repo.fetchDailyFocus(),
    repo.fetchContinue(),
    repo.fetchLiveAndUpcoming(),
    repo.fetchImpact(),
    repo.fetchGiving(),
    repo.fetchCommunity(),
    repo.fetchEvents(),
    repo.fetchAnnouncements(),
    repo.fetchInspirations(),
  ]);

  return DashboardData(
    hero: results[0] as HeroGreeting,
    dailyFocus: results[1] as DailyFocus,
    continueItems: results[2] as List<ContinueItem>,
    liveService:
        (results[3] as ({LiveService? live, UpcomingService? upcoming})).live,
    upcomingService:
        (results[3] as ({LiveService? live, UpcomingService? upcoming}))
            .upcoming,
    impact: results[4] as List<ImpactStat>,
    giving: results[5] as GivingSummary,
    community: results[6] as List<CommunityMoment>,
    events: results[7] as List<UpcomingEvent>,
    announcements: results[8] as List<DashboardAnnouncement>,
    inspirations: results[9] as List<InspirationQuote>,
  );
});
