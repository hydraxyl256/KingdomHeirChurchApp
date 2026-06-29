// Kingdom Heir — Home Dashboard Repository
//
// Mock data that powers the redesigned dashboard. Each fetch* method is
// independent so providers can load in parallel. Ready to swap to live
// Supabase calls without changing the UI layer.

import 'dart:math' as math;

import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class HomeDashboardRepository {
  HomeDashboardRepository({math.Random? random})
      : _rng = random ?? math.Random();

  final math.Random _rng;

  // ── Greeting ────────────────────────────────────────────────────────────────

  Future<DashboardGreeting> fetchGreeting() async {
    await _latency(80);
    final now = DateTime.now();
    return DashboardGreeting(
      firstName: 'Eron',
      moment: resolveGreetingMoment(now),
      streakDays: 17,
      unreadNotifications: 3,
    );
  }

  // ── Scripture ────────────────────────────────────────────────────────────────

  Future<ScriptureCard> fetchScripture() async {
    await _latency(150);
    const verses = [
      (
        text:
            'I can do all things through Christ who strengthens me.',
        ref: 'Philippians 4:13',
        translation: 'NKJV',
      ),
      (
        text:
            'Trust in the Lord with all your heart, and do not lean on your own understanding.',
        ref: 'Proverbs 3:5',
        translation: 'ESV',
      ),
      (
        text:
            'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
        ref: 'John 3:16',
        translation: 'NIV',
      ),
      (
        text:
            'The Lord is my shepherd; I shall not want.',
        ref: 'Psalm 23:1',
        translation: 'KJV',
      ),
      (
        text:
            'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
        ref: 'Joshua 1:9',
        translation: 'NIV',
      ),
    ];
    // Rotate daily by day-of-year
    final idx = DateTime.now().dayOfYear % verses.length;
    final v = verses[idx];
    return ScriptureCard(
      verseText: v.text,
      reference: v.ref,
      translation: v.translation,
    );
  }

  // ── Continue Your Journey ────────────────────────────────────────────────────

  Future<List<ContinueCard>> fetchContinueCards() async {
    await _latency(130);
    return const [
      ContinueCard(
        id: 'sermon-1',
        kind: ContinueKind.sermon,
        title: 'Walking in the Spirit',
        subtitle: 'Bishop J. Mensah',
        progress: 0.46,
        durationLabel: '28 min left',
      ),
      ContinueCard(
        id: 'plan-1',
        kind: ContinueKind.biblePlan,
        title: 'Gospel of John in 21 Days',
        subtitle: 'Day 12 of 21',
        progress: 0.57,
      ),
      ContinueCard(
        id: 'devotional-1',
        kind: ContinueKind.devotional,
        title: 'Standing Firm in the Storm',
        subtitle: 'Day 3 of 7',
        progress: 0.42,
      ),
      ContinueCard(
        id: 'podcast-1',
        kind: ContinueKind.podcast,
        title: 'Morning Coffee with Pastor Grace',
        subtitle: 'Episode 14',
        progress: 0.62,
        durationLabel: '18 min left',
      ),
    ];
  }

  // ── Live / Next Service ──────────────────────────────────────────────────────

  Future<ServiceStatus> fetchServiceStatus() async {
    await _latency(200);
    final now = DateTime.now();
    // Mock: Sunday = live, otherwise next service
    final isSunday = now.weekday == DateTime.sunday;
    if (isSunday) {
      return ServiceStatus(
        isLive: true,
        title: 'Sunday Worship — Week ${_weekOfYear(now)}',
        hostLabel: 'with Bishop J. Mensah',
        viewerCount: 1248 + _rng.nextInt(80),
        streamUrl: '',
      );
    }
    // Next Sunday
    final daysUntilSunday = DateTime.sunday - now.weekday;
    final nextSunday = now.add(Duration(days: daysUntilSunday));
    final nextService = DateTime(
      nextSunday.year,
      nextSunday.month,
      nextSunday.day,
      9,
    );
    return ServiceStatus(
      isLive: false,
      title: 'Sunday Worship Service',
      hostLabel: 'Bishop J. Mensah',
      startsAt: nextService,
      locationLabel: 'Main Sanctuary · In-person & Online',
    );
  }

  // ── Daily Journey ────────────────────────────────────────────────────────────

  Future<DailyJourney> fetchDailyJourney() async {
    await _latency(100);
    return const DailyJourney(
      streakDays: 17,
      tasks: [
        SpiritualTask(kind: SpiritualTaskKind.scripture, isCompleted: true),
        SpiritualTask(kind: SpiritualTaskKind.devotional, isCompleted: true),
        SpiritualTask(kind: SpiritualTaskKind.prayer, isCompleted: false),
        SpiritualTask(kind: SpiritualTaskKind.reflection, isCompleted: false),
        SpiritualTask(kind: SpiritualTaskKind.worship, isCompleted: false),
      ],
    );
  }

  // ── Church Today ─────────────────────────────────────────────────────────────

  Future<List<TodayEvent>> fetchTodayEvents() async {
    await _latency(120);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return [
      TodayEvent(
        id: 'e-1',
        title: 'Prayer & Intercession',
        startsAt: today.add(const Duration(hours: 6)),
        locationLabel: 'Prayer Room — Ground Floor',
      ),
      TodayEvent(
        id: 'e-2',
        title: 'Youth Bible Study',
        startsAt: today.add(const Duration(hours: 18, minutes: 30)),
        locationLabel: 'Youth Hall',
      ),
      TodayEvent(
        id: 'e-3',
        title: 'Midweek Service',
        startsAt: tomorrow.add(const Duration(hours: 19)),
        locationLabel: 'Main Sanctuary · Online',
        isOnline: true,
        isToday: false,
      ),
    ];
  }

  // ── Prayer Corner ────────────────────────────────────────────────────────────

  Future<PrayerCorner> fetchPrayerCorner() async {
    await _latency(140);
    return const PrayerCorner(
      usersPrayedToday: 84,
      answeredPrayerHighlight:
          '"After months of chronic pain, God brought complete healing." — Sarah M.',
      requests: [
        PrayerRequest(
          id: 'p-1',
          authorName: 'Daniel O.',
          preview: 'Wisdom for a major career decision.',
          prayerCount: 47,
        ),
        PrayerRequest(
          id: 'p-2',
          authorName: 'Grace A.',
          preview: 'Healing and restoration for my family.',
          prayerCount: 63,
        ),
        PrayerRequest(
          id: 'p-3',
          authorName: 'Michael K.',
          preview: 'Financial breakthrough and open doors.',
          prayerCount: 29,
        ),
      ],
    );
  }

  // ── Community Highlight ──────────────────────────────────────────────────────

  Future<CommunityHighlight> fetchCommunityHighlight() async {
    await _latency(90);
    return const CommunityHighlight(
      unreadGroupMessages: 5,
      birthdayName: 'Sarah Mensah',
      leaderAnnouncement: 'Leaders meeting this Saturday at 8 AM.',
    );
  }

  // ── Continue Watching ────────────────────────────────────────────────────────

  Future<List<WatchCard>> fetchWatchCards() async {
    await _latency(160);
    return const [
      WatchCard(
        id: 'w-1',
        kind: WatchKind.sermon,
        title: 'The Power of Resurrection',
        speakerName: 'Bishop J. Mensah',
        progress: 0.68,
        durationLabel: '14 min left',
      ),
      WatchCard(
        id: 'w-2',
        kind: WatchKind.podcast,
        title: 'Faith That Moves Mountains',
        speakerName: 'Pastor Grace K.',
        progress: 0.33,
        durationLabel: '22 min left',
      ),
      WatchCard(
        id: 'w-3',
        kind: WatchKind.sermon,
        title: 'Kingdom Principles for Business',
        speakerName: 'Dr. Emmanuel A.',
        progress: 0.81,
        durationLabel: '8 min left',
      ),
      WatchCard(
        id: 'w-4',
        kind: WatchKind.sermon,
        title: 'Walking in the Spirit',
        speakerName: 'Bishop J. Mensah',
        progress: 0.15,
        durationLabel: '38 min left',
      ),
    ];
  }

  // ── Aggregate ────────────────────────────────────────────────────────────────

  Future<HomeDashboardData> fetchAll() async {
    final results = await Future.wait([
      fetchGreeting(),
      fetchScripture(),
      fetchContinueCards(),
      fetchServiceStatus(),
      fetchDailyJourney(),
      fetchTodayEvents(),
      fetchPrayerCorner(),
      fetchCommunityHighlight(),
      fetchWatchCards(),
    ]);
    return HomeDashboardData(
      greeting: results[0] as DashboardGreeting,
      scripture: results[1] as ScriptureCard,
      continueCards: results[2] as List<ContinueCard>,
      serviceStatus: results[3] as ServiceStatus,
      dailyJourney: results[4] as DailyJourney,
      todayEvents: results[5] as List<TodayEvent>,
      prayerCorner: results[6] as PrayerCorner,
      communityHighlight: results[7] as CommunityHighlight,
      watchCards: results[8] as List<WatchCard>,
    );
  }

  Future<void> _latency(int ms) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  int _weekOfYear(DateTime dt) {
    final startOfYear = DateTime(dt.year);
    final diff = dt.difference(startOfYear).inDays;
    return (diff / 7).ceil() + 1;
  }
}

extension _DateTimeExt on DateTime {
  int get dayOfYear {
    final start = DateTime(year);
    return difference(start).inDays;
  }
}
