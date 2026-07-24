import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps Supabase and network errors to typed [Failure]s.
class ErrorHandler {
  const ErrorHandler._();

  /// Tracks whether Sentry / Crashlytics are available so we don't
  /// re-call `Firebase.apps.isEmpty` etc. on every error.
  static bool _crashlyticsAvailable = true;

  /// Disable the remote crash reporters (used by unit tests so a
  /// thrown test exception does not pollute the production dashboard).
  static void disableRemoteReportingForTests() {
    _crashlyticsAvailable = false;
  }

  static Failure handle(Object error, StackTrace stackTrace) {
    final failure = _mapToFailure(error, stackTrace);

    // Forward the raw error to Sentry + Crashlytics. We forward the
    // original `error` (not the Failure) so dashboards / alerts
    // see the real exception type and message — including the
    // `PostgrestException(42501, permission denied for table
    // auth.users)` text. The UI still only ever sees the
    // human-readable `failure.message`.
    if (_crashlyticsAvailable && !kDebugMode) {
      _reportToRemote(error, stackTrace);
    } else if (kDebugMode) {
      debugPrint('ErrorHandler: $error\n$stackTrace');
    }

    return failure;
  }

  static Failure _mapToFailure(Object error, StackTrace stackTrace) {
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

    return UnknownFailure(message: error.toString());
  }

  static void _reportToRemote(Object error, StackTrace stackTrace) {
    // Best-effort: never let the reporter itself crash the caller.
    try {
      // Sentry first (synchronous, fast).
      // ignore: deprecated_member_use
      Sentry.captureException(error, stackTrace: stackTrace);
    } catch (_) {/* Sentry unavailable */}
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'ErrorHandler.handle',
      );
    } catch (_) {/* Crashlytics unavailable */}
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
