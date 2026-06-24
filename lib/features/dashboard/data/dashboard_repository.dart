// Kingdom Heir — Dashboard Repository
//
// Single source of truth for the dashboard's network calls. In production
// each `fetch*` method calls Supabase; here they return curated mock data
// so the UI works end-to-end with no backend.
//
// Methods are split per-section so Riverpod providers can load in parallel
// and one slow/failing section does not block the rest of the dashboard.

import 'dart:math' as math;

import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';

class DashboardRepository {
  DashboardRepository({math.Random? random}) : _rng = random ?? math.Random();

  final math.Random _rng;

  Future<HeroGreeting> fetchHero() async {
    await _latency(120);
    return const HeroGreeting(
      firstName: 'Eron',
      streakDays: 17,
      seasonLabel: 'Walking in the Spirit',
      moment: GreetingMoment.morning,
    );
  }

  Future<DailyFocus> fetchDailyFocus() async {
    await _latency(180);
    return const DailyFocus(
      verseText: 'I can do all things through Christ who strengthens me.',
      verseReference: 'Philippians 4:13',
      devotionalTitle: 'Standing Firm in the Storm',
      devotionalSubtitle: 'A 7-day devotional on resilient faith',
      prayerFocus: 'Pray for peace in your home today.',
      continueLabel: 'Continue devotional',
    );
  }

  Future<List<ContinueItem>> fetchContinue() async {
    await _latency(160);
    return const [
      ContinueItem(
        id: 'sermon-1',
        kind: ContinueKind.sermon,
        title: 'Walking in the Spirit',
        subtitle: 'Bishop J. Mensah · 28 min left',
        progress: 0.46,
      ),
      ContinueItem(
        id: 'plan-1',
        kind: ContinueKind.biblePlan,
        title: 'Gospel of John in 21 Days',
        subtitle: 'Day 12 of 21',
        progress: 0.57,
      ),
      ContinueItem(
        id: 'devotional-1',
        kind: ContinueKind.devotional,
        title: 'Standing Firm in the Storm',
        subtitle: 'Day 3 of 7',
        progress: 0.42,
      ),
      ContinueItem(
        id: 'podcast-1',
        kind: ContinueKind.podcast,
        title: 'Morning Coffee with Pastor Grace',
        subtitle: 'Episode 14 · 18 min left',
        progress: 0.62,
      ),
    ];
  }

  Future<({LiveService? live, UpcomingService? upcoming})>
      fetchLiveAndUpcoming() async {
    await _latency(220);
    final now = DateTime.now();
    return (
      live: LiveService(
        title: 'Sunday Worship — Week 24',
        hostLabel: 'with Bishop J. Mensah',
        startsAt: now.subtract(const Duration(minutes: 12)),
        viewerCount: 1248 + _rng.nextInt(80),
        heroImageUrl: '',
      ),
      upcoming: UpcomingService(
        title: 'Midweek Bible Study',
        startsAt: now.add(const Duration(hours: 26, minutes: 30)),
        locationLabel: 'Main Sanctuary · In-person & Online',
      ),
    );
  }

  Future<List<ImpactStat>> fetchImpact() async {
    await _latency(180);
    return const [
      ImpactStat(
        label: 'Souls impacted',
        value: 12482,
        iconKey: 'favorite',
        deltaLabel: '+312 this week',
      ),
      ImpactStat(
        label: 'Nations reached',
        value: 38,
        iconKey: 'public',
        deltaLabel: '+2 this quarter',
      ),
      ImpactStat(
        label: 'Active missions',
        value: 24,
        iconKey: 'flight_takeoff',
        deltaLabel: '5 launching soon',
      ),
      ImpactStat(
        label: 'Prayers answered',
        value: 8741,
        iconKey: 'auto_awesome',
        deltaLabel: '+128 this month',
      ),
    ];
  }

  Future<GivingSummary> fetchGiving() async {
    await _latency(200);
    return const GivingSummary(
      monthLabel: 'June 2026',
      amountGiven: 2480,
      goalAmount: 4000,
      history: [180, 320, 410, 540],
      presets: [10, 25, 50, 100],
      campaignTitle: 'Kingdom Missions 2026',
      campaignRaised: 68400,
      campaignGoal: 120000,
    );
  }

  Future<List<CommunityMoment>> fetchCommunity() async {
    await _latency(220);
    final now = DateTime.now();
    return [
      CommunityMoment(
        id: 'c-1',
        kind: CommunityKind.testimony,
        title: 'Healed and restored',
        body: 'After months of chronic pain, prayer and the laying on of hands '
            'brought complete healing. I give God all the glory.',
        authorName: 'Sarah Mensah',
        publishedAt: now.subtract(const Duration(hours: 3)),
        reactionCount: 142,
      ),
      CommunityMoment(
        id: 'c-2',
        kind: CommunityKind.prayerRequest,
        title: 'Wisdom for a career decision',
        body: 'Please stand with me as I discern whether to relocate for a new '
            "role. I want God's will above my own.",
        authorName: 'Daniel O.',
        publishedAt: now.subtract(const Duration(hours: 8)),
        reactionCount: 47,
      ),
      CommunityMoment(
        id: 'c-3',
        kind: CommunityKind.communityWin,
        title: '200 backpacks for the community!',
        body: 'Our youth ministry exceeded their goal — 200 backpacks stuffed '
            'with school supplies will bless families this September.',
        authorName: 'Youth Ministry',
        publishedAt: now.subtract(const Duration(hours: 14)),
        reactionCount: 318,
      ),
    ];
  }

  Future<List<UpcomingEvent>> fetchEvents() async {
    await _latency(160);
    final now = DateTime.now();
    return [
      UpcomingEvent(
        id: 'e-1',
        title: 'Sunday Worship',
        startsAt: now.add(const Duration(days: 3, hours: 8)),
        locationLabel: 'Main Sanctuary',
        iconKey: 'church',
        accentIndex: 0,
      ),
      UpcomingEvent(
        id: 'e-2',
        title: 'Young Adults Night',
        startsAt: now.add(const Duration(days: 5, hours: 10)),
        locationLabel: 'The Loft',
        iconKey: 'groups',
        accentIndex: 1,
      ),
      UpcomingEvent(
        id: 'e-3',
        title: 'Community Outreach',
        startsAt: now.add(const Duration(days: 6, hours: 2)),
        locationLabel: 'Downtown Square',
        iconKey: 'volunteer_activism',
        accentIndex: 2,
      ),
      UpcomingEvent(
        id: 'e-4',
        title: 'Marriage Retreat',
        startsAt: now.add(const Duration(days: 14)),
        locationLabel: 'Lakeside Camp',
        iconKey: 'favorite',
        accentIndex: 3,
      ),
    ];
  }

  Future<List<DashboardAnnouncement>> fetchAnnouncements() async {
    await _latency(140);
    return const [
      DashboardAnnouncement(
        id: 'a-1',
        title: 'Kingdom Missions Conference',
        body: 'Join us June 28–30 for our annual missions conference. '
            'Registration is open — early bird pricing ends Friday.',
        isPinned: true,
      ),
      DashboardAnnouncement(
        id: 'a-2',
        title: 'Youth Camp 2026',
        body: 'Spaces filling fast! Register your teen for Youth Camp 2026 — '
            'a week of worship, teaching, and adventure.',
      ),
      DashboardAnnouncement(
        id: 'a-3',
        title: 'New small groups launching',
        body: 'Twelve new small groups will launch across the city this fall. '
            'Sign up to find your fit.',
      ),
    ];
  }

  Future<List<InspirationQuote>> fetchInspirations() async {
    await _latency(100);
    return const [
      InspirationQuote(
        text:
            'Faith is the substance of things hoped for, the evidence of things not seen.',
        author: 'Hebrews 11:1',
      ),
      InspirationQuote(
        text: 'We walk by faith, not by sight.',
        author: '2 Corinthians 5:7',
      ),
      InspirationQuote(
        text: 'The Lord is my shepherd; I shall not want.',
        author: 'Psalm 23:1',
      ),
    ];
  }

  Future<void> _latency(int ms) =>
      Future<void>.delayed(Duration(milliseconds: ms));
}
