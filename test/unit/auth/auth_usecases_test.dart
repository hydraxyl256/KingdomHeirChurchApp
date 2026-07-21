import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';
import 'package:kingdom_heir/features/auth/domain/repositories/auth_repository.dart';
import 'package:kingdom_heir/features/auth/domain/usecases/auth_usecases.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SignInUseCase signInUseCase;
  late SignUpUseCase signUpUseCase;
  late SignOutUseCase signOutUseCase;

  const tUser = AppUser(
    id: 'uid-123',
    email: 'test@kingdomheir.app',
    fullName: 'Test User',
    role: UserRole.member,
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    signInUseCase = SignInUseCase(mockRepo);
    signUpUseCase = SignUpUseCase(mockRepo);
    signOutUseCase = SignOutUseCase(mockRepo);
  });

  group('SignInUseCase', () {
    test('should return AppUser on successful sign in', () async {
      // Arrange
      when(
        () => mockRepo.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await signInUseCase(
        const SignInParams(email: 'test@kingdomheir.app', password: 'pass123'),
      );

      // Assert
      expect(result, const Right<Failure, AppUser>(tUser));
      verify(
        () => mockRepo.signInWithEmail(
          email: 'test@kingdomheir.app',
          password: 'pass123',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // Arrange
      const failure = AuthFailure(message: 'Invalid credentials');
      when(
        () => mockRepo.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await signInUseCase(
        const SignInParams(email: 'bad@email.com', password: 'wrong'),
      );

      // Assert
      expect(result, const Left<Failure, AppUser>(failure));
    });
  });

  group('SignUpUseCase', () {
    test('should return AppUser on successful registration', () async {
      when(
        () => mockRepo.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await signUpUseCase(
        const SignUpParams(
          email: 'new@kingdomheir.app',
          password: 'secure123',
          fullName: 'New Member',
        ),
      );

      expect(result, const Right<Failure, AppUser>(tUser));
    });
  });

  group('SignOutUseCase', () {
    test('should return unit on successful sign out', () async {
      when(() => mockRepo.signOut()).thenAnswer((_) async => const Right(unit));

      final result = await signOutUseCase();

      expect(result, const Right<Failure, Unit>(unit));
    });
  });
}
