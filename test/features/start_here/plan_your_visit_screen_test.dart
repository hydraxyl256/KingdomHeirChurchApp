// Kingdom Heir — Plan Your Visit screen smoke test
//
// Verifies the new "Plan Your Visit" page (reached from Start Here →
// "Join Us This Sunday") renders all required sections: top bar,
// hero, service times, address card with Get Directions, Watch Live
// button, contact card, prayer shortcut, and Back to Discover.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/features/start_here/presentation/screens/plan_your_visit_screen.dart';

void main() {
  testWidgets(
    'Plan Your Visit screen renders all required sections',
    (tester) async {
      // Tall enough view (logical px) that the ListView builds all
      // cells onscreen — no scrolling required.
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const PlanYourVisitScreen(),
        ),
      );

      // Drive all entrance animations to completion so the lazy-built
      // cells finish laying out and are mounted in the element tree.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 800));

      // Top bar title (always mounted, not inside the ListView).
      expect(find.text('Plan Your Visit'), findsWidgets);

      // Hero copy (first cell, offstage-laid-out via the entrance
      // animation timers we just pumped).
      expect(find.text("We can't wait to meet you."), findsOneWidget);

      // Service Times header.
      expect(find.text('Service Times'), findsOneWidget);

      // Find Us (address card).
      expect(find.text('Find Us'), findsOneWidget);

      // Address & directions.
      expect(find.text('Get Directions'), findsOneWidget);

      // Watch Live.
      expect(find.text('Watch Live'), findsOneWidget);

      // Contact rows.
      expect(find.text('Get in Touch'), findsOneWidget);
      for (final label in ['Email', 'Phone', 'WhatsApp', 'Website']) {
        expect(find.text(label), findsOneWidget);
      }

      // Prayer shortcut.
      expect(find.text('Need prayer?'), findsOneWidget);

      // Back to Discover.
      expect(find.text('Back to Discover'), findsOneWidget);
    },
  );
}
