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

  Future<void> signOut() => _client.auth.signOut();

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'kingdomheir://reset-password',
      );

  Future<void> updatePassword(String newPassword) =>
      _client.auth.updateUser(UserAttributes(password: newPassword));

  Future<bool> signInWithGoogle() async {
    final result = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'kingdomheir://login-callback',
    );
    if (result) await _ensureProfileForCurrentUser();
    return result;
  }

  Future<bool> signInWithApple() async {
    final result = await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'kingdomheir://login-callback',
    );
    if (result) await _ensureProfileForCurrentUser();
    return result;
  }

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
