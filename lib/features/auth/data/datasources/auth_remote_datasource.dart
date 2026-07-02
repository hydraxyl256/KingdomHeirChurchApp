import 'package:google_sign_in/google_sign_in.dart';
import 'package:kingdom_heir/core/auth/deep_links.dart';
import 'package:kingdom_heir/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for all Supabase auth operations.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

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
      emailRedirectTo: DeepLinks.verifyEmailUrl(),
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

  Future<UserModel> signInWithGoogle() async {
    try {
      // The Web Client ID required for Supabase OAuth with Google Sign-In.
      // Configure via dart-define or update this constant directly.
      const webClientId = String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
      );

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in cancelled by user.');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthException('Missing Google ID Token.');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Failed to sign in with Supabase.');
      }

      await _ensureProfileForCurrentUser();

      return _fetchProfile(user);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }


  Future<void> signOut() => _client.auth.signOut();

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(
        email,
        redirectTo: DeepLinks.resetPasswordUrl(),
      );

  /// Resends the email-verification message. Returns silently on success
  /// so the caller can drive UI feedback. Throws [AuthException] on
  /// failure (rate-limit, offline, etc.).
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.email,
        email: email,
        emailRedirectTo: DeepLinks.verifyEmailUrl(),
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

  // ── Private ────────────────────────────────────────────────────────────

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

  /// Creates a minimal profile for first-time OAuth users.
  Future<void> _ensureProfileForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final existing = await _client
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    if (existing == null) {
      final meta = user.userMetadata ?? {};
      await _client.from('profiles').upsert({
        'id': user.id,
        'email': user.email ?? '',
        'full_name': meta['full_name'] ?? meta['name'] ?? 'Member',
        'avatar_url': meta['avatar_url'] ?? meta['picture'],
        'role': 'member',
      });
    }
  }
}
