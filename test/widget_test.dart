// Kingdom Heir — Root smoke test
//
// Boots the full app with a stubbed [SharedPreferences] and a minimal
// [GoRouter] (replacing the production router so we don't hit
// Supabase/auth redirect logic). Asserts the app renders a
// [MaterialApp] without throwing — the same regression guard the rest
// of the per-screen tests rely on, just at the top level.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/app.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('KingdomHeirApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // A throwaway router so the production redirect/auth logic never
    // runs — we only care that the app builds a MaterialApp.
    final stubRouter = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: Center(child: Text('Smoke test')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
          appRouterProvider.overrideWithValue(stubRouter),
        ],
        child: const KingdomHeirApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
