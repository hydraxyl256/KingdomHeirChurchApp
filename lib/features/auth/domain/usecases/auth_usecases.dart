import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/core/usecases/usecase.dart';
import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';
import 'package:kingdom_heir/features/auth/domain/repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sign In
// ─────────────────────────────────────────────────────────────────────────────

class SignInParams {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;
}

class SignInUseCase implements UseCase<AppUser, SignInParams> {
  const SignInUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(SignInParams params) =>
      _repository.signInWithEmail(
        email: params.email,
        password: params.password,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign Up
// ─────────────────────────────────────────────────────────────────────────────

class SignUpParams {
  const SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
  });
  final String email;
  final String password;
  final String fullName;
}

class SignUpUseCase implements UseCase<AppUser, SignUpParams> {
  const SignUpUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(SignUpParams params) =>
      _repository.signUpWithEmail(
        email: params.email,
        password: params.password,
        fullName: params.fullName,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign Out
// ─────────────────────────────────────────────────────────────────────────────

class SignOutUseCase implements UseCaseNoParams<Unit> {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call() => _repository.signOut();
}

// ─────────────────────────────────────────────────────────────────────────────
// Reset Password
// ─────────────────────────────────────────────────────────────────────────────

class ResetPasswordUseCase implements UseCase<Unit, String> {
  const ResetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.resetPassword(email);
}
