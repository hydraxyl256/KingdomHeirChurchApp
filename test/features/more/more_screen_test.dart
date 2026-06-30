// Kingdom Heir — More screen widget test
//
// Regression guard: the More screen used to throw a runtime
// `Null check operator used on a null value` originating from
// `RenderViewport → RenderSliverToBoxAdapter → RenderBox.size`. The
// root cause was `flutter_animate`'s internal Builder interacting badly
// with SliverToBoxAdapter measurement. This test pumps the screen with
// fully-resolved async data, all 9 sections visible, and asserts the
// CustomScrollView lays out without throwing. If anyone re-introduces a
// `child.animate().fadeIn().slideY()` chain inside a SliverToBoxAdapter
// this test will catch it.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';
import 'package:kingdom_heir/features/more/presentation/providers/more_providers.dart';
import 'package:kingdom_heir/features/more/presentation/screens/more_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Override>> _testOverrides() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  const profile = MoreProfileHero(
    displayName: 'Test User',
    email: 'test@kingdomheir.app',
    roleLabel: 'Member',
    streakDays: 7,
    memberSinceLabel: 'Member since Jan 2024',
  );

  const favorites = FavoriteFeatures([
    MoreFeature.bible,
    MoreFeature.prayer,
    MoreFeature.events,
  ]);

  final recents = <RecentItem>[
    RecentItem(
      feature: MoreFeature.bible,
      label: 'Bible',
      subtitle: 'Read the Word',
      route: '/bible',
      usedAt: DateTime.now(),
    ),
    RecentItem(
      feature: MoreFeature.devotionals,
      label: 'Devotionals',
      subtitle: 'Daily reading',
      route: '/devotionals',
      usedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final giving = MoreGivingSummary(
    monthLabel: DateFormat.MMMM().format(DateTime.now()),
    amountGiven: 320,
    goalAmount: 500,
    campaignTitle: 'New Sanctuary Build',
    campaignRaised: 42000,
    campaignGoal: 80000,
    recentMonths: const [120, 200, 180, 240, 280, 320],
  );

  const family = FamilyEvents(
    nextEventLabel: 'Sunday Worship',
    nextEventWhen: 'This Sunday · 10:00 AM',
    upcomingCount: 4,
    thisWeekCount: 2,
    kidsCheckedInToday: 12,
  );

  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    moreProfileProvider.overrideWith((ref) async => profile),
    moreFavoritesProvider.overrideWith(() => _StubFavoritesNotifier(favorites)),
    moreRecentsProvider.overrideWith((ref) async => recents),
    moreGivingProvider.overrideWith((ref) async => giving),
    moreFamilyEventsProvider.overrideWith((ref) async => family),
  ];
}

class _StubFavoritesNotifier extends FavoritesNotifier {
  _StubFavoritesNotifier(this._initial);
  final FavoriteFeatures _initial;

  @override
  Future<FavoriteFeatures> build() async => _initial;
}

void main() {
  testWidgets(
    'More screen builds all 9 sections without runtime exception',
    (tester) async {
      // Force a known surface size so the CustomScrollView has bounded
      // constraints. This matches the runtime environment of a phone.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final overrides = await _testOverrides();

      // The screen must pump and settle without throwing. This is the
      // regression guard for the
      // `RenderViewport → RenderSliverToBoxAdapter → RenderBox.size` crash.
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MoreScreen(),
          ),
        ),
      );

      // First pump: providers resolve and the screen builds the
      // CustomScrollView with all 9 sections.
      await tester.pump();
      // Second pump: any TweenAnimationBuilder-driven entrance animation
      // reaches its first frame.
      await tester.pump(const Duration(milliseconds: 50));
      // Third pump: animations settle.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // ── Top-level chrome ─────────────────────────────────────────
      expect(find.text('Kingdom Center'), findsOneWidget);

      // ── SECTION 1 — Profile hero ─────────────────────────────────
      expect(find.text('Test User'), findsOneWidget);

      // ── SECTION 5 — Kingdom Giving ───────────────────────────────
      // Scroll the CustomScrollView until the Kingdom Giving section
      // is on screen — on a 360×800 phone the lower sections start
      // off-screen and need a scroll to render.
      await tester.scrollUntilVisible(
        find.text('KINGDOM GIVING'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('KINGDOM GIVING'), findsOneWidget);
      expect(find.textContaining('of monthly goal'), findsOneWidget);

      // ── SECTION 6 — Family & Events ──────────────────────────────
      await tester.scrollUntilVisible(
        find.text('FAMILY & EVENTS'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('FAMILY & EVENTS'), findsOneWidget);
      expect(find.text('Sunday Worship'), findsOneWidget);

      // ── SECTION 9 — Account ──────────────────────────────────────
      await tester.scrollUntilVisible(
        find.text('Account'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Account'), findsOneWidget);
    },
  );
}
