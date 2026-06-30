// Kingdom Heir — Offline Dashboard Mock Data
//
// Curated fallback content returned by `HomeDashboardRepository` when
// Supabase is unreachable. Keeps the dashboard rendering a believable
// surface during offline sessions — never blank — and gives new users
// sample rows to interact with on first launch.
//
// The data here mirrors the seed content described in
// `supabase/migrations/20260630_dashboard_real_data.sql` so the offline
// view is visually identical to the seeded live view.

import 'dart:math' as math;

import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

abstract final class HomeDashboardMock {
  HomeDashboardMock._();

  static DashboardGreeting greeting(math.Random rng) {
    final now = DateTime.now();
    return DashboardGreeting(
      firstName: 'Eron',
      moment: resolveGreetingMoment(now),
      streakDays: 17,
      unreadNotifications: 3,
    );
  }

  static ScriptureCard scripture() {
    const verses = <(String, String, String)>[
      (
        'I can do all things through Christ who strengthens me.',
        'Philippians 4:13',
        'NKJV',
      ),
      (
        'Trust in the Lord with all your heart, and do not lean on your own understanding.',
        'Proverbs 3:5',
        'ESV',
      ),
      (
        'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
        'John 3:16',
        'NIV',
      ),
      (
        'The Lord is my shepherd; I shall not want.',
        'Psalm 23:1',
        'KJV',
      ),
      (
        'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
        'Joshua 1:9',
        'NIV',
      ),
    ];
    final idx = DateTime.now().day % verses.length;
    final v = verses[idx];
    return ScriptureCard(
      verseText: v.$1,
      reference: v.$2,
      translation: v.$3,
    );
  }

  static const List<ScriptureCard> scriptureRoster = <ScriptureCard>[
    ScriptureCard(
      verseText:
          'I can do all things through Christ who strengthens me.',
      reference: 'Philippians 4:13',
      translation: 'NKJV',
    ),
    ScriptureCard(
      verseText:
          'Trust in the Lord with all your heart, and do not lean on your own understanding.',
      reference: 'Proverbs 3:5',
      translation: 'ESV',
    ),
    ScriptureCard(
      verseText:
          'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
      reference: 'John 3:16',
      translation: 'NIV',
    ),
    ScriptureCard(
      verseText: 'The Lord is my shepherd; I shall not want.',
      reference: 'Psalm 23:1',
      translation: 'KJV',
    ),
    ScriptureCard(
      verseText:
          'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      reference: 'Joshua 1:9',
      translation: 'NIV',
    ),
  ];

  static const List<ContinueCard> continueCards = <ContinueCard>[
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

  static ServiceStatus serviceStatus(math.Random rng) {
    final now = DateTime.now();
    final isSunday = now.weekday == DateTime.sunday;
    if (isSunday) {
      return ServiceStatus(
        isLive: true,
        title: 'Sunday Worship — Week ${_weekOfYear(now)}',
        hostLabel: 'with Bishop J. Mensah',
        viewerCount: 1248 + rng.nextInt(80),
        streamUrl: '',
      );
    }
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

  static const DailyJourney dailyJourney = DailyJourney(
    streakDays: 17,
    tasks: <SpiritualTask>[
      SpiritualTask(kind: SpiritualTaskKind.scripture, isCompleted: true),
      SpiritualTask(kind: SpiritualTaskKind.devotional, isCompleted: true),
      SpiritualTask(kind: SpiritualTaskKind.prayer, isCompleted: false),
      SpiritualTask(kind: SpiritualTaskKind.reflection, isCompleted: false),
      SpiritualTask(kind: SpiritualTaskKind.worship, isCompleted: false),
      SpiritualTask(kind: SpiritualTaskKind.journal, isCompleted: false),
    ],
  );

  static List<TodayEvent> todayEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return <TodayEvent>[
      TodayEvent(
        id: 'e-1',
        title: 'Prayer & Intercession',
        startsAt: today.add(const Duration(hours: 6)),
        locationLabel: 'Prayer Room — Ground Floor',
        leaderName: 'Pastor Grace K.',
        category: TodayEventCategory.prayer,
      ),
      TodayEvent(
        id: 'e-2',
        title: 'Youth Bible Study',
        startsAt: today.add(const Duration(hours: 18, minutes: 30)),
        locationLabel: 'Youth Hall',
        leaderName: 'Mr. Kofi M.',
        category: TodayEventCategory.bibleStudy,
      ),
      TodayEvent(
        id: 'e-3',
        title: 'Midweek Service',
        startsAt: tomorrow.add(const Duration(hours: 19)),
        locationLabel: 'Main Sanctuary · Online',
        isOnline: true,
        isToday: false,
        leaderName: 'Bishop J. Mensah',
        category: TodayEventCategory.sundayService,
      ),
    ];
  }

  static const PrayerCorner prayerCorner = PrayerCorner(
    usersPrayedToday: 84,
    answeredPrayerHighlight:
        '"After months of chronic pain, God brought complete healing." — Sarah M.',
    requests: <PrayerRequest>[
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

  static const CommunityHighlight communityHighlight = CommunityHighlight(
    unreadGroupMessages: 5,
    birthdayName: 'Sarah Mensah',
    leaderAnnouncement: 'Leaders meeting this Saturday at 8 AM.',
    upcomingGroupMeeting: 'Worship Team rehearsal · Friday 6 PM',
  );

  static const List<WatchCard> watchCards = <WatchCard>[
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
      isDownloaded: true,
    ),
  ];

  static int _weekOfYear(DateTime dt) {
    final startOfYear = DateTime(dt.year);
    final diff = dt.difference(startOfYear).inDays;
    return (diff / 7).ceil() + 1;
  }
}

extension _DateTimeExt on DateTime {
  int get day {
    final start = DateTime(year);
    return difference(start).inDays;
  }
}