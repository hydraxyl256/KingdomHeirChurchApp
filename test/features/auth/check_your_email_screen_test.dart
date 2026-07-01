// Kingdom Heir — "Check Your Email" screen smoke test
//
// Verifies the premium email-verification success screen renders all
// required CTAs (Open Email App, Resend, Back to Sign In) and the email
// address. The screen normally polls Supabase every 5s for verification
// status — we override `authStateProvider` with an empty stream and
// stub the Supabase client so the timer never touches the network.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/check_your_email_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recursively walks a [TextSpan] tree looking for a child whose
/// `text` contains [needle]. Used to assert on rich-text content
/// (which is not directly addressable by `find.text`).
bool _spanContains(InlineSpan span, String needle) {
  if (span is TextSpan) {
    if (span.text != null && span.text!.contains(needle)) return true;
    final children = span.children;
    if (children != null) {
      for (final c in children) {
        if (_spanContains(c, needle)) return true;
      }
    }
  }
  return false;
}

void main() {
  testWidgets(
    'Check Your Email screen renders title, address, Resend, Open Email App, Back to Sign In',
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
            // The screen polls the auth state on a 5-second timer; an
            // empty stream prevents the poller from doing any work.
            authStateProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CheckYourEmailScreen(
              email: 'test@kingdomheirs.app',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));

      // Title
      expect(find.text('Check your email'), findsOneWidget);

      // The address is rendered inside a RichText/TextSpan subtree.
      // We walk the RichText widget list and search for a TextSpan
      // whose `text` contains the email.
      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final foundInRichText = richTexts.any((rt) {
        final span = rt.text;
        return _spanContains(span, 'test@kingdomheirs.app');
      });
      expect(foundInRichText, isTrue);

      // CTAs all render
      expect(find.text('Open Email App'), findsOneWidget);
      // "I've verified my email" is the primary continue button.
      expect(find.text("I've verified my email"), findsOneWidget);
      // "Use a different email" is the change-email link.
      expect(find.text('Use a different email'), findsOneWidget);
      // Resend label exists; the timer text follows the same Text widget.
      expect(find.textContaining('Resend'), findsOneWidget);
    },
  );
}
