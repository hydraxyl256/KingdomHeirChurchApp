// Kingdom Heir — Dashboard auth.users permission regression test
//
// Pin down the production bug where `get_dashboard_greeting` queried
// `auth.users` directly and Supabase returned:
//
//   PostgrestException(
//     message: permission denied for table auth.users,
//     code: 42501,
//     details: forbidden,
//     hint: Grant SELECT ON auth.users...
//   )
//
// The Flutter repository used to rethrow that, and
// `DashboardScreen._readableError(err)` then showed the raw text to
// the end user via `AppErrorWidget`. This test simulates the same
// error and asserts:
//
//   1. The repository converts the PostgrestException into a safe
//      empty greeting — it never rethrows the raw exception to the
//      meta aggregator.
//   2. The screen's `error:` branch renders the friendly
//      `AppErrorWidget` — never the PostgrestException text.
//   3. The rest of the dashboard still renders when only the
//      greeting section has failed.
//
// We use mocktail to stub the SupabaseClient. The repository's
// `fetchAll` aggregator runs every section in parallel — only the
// greeting section is poisoned; every other section returns canned
// data. This mirrors the production fix: a single bad section
// cannot blank the screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/storage/cache_manager.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/features/dashboard/data/home_dashboard_repository.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:kingdom_heir/features/dashboard/presentation/providers/home_dashboard_providers.dart';
import 'package:kingdom_heir/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockRpcBuilder<T> extends Mock implements PostgrestFilterBuilder<T> {}

void main() {
  // `setUpAll` only takes a `VoidCallback`; the closure body is
  // required to perform multiple setup steps, hence the lambda.
  // ignore: unnecessary_lambdas
  setUpAll(() {
    // mocktail requires a registered fallback for any non-primitive
    // positional argument used with `any()`.
    registerFallbackValue(<String, dynamic>{});
  });

  test(
    'Repository.fetchGreeting swallows the auth.users PostgrestException '
    'and returns the safe empty greeting',
    () async {
      final client = _MockSupabaseClient();
      final auth = _MockGoTrueClient();
      when(() => auth.currentUser).thenReturn(null);
      when(() => client.auth).thenReturn(auth);

      // _guardData wraps the RPC in a PostgrestFilterBuilder chain.
      // The repository calls `.single()` on it. We make the chain
      // throw the exact production error.
      final rpcBuilder = _MockRpcBuilder<dynamic>();
      when(rpcBuilder.single).thenThrow(
        const PostgrestException(
          message: 'permission denied for table auth.users',
          code: '42501',
          details: 'forbidden',
          hint: 'Grant SELECT ON auth.users...',
        ),
      );
      when(
        () => client.rpc<dynamic>(
          any<String>(),
          params: any(named: 'params'),
        ),
      ).thenAnswer((_) => rpcBuilder);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cacheManager = CacheManager(prefs);
      final repo = HomeDashboardRepository(cacheManager, client: client);

      // Should NOT throw.
      final greeting = await repo.fetchGreeting();

      // The repository fell back to the empty greeting.
      expect(greeting.firstName, 'Friend');
      expect(greeting.streakDays, 0);
    },
  );

  testWidgets(
    'DashboardScreen shows the friendly error widget when the meta '
    'aggregator throws the auth.users PostgrestException — never the '
    'raw exception text',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Simulate the production-bug surface: the greetingProvider
      // throws the raw PostgrestException. The DashboardScreen
      // must convert that into a friendly message via
      // `_toFailure(...)`.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            greetingProvider.overrideWith(
              (ref) async => throw const PostgrestException(
                message: 'permission denied for table auth.users',
                code: '42501',
                details: 'forbidden',
                hint: 'Grant SELECT ON auth.users...',
              ),
            ),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Friendly message is shown.
      expect(
        find.text("We couldn't load your dashboard. Please try again."),
        findsOneWidget,
        reason: 'Dashboard must show a friendly message, not the raw '
            'PostgrestException text.',
      );
      // Raw exception text is never shown.
      expect(find.textContaining('PostgrestException'), findsNothing);
      expect(find.textContaining('auth.users'), findsNothing);
      expect(find.textContaining('permission denied'), findsNothing);
      expect(find.textContaining('42501'), findsNothing);
      // Retry is offered.
      expect(find.text('Try Again'), findsOneWidget);
    },
  );

  testWidgets(
    'DashboardScreen still renders all sections when the greeting '
    'section falls back to the safe empty greeting',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Production path: repository converted the auth.users error
      // into the safe empty greeting, and every other section
      // returns its data.
      const stub = HomeDashboardData(
        greeting: DashboardGreeting(
          firstName: 'Friend',
          moment: GreetingMoment.morning,
          streakDays: 0,
        ),
        scripture: ScriptureCard(
          verseText:
              'I can do all things through Christ who strengthens me.',
          reference: 'Philippians 4:13',
          translation: 'NKJV',
        ),
        continueCards: <ContinueCard>[],
        serviceStatus: ServiceStatus(
          isLive: false,
          title: 'Sunday Worship Service',
        ),
        dailyJourney: DailyJourney(streakDays: 0, tasks: <SpiritualTask>[]),
        todayEvents: <TodayEvent>[],
        prayerCorner: PrayerCorner(usersPrayedToday: 0, requests: []),
        communityHighlight: CommunityHighlight(),
        watchCards: <WatchCard>[],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            greetingProvider.overrideWith((ref) async => stub.greeting),
            scriptureProvider.overrideWith(
              (ref) async => <ScriptureCard>[stub.scripture],
            ),
            continueCardsProvider.overrideWith(
              (ref) async => stub.continueCards,
            ),
            serviceStatusProvider.overrideWith(
              (ref) async => stub.serviceStatus,
            ),
            journeyProvider.overrideWith(
              (ref) async => stub.dailyJourney,
            ),
            todayEventsProvider.overrideWith(
              (ref) async => stub.todayEvents,
            ),
            prayerCornerProvider.overrideWith(
              (ref) async => stub.prayerCorner,
            ),
            communityHighlightProvider.overrideWith(
              (ref) async => stub.communityHighlight,
            ),
            watchCardsProvider.overrideWith(
              (ref) async => stub.watchCards,
            ),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 1));

      // Greeting section fell back to "Friend".
      expect(find.text('Friend'), findsOneWidget);
      // No raw exception text anywhere.
      expect(find.textContaining('PostgrestException'), findsNothing);
      expect(find.textContaining('auth.users'), findsNothing);

      // Other sections still render.
      expect(
        find.textContaining('I can do all things through Christ'),
        findsOneWidget,
      );
      expect(find.text('Continue Your Journey'), findsOneWidget);
      expect(find.text('NEXT SERVICE'), findsOneWidget);
    },
  );
}
