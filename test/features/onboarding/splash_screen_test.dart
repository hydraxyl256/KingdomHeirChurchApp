import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/features/onboarding/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('never renders a startup diagnostic banner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.textContaining('FINGERPRINT'), findsNothing);
    expect(find.textContaining('abc1234'), findsNothing);
    expect(find.textContaining('Mode: Release'), findsNothing);
  });
}
