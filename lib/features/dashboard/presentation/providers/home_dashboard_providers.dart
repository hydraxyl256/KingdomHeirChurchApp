// Kingdom Heir — Home Dashboard Providers
//
// Per-section providers load independently in parallel.
// Aggregate provider coordinates the initial load + pull-to-refresh.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/dashboard/data/home_dashboard_repository.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

// ── Repository DI ────────────────────────────────────────────────────────────

final homeDashboardRepositoryProvider = Provider<HomeDashboardRepository>(
  (ref) => HomeDashboardRepository(),
);

// ── Aggregate provider (used by screen for load/refresh) ─────────────────────

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  return ref.read(homeDashboardRepositoryProvider).fetchAll();
});
