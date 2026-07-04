import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/analytics/analytics_service.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/notifications/push_notification_service.dart';
import 'package:kingdom_heir/core/storage/local_storage_service.dart';
import 'package:kingdom_heir/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kingdom_heir/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';
import 'package:kingdom_heir/features/auth/domain/repositories/auth_repository.dart';
import 'package:kingdom_heir/features/auth/domain/usecases/auth_usecases.dart';

// ─────────────────────────────────────────────
// Data Source
// ─────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(supabaseClientProvider));
});

// ─────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// ─────────────────────────────────────────────
// Use Cases
// ─────────────────────────────────────────────

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

// ─────────────────────────────────────────────
// Auth State Stream
// ─────────────────────────────────────────────

/// Streams the current [AppUser?]. null = signed out.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
});

/// Convenience provider — nullable current user.
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// ─────────────────────────────────────────────
// Auth Notifier (Sign In / Up / Out / Change Password)
// ─────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(signInUseCaseProvider).call(
          SignInParams(email: email, password: password),
        );
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) {
        unawaited(ref.read(analyticsServiceProvider).setUserId(user.id));
        unawaited(ref.read(analyticsServiceProvider).logLogin(method: 'email'));
        unawaited(ref.read(pushNotificationServiceProvider).syncToken());
        return const AsyncData(null);
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(signUpUseCaseProvider).call(
          SignUpParams(email: email, password: password, fullName: fullName),
        );
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) {
        unawaited(ref.read(analyticsServiceProvider).setUserId(user.id));
        unawaited(
          ref.read(analyticsServiceProvider).logRegistration(method: 'email'),
        );
        unawaited(ref.read(pushNotificationServiceProvider).syncToken());
        return const AsyncData(null);
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      // 1. Remove FCM token from Supabase + the device.
      //    Must be called BEFORE signOut — we still need an authenticated
      //    client to reach the Supabase push_subscriptions table.
      try {
        await ref.read(pushNotificationServiceProvider).removeToken();
      } catch (_) {
        // Tolerate FCM failure — the session must still be invalidated.
      }

      // 2. Invalidate the Supabase session server-side.
      //    auth_remote_datasource.dart uses SignOutScope.global which revokes
      //    the refresh token on Supabase's servers, preventing session
      //    restoration after app restart.  This is the primary security action
      //    and must NOT be swallowed.
      await ref.read(signOutUseCaseProvider).call();

      // 3. Wipe account-scoped local preferences.
      //    Theme and currency are NOT cleared — they are not account-specific.
      final storage = ref.read(localStorageServiceProvider);
      await Future.wait([
        storage.remove(LocalStorageKeys.userRole),
        storage.remove(LocalStorageKeys.pendingVerificationEmail),
        storage.remove(LocalStorageKeys.lastSeenNotification),
        storage.remove(LocalStorageKeys.onboardingComplete),
        storage.remove('more_favorites_v1'),
      ]);

      // 4. Reset analytics identity.
      unawaited(ref.read(analyticsServiceProvider).setUserId(null));

      // 5. Do NOT call ref.invalidate(authStateProvider).
      //    The onAuthStateChange stream naturally emits null after the Supabase
      //    sign-out is confirmed, which triggers GoRouter's redirect guard.
      //    Invalidating forces the StreamProvider to re-subscribe immediately,
      //    before Supabase confirms the logout, creating a race condition where
      //    the old cached session value can briefly flash the authenticated UI.

      state = const AsyncData(null);
    } catch (e, st) {
      // Sign-out failed — propagate so the UI can warn the user.
      // The user remains signed in (safe-fail behaviour).
      state = AsyncError(e, st);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    final result = await ref.read(resetPasswordUseCaseProvider).call(email);
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  /// Update password (used from the Reset Password screen after the user
  /// clicks the deep-link from the password-reset email).
  Future<void> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRemoteDataSourceProvider).updatePassword(newPassword);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Change password — re-authenticates with [currentPassword] first so we
  /// verify the user owns the account, then applies [newPassword].
  /// Used by ChangePasswordScreen.
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).changePassword(
          email: email,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  /// Sign in with Google OAuth (Supabase ID-token flow).
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRemoteDataSourceProvider).signInWithGoogle();

      final user = ref.read(currentUserProvider);
      if (user != null) {
        unawaited(ref.read(analyticsServiceProvider).setUserId(user.id));
        unawaited(
          ref.read(analyticsServiceProvider).logLogin(method: 'google'),
        );
        unawaited(ref.read(pushNotificationServiceProvider).syncToken());
      }
      state = const AsyncData(null);
    } on GoogleAuthCancelledException {
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
