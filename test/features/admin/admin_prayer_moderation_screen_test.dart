// Kingdom Heir — Admin Prayer Moderation screen widget test
//
// Asserts the two contract guarantees of the admin moderation screen:
//   1. A non-admin user sees a "Redirecting…" placeholder instead of
//      the moderation tabs (defense in depth on top of the route guard
//      and the RLS policies on the underlying RPCs).
//   2. An admin user sees the three tabs (Pending review, Approved,
//      Not published).
//
// We do not exercise the approve/reject flows end-to-end here — they
// need real RPC calls or a deep Supabase fake, which is out of scope
// for a smoke test. Those flows are covered by the repository tests.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_prayer_moderation_screen.dart';
import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:kingdom_heir/features/prayer_requests/data/models/prayer_request_model.dart';
import 'package:kingdom_heir/features/prayer_requests/data/repositories/prayer_repository.dart';

const _adminUser = AppUser(
  id: 'admin-1',
  email: 'admin@example.com',
  fullName: 'Admin User',
  role: UserRole.admin,
);

const _memberUser = AppUser(
  id: 'member-1',
  email: 'member@example.com',
  fullName: 'Member User',
  role: UserRole.member,
);

/// Empty prayer repository. The screen's data tabs all show empty
/// states; this test only cares about the tabs themselves and the
/// admin guard.
class _EmptyPrayerRepository implements PrayerRepository {
  @override
  Future<Either<String, List<PrayerRequestModel>>> getApprovedPrayerWall({
    int limit = 50,
  }) async =>
      const Right([]);

  @override
  Future<Either<String, void>> submitPrayerRequest(
    Map<String, dynamic> insertData,
  ) async =>
      const Right(null);

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
  Future<Either<String, List<PrayerRequestModel>>> getMyPrayerRequests({
    int limit = 30,
  }) async =>
      const Right([]);

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

Future<void> _pumpScreen(
  WidgetTester tester, {
  required AppUser user,
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
        authStateProvider.overrideWith((ref) => Stream.value(user)),
        prayerRepositoryProvider.overrideWithValue(_EmptyPrayerRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const AdminPrayerModerationScreen(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets(
    'Non-admin user sees the redirect placeholder, not the tabs',
    (tester) async {
      await _pumpScreen(tester, user: _memberUser);

      // The redirect placeholder is visible.
      expect(find.text('Redirecting…'), findsOneWidget);
      // The admin tabs are NOT visible.
      expect(find.text('Pending review'), findsNothing);
      expect(find.text('Approved'), findsNothing);
      expect(find.text('Not published'), findsNothing);
    },
  );

  testWidgets(
    'Admin user sees the three moderation tabs',
    (tester) async {
      await _pumpScreen(tester, user: _adminUser);

      // No redirect placeholder.
      expect(find.text('Redirecting…'), findsNothing);
      // All three tabs are visible.
      expect(find.text('Pending review'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Not published'), findsOneWidget);
      // The empty state for the pending tab is shown (the only data
      // tab fully built on first frame).
      expect(find.text('No pending requests'), findsOneWidget);
    },
  );
}
