import 'dart:developer' as dev;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kingdom_heir/core/auth/deep_links.dart';
import 'package:kingdom_heir/core/config/env.dart';
import 'package:kingdom_heir/core/error/error_handler.dart';
import 'package:kingdom_heir/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for all Supabase auth operations.
///
/// ## Google Sign-In Flow (Production)
///
/// Uses the native Android account picker via the `google_sign_in` package,
/// then exchanges the resulting tokens with Supabase using `signInWithIdToken`.
/// This is the recommended approach for Android (used by YouVersion, Hallow, etc.)
///
/// ⚠️  DO NOT use `signInWithOAuth(OAuthProvider.google)` on Android.
///     That opens a browser redirect and causes DEVELOPER_ERROR (10).
///
/// Prerequisites (must be done in Google Cloud Console + Supabase dashboard):
///   1. Android OAuth client registered with the correct SHA-1 fingerprints.
///   2. Web OAuth client ID set as `Env.googleWebClientId`.
///   3. Supabase Auth → Google provider configured with the Web client ID/secret.
///   4. `google-services.json` re-downloaded after adding OAuth clients.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  // ── Google Sign-In singleton ─────────────────────────────────────────────
  //
  // `serverClientId` is the WEB OAuth client ID (not Android). This causes the
  // native account picker to request an idToken scoped to that web client, which
  // Supabase can then verify server-side via signInWithIdToken.
  //
  // scopes: 'email' and 'profile' give us the name + avatar for profile creation.
  GoogleSignIn get _googleSignIn => GoogleSignIn(
        serverClientId:
            Env.googleWebClientId.isNotEmpty ? Env.googleWebClientId : null,
        scopes: const ['email', 'profile'],
      );

  // ── Auth state ────────────────────────────────────────────────────────────

  /// Stream of Supabase auth state changes mapped to [UserModel].
  Stream<UserModel?> watchAuthState() {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;
      return _fetchProfile(user);
    });
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user);
  }

  // ── Email / Password ──────────────────────────────────────────────────────

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw const AuthException('Sign in failed.');
    return _fetchProfile(user);
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
      // Production redirect — universal link handled by AndroidManifest /
      // Info.plist, then routed into the app via [DeepLinkHandler]. We
      // intentionally use the universal link (not the custom scheme) so
      // the App Links / Universal Links verification flows apply.
      emailRedirectTo: DeepLinks.authCallbackUrl,
    );
    final user = response.user;
    if (user == null) throw const AuthException('Sign up failed.');

    // Attempt to create the profile row.
    // This may fail if the Supabase RLS policy doesn't allow client-side inserts.
    // FIX IN SUPABASE DASHBOARD → Table Editor → profiles → RLS Policies:
    //   Add policy: "Users can insert their own profile"
    //   Operation: INSERT  |  USING: (auth.uid() = id)
    // Until then, we catch the error so the auth user is still created successfully.
    try {
      await _client.from('profiles').upsert({
        'id': user.id,
        'email': email,
        'full_name': fullName,
        'role': 'member',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Profile creation blocked by RLS — user is still authenticated.
      // Profile will be created when the INSERT RLS policy is added in Supabase.
    }

    return _fetchProfile(user);
  }

  // ── Google Sign-In (Native Android flow) ─────────────────────────────────

  /// Authenticates the user with Google using the native account picker,
  /// then exchanges the resulting tokens with Supabase.
  ///
  /// Throws [GoogleAuthCancelledException] if the user dismisses the picker.
  /// Throws [AuthException] with a user-friendly message on all other failures.
  Future<UserModel> signInWithGoogle() async {
    dev.log('[Google Auth] Starting native sign-in flow', name: 'AuthDS');
    if (kDebugMode) {
      dev.log(
        '[Google Auth] Resolved GOOGLE_WEB_CLIENT_ID: '
        '${Env.googleWebClientId}',
        name: 'AuthDS',
      );
    }
    if (Env.googleWebClientId.trim().isEmpty) {
      const error = AuthException(
        'Google sign-in is not configured for this build.',
      );
      _reportGoogleFailure(
        stage: 'configuration',
        error: error,
        stackTrace: StackTrace.current,
      );
      throw error;
    }

    // ── Step 1: Sign out any stale Google session first ───────────────────
    // Prevents the picker from auto-selecting the wrong account when the
    // user has previously signed in with a different Google account.
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Non-fatal — proceed even if signOut fails.
    }

    // ── Step 2: Show native Google account picker ─────────────────────────
    final GoogleSignInAccount? googleAccount;
    try {
      googleAccount = await _googleSignIn.signIn();
    } catch (e, st) {
      _handleGoogleError(e, st, stage: 'native_sign_in');
    }

    if (googleAccount == null) {
      // User tapped the back button / dismissed the picker.
      dev.log('[Google Auth] User cancelled account picker', name: 'AuthDS');
      throw const GoogleAuthCancelledException();
    }

    dev.log(
      '[Google Auth] Account selected: ${googleAccount.email}',
      name: 'AuthDS',
    );

    // ── Step 3: Retrieve Google tokens ────────────────────────────────────
    final GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await googleAccount.authentication;
    } catch (e, st) {
      _handleGoogleError(e, st, stage: 'token_retrieval');
    }

    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    dev.log(
      '[Google Auth] Tokens received — idToken: ${idToken != null}, '
      'accessToken: ${accessToken != null}',
      name: 'AuthDS',
    );

    if (idToken == null) {
      // idToken is null when serverClientId is missing or wrong.
      // See: https://pub.dev/packages/google_sign_in#android
      dev.log(
        '[Google Auth] idToken is null — check that Env.googleWebClientId '
        'matches the Web OAuth client in Google Cloud Console.',
        name: 'AuthDS',
      );
      throw const AuthException(
        'Unable to sign in with Google. '
        'Please try again or use email sign-in.',
      );
    }

    // ── Step 4: Exchange tokens with Supabase ─────────────────────────────
    dev.log('[Google Auth] Calling supabase.signInWithIdToken', name: 'AuthDS');

    final AuthResponse supabaseResponse;
    try {
      supabaseResponse = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } on AuthException catch (e, st) {
      _reportGoogleFailure(
        stage: 'supabase_token_exchange',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      _reportGoogleFailure(
        stage: 'supabase_token_exchange',
        error: e,
        stackTrace: st,
      );
      throw const AuthException(
        'Unable to sign in with Google. '
        'Please try again or contact support if the problem continues.',
      );
    }

    final user = supabaseResponse.user;
    if (user == null) {
      dev.log(
        '[Google Auth] Supabase returned no user after signInWithIdToken',
        name: 'AuthDS',
      );
      throw const AuthException(
        'Unable to complete sign-in. Please try again.',
      );
    }

    dev.log(
      '[Google Auth] Supabase session established for ${user.email}',
      name: 'AuthDS',
    );

    // ── Step 5: Upsert profile ────────────────────────────────────────────
    // For new users: creates the profile row.
    // For returning users: updates display_name + avatar_url if changed.
    // upsert with ignoreDuplicates: false ensures the row is always current.
    await _upsertGoogleProfile(
      user: user,
      googleAccount: googleAccount,
    );

    // ── Step 6: Fetch and return the full profile ─────────────────────────
    dev.log('[Google Auth] Sign-in complete ✓', name: 'AuthDS');
    return _fetchProfile(user);
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    // Also sign out of Google so the account picker shows next time.
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Non-fatal.
    }
    // SignOutScope.global revokes the refresh token on Supabase's server so
    // the session cannot be restored after app restart.  SignOutScope.local
    // (the default) only clears local storage — the token remains valid
    // server-side and supabase_flutter will re-authenticate on next launch.
    await _client.auth.signOut(scope: SignOutScope.global);
  }

  // ── Password / Profile ────────────────────────────────────────────────────

  /// Re-authenticates with email + current password.
  /// Call this before updating the password to verify the user's identity.
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Returns the provider name (e.g. 'google', 'email') from app metadata.
  String get currentAuthProvider =>
      (_client.auth.currentUser?.appMetadata['provider'] as String?) ?? 'email';

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(
        email,
        redirectTo: DeepLinks.authCallbackUrl,
      );

  /// Resends the email-verification message. Returns silently on success
  /// so the caller can drive UI feedback. Throws [AuthException] on
  /// failure (rate-limit, offline, etc.).
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.email,
        email: email,
        emailRedirectTo: DeepLinks.authCallbackUrl,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Could not resend verification email: $e');
    }
  }

  /// Refresh the current session and report whether the email is now
  /// verified. Returns the current user (or null) — callers should
  /// inspect `user.emailConfirmedAt != null` to detect verification.
  Future<User?> refreshVerificationStatus() async {
    final response = await _client.auth.refreshSession();
    return response.session?.user;
  }

  /// Reports whether the currently-cached user has a verified email.
  bool get isCurrentEmailVerified =>
      _client.auth.currentUser?.emailConfirmedAt != null;

  /// Returns the email of the currently-cached user, if any.
  String? get currentEmail => _client.auth.currentUser?.email;

  Future<void> updatePassword(String newPassword) =>
      _client.auth.updateUser(UserAttributes(password: newPassword));

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('profiles').update(data).eq('id', userId);
    return _fetchProfile(_client.auth.currentUser!);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<UserModel> _fetchProfile(User user) async {
    try {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return UserModel.fromSupabaseUser(user, profile);
    } catch (_) {
      return UserModel.fromSupabaseUser(user);
    }
  }

  /// Creates or updates the Supabase `profiles` row for a Google-authenticated user.
  ///
  /// Logic:
  ///   • New user  → full insert (full_name, email, avatar_url, role, timestamps)
  ///   • Returning → updates display_name + avatar_url only (preserves role etc.)
  Future<void> _upsertGoogleProfile({
    required User user,
    required GoogleSignInAccount googleAccount,
  }) async {
    dev.log(
      '[Google Auth] Upserting profile for ${user.email}',
      name: 'AuthDS',
    );

    try {
      // Check whether the profile row already exists.
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      final now = DateTime.now().toUtc().toIso8601String();

      if (existing == null) {
        // ── New Google user: full profile insert ──────────────────────────
        dev.log(
          '[Google Auth] New user — creating profile row',
          name: 'AuthDS',
        );
        await _client.from('profiles').insert({
          'id': user.id,
          'email': user.email ?? googleAccount.email,
          'full_name':
              googleAccount.displayName ?? user.email?.split('@').first,
          'avatar_url': googleAccount.photoUrl,
          'role': 'member',
          'created_at': now,
          'updated_at': now,
          // Optional fields initialised to sensible defaults:
          // 'language': 'en',
          // 'timezone': 'UTC',
          // 'default_theme': 'dark',
        });
        dev.log('[Google Auth] Profile row created ✓', name: 'AuthDS');
      } else {
        // ── Returning user: refresh display name + avatar only ────────────
        dev.log(
          '[Google Auth] Existing user — refreshing display_name + avatar_url',
          name: 'AuthDS',
        );
        await _client.from('profiles').update({
          'full_name': googleAccount.displayName,
          'avatar_url': googleAccount.photoUrl,
          'updated_at': now,
        }).eq('id', user.id);
        dev.log('[Google Auth] Profile refreshed ✓', name: 'AuthDS');
      }
    } catch (e) {
      // Profile upsert failure is non-fatal.
      // The auth session is already established — the user is authenticated.
      // The profile will be present (or stale) until the next sign-in.
      dev.log(
        '[Google Auth] Profile upsert failed (non-fatal): $e',
        name: 'AuthDS',
      );
    }
  }

  /// Translates raw Google / platform exceptions into user-friendly [AuthException]s.
  /// Always throws — the return type is `Never` by convention.
  Never _handleGoogleError(
    Object e,
    StackTrace stackTrace, {
    required String stage,
  }) {
    _reportGoogleFailure(stage: stage, error: e, stackTrace: stackTrace);
    final msg = e.toString().toLowerCase();

    // DEVELOPER_ERROR (10): SHA mismatch or wrong package name.
    if (msg.contains('developer_error') || msg.contains('error code: 10')) {
      throw const AuthException(
        'Google sign-in needs an app configuration update. '
        'Please try again later.',
      );
    }

    // Network / timeout.
    if (msg.contains('network_error') ||
        msg.contains('timeout') ||
        msg.contains('socketexception')) {
      throw const AuthException(
        'No internet connection. Please check your network and try again.',
      );
    }

    // User already signed in with email — account conflict.
    if (msg.contains('already registered') || msg.contains('email already')) {
      throw const AuthException(
        'This email is already registered. Please sign in with email and password.',
      );
    }

    // Catch-all.
    throw const AuthException(
      'Unable to sign in with Google. '
      'Please try again or contact support if the problem continues.',
    );
  }

  void _reportGoogleFailure({
    required String stage,
    required Object error,
    required StackTrace stackTrace,
  }) {
    dev.log(
      '[Google Auth] $stage failed (${error.runtimeType}): $error',
      name: 'AuthDS',
      stackTrace: stackTrace,
    );

    // Preserve the original platform/Supabase exception for release
    // diagnostics while the UI receives only the curated AuthException.
    if (!kDebugMode) ErrorHandler.handle(error, stackTrace);
  }
}

/// Thrown when the user cancels the Google Sign-In native picker.
/// The caller should treat this as a no-op (do not show an error).
class GoogleAuthCancelledException implements Exception {
  const GoogleAuthCancelledException();
}
