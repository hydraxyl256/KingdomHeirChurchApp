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

/// Manual override that the signout flow sets to null to immediately
/// trip the redirect logic, even before the Supabase auth-state stream
/// catches up.
///
/// Read order:
///   1. If [_signedOutOverrideProvider] is set, use that (signout is in progress
///      or has just completed).
///   2. Otherwise, fall through to the live [authStateProvider] stream.
final currentUserProvider = Provider<AppUser?>((ref) {
  // The override wins while it is non-null. We re-read on every
  // dependency change so a signout flips the user to null synchronously
  // even if the Supabase stream is mid-emission.
  final override = ref.watch(_signedOutOverrideProvider);
  if (override != null) return override;
  return ref.watch(authStateProvider).valueOrNull;
});

/// State controller that the signout flow sets to `null` to immediately
/// trip the redirect logic, even before the Supabase auth-state stream
/// catches up.
final _signedOutOverrideProvider = StateProvider<AppUser?>((ref) => null);

// ─────────────────────────────────────────────
// Auth Notifier (Sign In / Up / Out actions)
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
        // Clear any leftover signed-out override from a previous
        // session so the live auth stream takes over again.
        ref.read(_signedOutOverrideProvider.notifier).state = null;
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
        // Clear any leftover signed-out override from a previous
        // session so the live auth stream takes over again.
        ref.read(_signedOutOverrideProvider.notifier).state = null;
        unawaited(ref.read(analyticsServiceProvider).setUserId(user.id));
        unawaited(ref.read(analyticsServiceProvider).logRegistration(method: 'email'));
        unawaited(ref.read(pushNotificationServiceProvider).syncToken());
        return const AsyncData(null);
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      // 1. Stamp `null` synchronously so the router's redirect logic
      //    fires the moment the user confirms signout. We don't wait
      //    for the Supabase auth-state stream to propagate — that
      //    can take a tick, and the user must not be left on the
      //    authenticated settings page for a single frame longer
      //    than necessary.
      ref.read(_signedOutOverrideProvider.notifier).state = null;

      // 2. Remove FCM token from Supabase + the local device BEFORE
      //    signing out — once we're signed out we lose the auth
      //    context that lets the user_devices row be deleted.
      await ref.read(pushNotificationServiceProvider).removeToken();

      // 3. Sign out of Supabase. Wrapped in try so a network failure
      //    doesn't strand the user — we still want to wipe local
      //    state below.
      try {
        await ref.read(signOutUseCaseProvider).call();
      } catch (_) {
        // Ignore — local cleanup is still required.
      }

      // 4. Wipe non-essential local preferences. Keep keys that the
      //    auth/redirect flow needs to make a sensible decision
      //    (onboarding-complete, user-role) so the user lands in the
      //    correct post-logout state instead of being forced back
      //    through onboarding.
      final storage = ref.read(localStorageServiceProvider);
      await storage.remove(LocalStorageKeys.selectedTheme);
      await storage.remove(LocalStorageKeys.selectedLocale);
      await storage.remove(LocalStorageKeys.selectedCurrency);
      await storage.remove(LocalStorageKeys.lastSeenNotification);
      await storage.remove('more_favorites_v1');

      // 5. Invalidate the upstream auth state provider so the next
      //    time the user signs in, a fresh stream is set up.
      ref.invalidate(authStateProvider);

      // 6. Reset analytics identity.
      unawaited(ref.read(analyticsServiceProvider).setUserId(null));

      state = const AsyncData(null);
    } catch (e, st) {
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

  /// Update password (used from the Reset Password screen after
  /// clicking the deep-link from the email).
  Future<void> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRemoteDataSourceProvider).updatePassword(newPassword);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Sign in with Google OAuth (Supabase OAuth flow).
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRemoteDataSourceProvider).signInWithGoogle();
      // Clear the signed-out override so the live auth stream wins.
      ref.read(_signedOutOverrideProvider.notifier).state = null;
      final user = ref.read(currentUserProvider);
      if (user != null) {
        unawaited(ref.read(analyticsServiceProvider).setUserId(user.id));
        unawaited(ref.read(analyticsServiceProvider).logLogin(method: 'google'));
        unawaited(ref.read(pushNotificationServiceProvider).syncToken());
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
