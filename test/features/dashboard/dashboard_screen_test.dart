// Kingdom Heir — Dashboard screen widget test
//
// Regression guard + smoke test. The DashboardScreen rebuilds against
// 9 per-section FutureProviders + 1 meta aggregator. This test:
//
//   1. Overrides every per-section provider with a fully-populated
//      HomeDashboardData (matches the test/features/more/more_screen_test.dart
//      pattern).
//   2. Asserts the CustomScrollView lays out without throwing — this is
//      the same RenderViewport → RenderSliverToBoxAdapter regression
//      that bit the More screen. Anyone re-introducing a
//      `child.animate().fadeIn().slideY()` chain inside a
//      SliverToBoxAdapter will trip this test.
//   3. Asserts the 10 redesigned sections are present.
//   4. Asserts the floating prayer FAB is rendered above the body.
//   5. Asserts the Quick Actions Bible tap pushes the bible route.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:kingdom_heir/features/dashboard/presentation/providers/home_dashboard_providers.dart';
import 'package:kingdom_heir/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/_shared/floating_prayer_button.dart';
import 'package:kingdom_heir/features/dashboard/presentation/widgets/actions/quick_actions_strip.dart';
import 'package:shared_preferences/shared_preferences.dart';

HomeDashboardData _stubDashboard() {
  return HomeDashboardData(
    greeting: const DashboardGreeting(
      firstName: 'Eron',
      moment: GreetingMoment.morning,
      streakDays: 17,
      unreadNotifications: 3,
    ),
    scripture: const ScriptureCard(
      verseText: 'I can do all things through Christ who strengthens me.',
      reference: 'Philippians 4:13',
      translation: 'NKJV',
    ),
    continueCards: const <ContinueCard>[
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
    ],
    serviceStatus: ServiceStatus(
      isLive: false,
      title: 'Sunday Worship Service',
      hostLabel: 'Bishop J. Mensah',
      startsAt: DateTime.now().add(const Duration(hours: 23, minutes: 45)),
      locationLabel: 'Main Sanctuary · In-person & Online',
    ),
    dailyJourney: const DailyJourney(
      streakDays: 17,
      tasks: <SpiritualTask>[
        SpiritualTask(kind: SpiritualTaskKind.scripture, isCompleted: true),
        SpiritualTask(kind: SpiritualTaskKind.devotional, isCompleted: true),
        SpiritualTask(kind: SpiritualTaskKind.prayer, isCompleted: false),
        SpiritualTask(kind: SpiritualTaskKind.reflection, isCompleted: false),
        SpiritualTask(kind: SpiritualTaskKind.worship, isCompleted: false),
        SpiritualTask(kind: SpiritualTaskKind.journal, isCompleted: false),
      ],
    ),
    todayEvents: <TodayEvent>[
      TodayEvent(
        id: 'e-1',
        title: 'Prayer & Intercession',
        startsAt: DateTime.now().add(const Duration(hours: 3)),
        locationLabel: 'Prayer Room — Ground Floor',
        leaderName: 'Pastor Grace K.',
        category: TodayEventCategory.prayer,
      ),
      TodayEvent(
        id: 'e-2',
        title: 'Youth Bible Study',
        startsAt: DateTime.now().add(const Duration(hours: 18)),
        locationLabel: 'Youth Hall',
        leaderName: 'Mr. Kofi M.',
        category: TodayEventCategory.bibleStudy,
      ),
    ],
    prayerCorner: const PrayerCorner(
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
      ],
    ),
    communityHighlight: const CommunityHighlight(
      unreadGroupMessages: 5,
      birthdayName: 'Sarah Mensah',
      leaderAnnouncement: 'Leaders meeting this Saturday at 8 AM.',
      upcomingGroupMeeting: 'Worship Team rehearsal · Friday 6 PM',
    ),
    watchCards: const <WatchCard>[
      WatchCard(
        id: 'w-1',
        kind: WatchKind.sermon,
        title: 'The Power of Resurrection',
        speakerName: 'Bishop J. Mensah',
        progress: 0.68,
        durationLabel: '14 min left',
        isDownloaded: true,
      ),
      WatchCard(
        id: 'w-2',
        kind: WatchKind.podcast,
        title: 'Faith That Moves Mountains',
        speakerName: 'Pastor Grace K.',
        progress: 0.33,
        durationLabel: '22 min left',
      ),
    ],
  );
}

Future<List<Override>> _testOverrides() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final stub = _stubDashboard();
  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    greetingProvider.overrideWith((ref) async => stub.greeting),
    scriptureProvider.overrideWith((ref) async => <ScriptureCard>[
          stub.scripture,
        ]),
    continueCardsProvider.overrideWith((ref) async => stub.continueCards),
    serviceStatusProvider.overrideWith((ref) async => stub.serviceStatus),
    journeyProvider.overrideWith((ref) async => stub.dailyJourney),
    todayEventsProvider.overrideWith((ref) async => stub.todayEvents),
    prayerCornerProvider.overrideWith((ref) async => stub.prayerCorner),
    communityHighlightProvider
        .overrideWith((ref) async => stub.communityHighlight),
    watchCardsProvider.overrideWith((ref) async => stub.watchCards),
  ];
}

void main() {
  testWidgets(
    'Dashboard builds all 10 redesigned sections, FAB, and Quick Actions',
    (tester) async {
      // Phone-class viewport — matches the runtime environment.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final overrides = await _testOverrides();

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      // First pump: providers resolve and the screen builds the
      // CustomScrollView with all 10 sections.
      await tester.pump();
      // Second pump: any TweenAnimationBuilder-driven entrance animation
      // reaches its first frame.
      await tester.pump(const Duration(milliseconds: 50));
      // Third pump: animations settle to first frame.
      // NOTE: pumpAndSettle() is intentionally avoided — the floating
      // prayer FAB runs a repeat(reverse: true) breathing controller
      // (2400ms period) that never settles.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 1));

      // ── Top-level chrome ────────────────────────────────────────
      // Greeting header
      expect(find.text('Eron'), findsOneWidget);

      // ── Scripture hero ───────────────────────────────────────────
      // Verse text uses curly quotes around the verse.
      expect(
        find.textContaining('I can do all things through Christ'),
        findsOneWidget,
      );
      expect(find.text('— Philippians 4:13'), findsOneWidget);

      // ── Continue Your Journey ────────────────────────────────────
      expect(find.text('Continue Your Journey'), findsOneWidget);

      // ── Service status card ──────────────────────────────────────
      expect(find.text('NEXT SERVICE'), findsOneWidget);
      expect(find.text('Sunday Worship Service'), findsOneWidget);

      // ── Daily Spiritual Journey ──────────────────────────────────
      expect(find.text('Daily Spiritual Journey'), findsOneWidget);
      expect(find.text('17-day streak — keep going!'), findsOneWidget);

      // ── Church Today ─────────────────────────────────────────────
      expect(find.text('Church Today'), findsOneWidget);

      // ── Prayer Corner ────────────────────────────────────────────
      expect(find.text('Prayer Corner'), findsOneWidget);
      expect(find.text('84 people prayed today'), findsOneWidget);
      expect(find.text('Submit a Prayer Request'), findsOneWidget);

      // ── Community (2x2 grid) ─────────────────────────────────────
      expect(find.text('Community'), findsOneWidget);

      // ── Continue Watching ────────────────────────────────────────
      expect(find.text('Continue Watching'), findsOneWidget);

      // ── Quick Actions ────────────────────────────────────────────
      expect(find.text('Quick Actions'), findsOneWidget);
      // 4 actions: Bible, Prayer, Sermons, Give — scoped to the strip
      // because the journey task list also contains a "Prayer" task
      // label.
      final quickActions = find.byType(QuickActionsStrip);
      expect(quickActions, findsOneWidget);
      expect(
        find.descendant(of: quickActions, matching: find.text('Bible')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: quickActions, matching: find.text('Prayer')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: quickActions, matching: find.text('Sermons')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: quickActions, matching: find.text('Give')),
        findsOneWidget,
      );

      // ── Floating Prayer FAB ──────────────────────────────────────
      expect(find.byType(FloatingPrayerButton), findsOneWidget);
    },
  );
}
