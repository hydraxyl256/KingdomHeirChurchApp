import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/app.dart';

void main() {
  testWidgets('KingdomHeirApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KingdomHeirApp(),
      ),
    );
    // App should build without throwing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
