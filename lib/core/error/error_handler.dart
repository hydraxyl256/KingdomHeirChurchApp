import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps Supabase and network errors to typed [Failure]s.
class ErrorHandler {
  const ErrorHandler._();

  static Failure handle(Object error, StackTrace stackTrace) {
    if (error is AuthException) {
      return AuthFailure(message: error.message);
    }

    if (error is PostgrestException) {
      return ServerFailure(
        message: error.message,
        code: int.tryParse(error.code ?? ''),
      );
    }

    if (error is StorageException) {
      return ServerFailure(message: error.message);
    }

    if (kDebugMode) {
      debugPrint('Unhandled error: $error\n$stackTrace');
    }

    return UnknownFailure(message: error.toString());
  }

  /// Wraps a future in Either, mapping exceptions to [Failure].
  static Future<Either<Failure, T>> guard<T>(
    Future<T> Function() fn,
  ) async {
    try {
      final result = await fn();
      return Right(result);
    } catch (e, st) {
      return Left(handle(e, st));
    }
  }
}
