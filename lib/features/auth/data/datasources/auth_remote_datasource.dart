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

  Future<UserModel> signInWithGoogle() async {
    try {
      const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
      
      if (webClientId.isEmpty || !webClientId.endsWith('.apps.googleusercontent.com')) {
        throw const AuthException('Google sign-in is temporarily unavailable. Please use email and password.');
      }

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        scopes: const ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw GoogleAuthCancelledException();
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Google sign-in could not be completed. Please try again.');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('We could not sign you in with Google. Please try again or use email sign-in.');
      }

      await _ensureProfileForCurrentUser();

      return _fetchProfile(user);
    } on GoogleAuthCancelledException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('Sign_in_failed') || errorStr.contains('DEVELOPER_ERROR') || errorStr.contains('10:')) {
        throw const AuthException('Google sign-in needs an app configuration update. Please try again later.');
      } else if (errorStr.toLowerCase().contains('network') || errorStr.toLowerCase().contains('socket') || errorStr.toLowerCase().contains('connection')) {
        throw const AuthException('Check your internet connection and try again.');
      }
      throw const AuthException('We could not sign you in with Google. Please try again or use email sign-in.');
    }
  }


  Future<void> signOut() => _client.auth.signOut();

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
      final emailName = user.email?.split('@').first;
      
      final fullName = meta['full_name'] as String? ?? 
                       meta['name'] as String? ?? 
                       emailName ?? 
                       'Kingdom Heirs Member';
                       
      final avatarUrl = meta['avatar_url'] as String? ?? 
                        meta['picture'] as String?;

      await _client.from('profiles').insert({
        'id': user.id,
        'email': user.email ?? '',
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': 'member',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}

/// Thrown when the user cancels the Google Sign-In native picker.
class GoogleAuthCancelledException implements Exception {}
