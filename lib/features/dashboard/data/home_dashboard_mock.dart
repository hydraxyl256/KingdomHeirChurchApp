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
      firstName: 'Good Steward',
      moment: resolveGreetingMoment(now),
      streakDays: 12,
      unreadNotifications: 3,
      avatarUrl: 'assets/images/dashboard/profile.jpg',
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
      backgroundUrl: 'assets/images/dashboard/verse_bg.jpg',
    );
  }

  static const List<ScriptureCard> scriptureRoster = <ScriptureCard>[
    ScriptureCard(
      verseText: 'I can do all things through Christ who strengthens me.',
      reference: 'Philippians 4:13',
      translation: 'NKJV',
      backgroundUrl: 'assets/images/dashboard/verse_bg.jpg',
    ),
    ScriptureCard(
      verseText:
          'Trust in the Lord with all your heart, and do not lean on your own understanding.',
      reference: 'Proverbs 3:5',
      translation: 'ESV',
      backgroundUrl: 'assets/images/dashboard/verse_bg.jpg',
    ),
    ScriptureCard(
      verseText:
          'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
      reference: 'John 3:16',
      translation: 'NIV',
      backgroundUrl: 'assets/images/dashboard/verse_bg.jpg',
    ),
    ScriptureCard(
      verseText: 'The Lord is my shepherd; I shall not want.',
      reference: 'Psalm 23:1',
      translation: 'KJV',
      backgroundUrl: 'assets/images/dashboard/verse_bg.jpg',
    ),
    ScriptureCard(
      verseText:
          'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      reference: 'Joshua 1:9',
      translation: 'NIV',
      backgroundUrl: 'assets/images/dashboard/verse_bg.jpg',
    ),
  ];

  static const List<ContinueCard> continueCards = <ContinueCard>[
    ContinueCard(
      id: 'plan-1',
      kind: ContinueKind.biblePlan,
      title: 'Finding Your Purpose',
      subtitle: 'Day 4 of 7',
      progress: 0.65,
      thumbnailUrl: 'assets/images/dashboard/journey_1.jpg',
    ),
    ContinueCard(
      id: 'plan-2',
      kind: ContinueKind.biblePlan,
      title: 'Kingdom Principles',
      subtitle: 'Day 1 of 12',
      progress: 0.15,
      thumbnailUrl: 'assets/images/dashboard/journey_2.jpg',
    ),
    ContinueCard(
      id: 'devotional-1',
      kind: ContinueKind.devotional,
      title: 'The Power of Community',
      subtitle: 'Day 10 of 10',
      progress: 0.85,
      thumbnailUrl: 'assets/images/dashboard/journey_3.jpg',
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
      title: 'The Art of Stewardship',
      speakerName: 'Series: Ancient Paths • 45m',
      progress: 0.42,
      thumbnailUrl: 'assets/images/dashboard/watch_1.jpg',
    ),
    WatchCard(
      id: 'w-2',
      kind: WatchKind.sermon,
      title: 'Worship & The Word',
      speakerName: 'Live Session • Oct 20',
      progress: 0,
      thumbnailUrl: 'assets/images/dashboard/watch_2.jpg',
    ),
    WatchCard(
      id: 'w-3',
      kind: WatchKind.sermon,
      title: 'Living With Purpose',
      speakerName: 'Special Message',
      progress: 0.1,
      thumbnailUrl: 'assets/images/dashboard/watch_3.jpg',
    ),
  ];

  static int _weekOfYear(DateTime dt) {
    final startOfYear = DateTime(dt.year);
    final diff = dt.difference(startOfYear).inDays;
    return (diff / 7).ceil() + 1;
  }
}
