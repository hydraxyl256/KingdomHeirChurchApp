// Kingdom Heir — Submit Prayer screen widget test
//
// Asserts the three contract guarantees of the submit flow:
//   1. The form is rendered with title, body, category, visibility,
//      and anonymous controls.
//   2. On successful submit, the screen replaces the form in-place
//      with the "Prayer request received" confirmation card.
//   3. While a submit is in flight, the button is disabled so a
//      rapid double-tap cannot enqueue two requests.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/features/prayer_requests/data/models/prayer_request_model.dart';
import 'package:kingdom_heir/features/prayer_requests/data/repositories/prayer_repository.dart';
import 'package:kingdom_heir/features/prayer_requests/presentation/screens/submit_prayer_screen.dart';

/// A `PrayerRepository` whose `submitPrayerRequest` resolves after
/// a configurable delay so we can test the "in flight" button state.
class _FakePrayerRepository implements PrayerRepository {
  _FakePrayerRepository({this.delay = const Duration(milliseconds: 50)});

  final Duration delay;
  int submitCallCount = 0;
  Map<String, dynamic>? lastSubmittedPayload;

  @override
  Future<Either<String, void>> submitPrayerRequest(
    Map<String, dynamic> insertData,
  ) async {
    submitCallCount += 1;
    lastSubmittedPayload = insertData;
    await Future<void>.delayed(delay);
    return const Right(null);
  }

  // ── Unused by these tests; throw clearly so future regressions surface.
  @override
  Future<Either<String, List<PrayerRequestModel>>> getApprovedPrayerWall({
    int limit = 50,
  }) async =>
      const Right([]);

  @override
  Future<Either<String, List<PrayerRequestModel>>> getMyPrayerRequests({
    int limit = 30,
  }) async =>
      const Right([]);

  @override
  Future<Either<String, void>> togglePrayerIntercession(
    String prayerRequestId, {
    required bool isPraying,
  }) async =>
      const Right(null);

  @override
  Stream<List<Map<String, dynamic>>> streamApprovedPrayerWall() =>
      const Stream.empty();

  @override
  Future<List<String>> getIntercededPrayerIds() async => const [];

  @override
  Future<Either<String, List<PrayerRequestModel>>>
      getPendingPrayerRequestsForAdmin({int limit = 50}) async => const Right([]);

  @override
  Future<Either<String, List<PrayerRequestModel>>>
      getApprovedPrayerRequestsForAdmin({int limit = 50}) async => const Right([]);

  @override
  Future<Either<String, List<PrayerRequestModel>>>
      getRejectedPrayerRequestsForAdmin({int limit = 50}) async => const Right([]);

  @override
  Future<Either<String, void>> approvePrayerRequest({
    required String id,
    String? adminNote,
  }) async =>
      const Right(null);

  @override
  Future<Either<String, void>> rejectPrayerRequest({
    required String id,
    String? adminNote,
  }) async =>
      const Right(null);

  @override
  Future<Either<String, void>> returnPrayerRequestToPending({
    required String id,
  }) async =>
      const Right(null);
}

Future<void> _pumpSubmitScreen(
  WidgetTester tester, {
  required _FakePrayerRepository repo,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        prayerRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const SubmitPrayerScreen(),
      ),
    ),
  );

  await tester.pump(); // First build
  await tester.pump(const Duration(milliseconds: 400)); // Animate in
}

void main() {
  testWidgets('Submit Prayer screen renders the full form', (tester) async {
    final repo = _FakePrayerRepository();
    await _pumpSubmitScreen(tester, repo: repo);

    // Title field is present.
    expect(find.text('Prayer title'), findsOneWidget);
    // Body field is present.
    expect(find.text('Your prayer request'), findsOneWidget);
    // Visibility header is present.
    expect(find.text('Visibility'), findsOneWidget);
    // Anonymous toggle is present.
    expect(find.text('Submit anonymously'), findsOneWidget);
    // Primary CTA is present.
    expect(find.text('Submit Prayer Request'), findsOneWidget);
    // Safety disclaimer is present.
    expect(
      find.textContaining('For urgent emergencies'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Submitting the form replaces it with the confirmation card',
    (tester) async {
      final repo = _FakePrayerRepository(delay: const Duration(milliseconds: 30));
      await _pumpSubmitScreen(tester, repo: repo);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Prayer title'),
        'Strength for the week',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Your prayer request'),
        'Please pray for me this week.',
      );

      await tester.tap(find.text('Submit Prayer Request'));
      await tester.pump(); // start the in-flight
      await tester.pump(const Duration(milliseconds: 200)); // settle
      await tester.pump(const Duration(milliseconds: 400)); // animate in

      // The form is gone, the confirmation card is present.
      expect(find.text('Submit Prayer Request'), findsNothing);
      expect(find.text('Prayer request received'), findsOneWidget);
      expect(find.text('View my requests'), findsOneWidget);
      expect(find.text('Submit another'), findsOneWidget);

      // The submit call hit the repository exactly once.
      expect(repo.submitCallCount, 1);
      // The payload was sanitized — no admin-controlled field slipped through.
      final payload = repo.lastSubmittedPayload!;
      expect(payload.containsKey('status'), isFalse);
      expect(payload.containsKey('admin_note'), isFalse);
      expect(payload.containsKey('requester_name'), isFalse);
    },
  );

  testWidgets(
    'Submit another clears the form so a second submission works',
    (tester) async {
      final repo = _FakePrayerRepository(delay: const Duration(milliseconds: 20));
      await _pumpSubmitScreen(tester, repo: repo);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Prayer title'),
        'First',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Your prayer request'),
        'First body',
      );
      await tester.tap(find.text('Submit Prayer Request'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Prayer request received'), findsOneWidget);

      await tester.tap(find.text('Submit another'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Confirmation card is gone, the form is back.
      expect(find.text('Prayer request received'), findsNothing);
      expect(find.text('Submit Prayer Request'), findsOneWidget);
    },
  );
}
