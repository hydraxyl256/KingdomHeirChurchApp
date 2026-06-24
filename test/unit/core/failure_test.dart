import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/core/error/failure.dart';

void main() {
  group('Failure sealed class', () {
    test('NetworkFailure has correct message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'No internet connection.');
    });

    test('ServerFailure stores code', () {
      const failure = ServerFailure(message: 'Internal error', code: 500);
      expect(failure.code, 500);
      expect(failure.message, 'Internal error');
    });

    test('AuthFailure has correct default message', () {
      const failure = AuthFailure();
      expect(failure.message, 'Authentication failed.');
    });

    test('ValidationFailure stores field name', () {
      const failure = ValidationFailure(message: 'Required', field: 'email');
      expect(failure.field, 'email');
    });

    test('Failures with same props are equal', () {
      const f1 = NetworkFailure();
      const f2 = NetworkFailure();
      expect(f1, equals(f2));
    });

    test('ServerFailure switch works with sealed class', () {
      const Failure failure = ServerFailure(message: 'Not found', code: 404);
      final message = switch (failure) {
        NetworkFailure() => 'network',
        ServerFailure(message: final m) => m,
        AuthFailure() => 'auth',
        ValidationFailure() => 'validation',
        CacheFailure() => 'cache',
        UnknownFailure() => 'unknown',
      };
      expect(message, 'Not found');
    });
  });
}
