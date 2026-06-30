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

/// Convenience: get the current user synchronously (from cached stream).
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

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
        unawaited(ref.read(analyticsServiceProvider).logRegistration(method: 'email'));
        unawaited(ref.read(pushNotificationServiceProvider).syncToken());
        return const AsyncData(null);
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      // 1. Remove FCM token from Supabase + the local device BEFORE
      //    signing out — once we're signed out we lose the auth
      //    context that lets the user_devices row be deleted.
      await ref.read(pushNotificationServiceProvider).removeToken();

      // 2. Sign out of Supabase. Wrapped in try so a network failure
      //    doesn't strand the user — we still want to wipe local
      //    state below.
      try {
        await ref.read(signOutUseCaseProvider).call();
      } catch (_) {
        // Ignore — local cleanup is still required.
      }

      // 3. Wipe non-essential local preferences. Keep keys that the
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

      // 4. Invalidate all auth-dependent providers so every Consumer
      //    rebuilds in the signed-out state. The auth stream will
      //    also fire with null shortly, but invalidating here lets us
      //    reset the UI synchronously rather than waiting on the
      //    Supabase auth event.
      ref
        ..invalidate(authStateProvider)
        ..invalidate(currentUserProvider);

      // 5. Reset analytics identity.
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
