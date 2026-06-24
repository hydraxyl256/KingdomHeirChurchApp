// Kingdom Heir — More Repository
//
// Centralized data source for the redesigned "More" screen. In production
// each `fetch*` method calls Supabase; here they return curated mock data
// so the UI works end-to-end with no backend.
//
// Methods split per-section so they can load in parallel.

import 'package:kingdom_heir/features/more/domain/more_models.dart';

class MoreRepository {
  Future<MoreProfileHero> fetchProfile({
    required String displayName,
    required String email,
    required String roleLabel,
    required int streakDays,
    String? avatarUrl,
    DateTime? memberSince,
  }) async {
    await _latency(140);
    return MoreProfileHero(
      displayName: displayName,
      email: email,
      roleLabel: roleLabel,
      streakDays: streakDays,
      memberSinceLabel: _memberSince(memberSince ?? DateTime(2024, 3, 18)),
      avatarUrl: avatarUrl,
    );
  }

  Future<FavoriteFeatures> fetchFavorites({List<MoreFeature>? seed}) async {
    await _latency(80);
    return FavoriteFeatures(
      seed ??
          const [
            MoreFeature.bible,
            MoreFeature.devotionals,
            MoreFeature.prayer,
          ],
    );
  }

  Future<List<RecentItem>> fetchRecents() async {
    await _latency(120);
    final now = DateTime.now();
    return [
      RecentItem(
        feature: MoreFeature.bible,
        label: 'Continue John, Chapter 12',
        subtitle: 'Verse 14 · 4 min read left',
        route: '/home/bible',
        usedAt: now.subtract(const Duration(minutes: 22)),
        progress: 0.58,
      ),
      RecentItem(
        feature: MoreFeature.podcasts,
        label: 'Morning Coffee · Ep. 14',
        subtitle: 'Pastor Grace · 18 min left',
        route: '/home/podcasts',
        usedAt: now.subtract(const Duration(hours: 3)),
        progress: 0.62,
      ),
      RecentItem(
        feature: MoreFeature.sermons,
        label: 'Walking in the Spirit',
        subtitle: 'Bishop J. Mensah · 28 min left',
        route: '/home/sermons',
        usedAt: now.subtract(const Duration(hours: 9)),
        progress: 0.46,
      ),
    ];
  }

  Future<MoreGivingSummary> fetchGiving() async {
    await _latency(180);
    return const MoreGivingSummary(
      monthLabel: 'June 2026',
      amountGiven: 2480,
      goalAmount: 4000,
      campaignTitle: 'Kingdom Missions 2026',
      campaignRaised: 68400,
      campaignGoal: 120000,
      recentMonths: [380, 410, 540, 320, 480, 540],
    );
  }

  Future<FamilyEvents> fetchFamilyEvents() async {
    await _latency(140);
    return const FamilyEvents(
      upcomingCount: 7,
      thisWeekCount: 2,
      kidsCheckedInToday: 12,
      nextEventLabel: 'Sunday Worship',
      nextEventWhen: 'Sun · 9:00 AM',
    );
  }

  static String _memberSince(DateTime d) {
    final now = DateTime.now();
    final months = (now.year - d.year) * 12 + (now.month - d.month);
    if (months <= 0) return 'Joined this month';
    if (months < 12) return 'Member · $months mo';
    final years = months ~/ 12;
    final rem = months % 12;
    if (rem == 0) return 'Member · $years yr';
    return 'Member · $years yr $rem mo';
  }

  Future<void> _latency(int ms) =>
      Future<void>.delayed(Duration(milliseconds: ms));
}
