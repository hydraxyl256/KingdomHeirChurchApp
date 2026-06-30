import 'package:equatable/equatable.dart';

/// Sealed hierarchy of all possible domain failures.
sealed class Failure extends Equatable {
  const Failure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];

  /// Returns just the human-readable message so call-sites that pass a
  /// [Failure] to `AsyncError(failure, …)` and then `state.error.toString()`
  /// surface the real reason (e.g. SnackBar text) instead of the default
  /// `Instance of AuthFailure` placeholder from `Object.toString`.
  @override
  String toString() => message;
}

/// No internet connection or request timed out.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.'});
}

/// Supabase returned a 4xx/5xx error.
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, this.code});
  final int? code;

  @override
  List<Object?> get props => [message, code];
}

/// Auth token missing, expired, or insufficient permissions.
final class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed.'});
}

/// Client-side input validation failed.
final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, this.field});
  final String? field;

  @override
  List<Object?> get props => [message, field];
}

/// Local cache / secure storage error.
final class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Local storage error.'});
}

/// Catch-all for unexpected errors.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred.'});
}
