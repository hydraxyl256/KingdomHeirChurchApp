import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';

/// Contract for the auth repository — domain layer only.
abstract class AuthRepository {
  /// Stream of the current auth state (null = signed out).
  Stream<AppUser?> watchAuthState();

  /// Returns the currently signed-in user, or null.
  Future<Either<Failure, AppUser?>> getCurrentUser();

  /// Sign in with email and password.
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register with email and password.
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign in with Google (native Android ID-token flow).
  /// Returns the authenticated [AppUser] on success.
  Future<Either<Failure, AppUser>> signInWithGoogle();

  /// Sign out the current user.
  Future<Either<Failure, Unit>> signOut();

  /// Send a password reset email.
  Future<Either<Failure, Unit>> resetPassword(String email);

  /// Update the user's profile in the database.
  Future<Either<Failure, AppUser>> updateProfile(AppUser user);

  /// Re-authenticate then change password.
  /// [currentPassword] is verified first; then [newPassword] is applied.
  Future<Either<Failure, Unit>> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  });

  /// Returns the Supabase auth provider for the current user
  /// (e.g. 'google', 'email').  Used to detect OAuth-only accounts.
  String get currentAuthProvider;
}
