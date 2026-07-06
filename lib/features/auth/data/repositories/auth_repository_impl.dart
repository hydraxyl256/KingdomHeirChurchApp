import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/error/error_handler.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';
import 'package:kingdom_heir/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository] using Supabase.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AppUser?> watchAuthState() =>
      _remote.watchAuthState().map((model) => model?.toEntity());

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() =>
      ErrorHandler.guard(() async {
        final model = await _remote.getCurrentUser();
        return model?.toEntity();
      });

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) =>
      ErrorHandler.guard(() async {
        final model = await _remote.signInWithEmail(
          email: email,
          password: password,
        );
        return model.toEntity();
      });

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) =>
      ErrorHandler.guard(() async {
        final model = await _remote.signUpWithEmail(
          email: email,
          password: password,
          fullName: fullName,
        );
        return model.toEntity();
      });

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() =>
      ErrorHandler.guard(() async {
        await _remote.signInWithGoogle();
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> signOut() => ErrorHandler.guard(() async {
        await _remote.signOut();
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> resetPassword(String email) =>
      ErrorHandler.guard(() async {
        await _remote.resetPassword(email);
        return unit;
      });

  @override
  Future<Either<Failure, AppUser>> updateProfile(AppUser user) =>
      ErrorHandler.guard(() async {
        final data = {
          'email': user.email,
          'full_name': user.fullName,
          'avatar_url': user.avatarUrl,
          'role': user.role?.name,
          'phone': user.phone,
          'bio': user.bio,
        };
        final updatedModel = await _remote.updateProfile(data);
        return updatedModel.toEntity();
      });

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) =>
      ErrorHandler.guard(() async {
        // Step 1 — verify the current password by re-authenticating.
        // This raises AuthException if the password is wrong.
        await _remote.reauthenticate(email: email, password: currentPassword);

        // Step 2 — update to the new password.
        await _remote.updatePassword(newPassword);
        return unit;
      });

  @override
  String get currentAuthProvider => _remote.currentAuthProvider;
}
