// Kingdom Heir — Register screen smoke test
//
// Regression guard for the single-screen registration flow (memory
// `register-screen-redesign-2026-06`). We override the auth providers
// with stubs so the test never hits Supabase, then assert the three
// required fields (email, password, confirm password), the Google
// button, the Sign In footer, and the "Create Account" CTA all render
// without throwing. If anyone reverts the wizard to a multi-step flow
// or removes a field, this test will fail.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Register screen renders email, password, confirm, Google CTA, and Sign In footer',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            sharedPreferencesProvider.overrideWithValue(prefs),
            // Replace the live auth repository stream with an empty one so
            // the screen doesn't try to call Supabase during the test.
            authStateProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const RegisterScreen(),
          ),
        ),
      );

      // First pump: builds the form.
      await tester.pump();
      // Second pump: any entrance animation reaches its first frame.
      await tester.pump(const Duration(milliseconds: 50));
      // Third pump: let the rest of the entrance animation settle.
      await tester.pump(const Duration(milliseconds: 400));

      // Form fields are present.
      expect(find.byType(TextFormField), findsNWidgets(3));

      // Google OAuth button is present.
      expect(find.text('Continue with Google'), findsOneWidget);

      // Primary CTA is present.
      expect(find.text('Create Account'), findsOneWidget);

      // "Already have an account? Sign In" footer is present.
      expect(find.textContaining('Sign In'), findsWidgets);
    },
  );
}
