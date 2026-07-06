// Kingdom Heir — Forgot Password screen smoke test
//
// Verifies the single-field submission flow renders the email input
// and the Send Reset Link button. The auth repository is stubbed so
// the test never hits Supabase.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart';
import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';
import 'package:kingdom_heir/features/auth/domain/repositories/auth_repository.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stub repository that bypasses Supabase entirely.
class _StubAuthRepository implements AuthRepository {
  const _StubAuthRepository();

  @override
  Stream<AppUser?> watchAuthState() => const Stream.empty();

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async =>
      const Right(null);

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      const Left(AuthFailure());

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async =>
      const Left(AuthFailure());

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async =>
      const Left(AuthFailure());

  @override
  Future<Either<Failure, Unit>> signOut() async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> resetPassword(String email) async =>
      const Right(unit);

  @override
  Future<Either<Failure, AppUser>> updateProfile(AppUser user) async =>
      const Left(AuthFailure());

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async =>
      const Right(unit);

  @override
  String get currentAuthProvider => 'email';
}

void main() {
  testWidgets(
    'Forgot Password screen renders the email field and Send Reset button',
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
            authRepositoryProvider.overrideWithValue(const _StubAuthRepository()),
            // Empty stream so the screen doesn't try to listen to Supabase.
            authStateProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));

      // Title.
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Email field is present.
      expect(find.byType(TextFormField), findsOneWidget);

      // Send button is present.
      expect(find.text('Send Reset Link'), findsOneWidget);
    },
  );
}
