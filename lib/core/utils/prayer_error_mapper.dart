// Kingdom Heir — Prayer error mapper
//
// Centralized mapper that turns Supabase / PostgREST / RPC exceptions into
// safe, user-facing copy. Never expose raw Postgres or PostgREST text in the
// UI — the spec demands a polished member + admin experience.
//
// Three audiences:
//   * mapSupabaseError       — generic, neutral copy
//   * mapErrorForMember      — pastoral, member-facing copy
//   * mapErrorForAdmin       — direct, admin-facing copy
//
// All three are pure functions and never throw.
//
// When the repository lifts a custom RPC error (e.g. 'not_authorized') it
// throws [PrayerRpcError]. The mapper recognizes the code and returns the
// matching copy.

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Generic → user-facing message. Returns a safe string for any input.
String mapSupabaseError(Object error) {
  if (error is supabase.PostgrestException) {
    return _mapPostgrest(error);
  }
  if (error is supabase.AuthException) {
    return _mapAuth(error);
  }
  if (error is supabase.StorageException) {
    return 'We could not upload that file. Please try again.';
  }
  if (error is PrayerRpcError) {
    return _mapRpcError(error.code);
  }
  if (error is FormatException) {
    return 'We could not read the server response. Please try again.';
  }
  if (error is PrayerNetworkError) {
    return 'We could not reach the server. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}

/// Member-facing copy. Warmer, pastoral tone.
String mapErrorForMember(Object error) {
  final raw = error.toString().toLowerCase();
  if (raw.contains('not_authenticated') || raw.contains('not logged in')) {
    return 'Please sign in to continue.';
  }
  if (raw.contains('not_authorized')) {
    return "You don't have permission to perform this action.";
  }
  if (raw.contains('invalid_state')) {
    return 'This prayer request is no longer pending review.';
  }
  if (raw.contains('network') || raw.contains('socket')) {
    return "We couldn't reach the server. Please try again.";
  }
  if (raw.contains('23505')) {
    return "You've already submitted an identical request. Please wait.";
  }
  return mapSupabaseError(error);
}

/// Admin-facing copy. Direct, includes the actionable state.
String mapErrorForAdmin(Object error) {
  final raw = error.toString().toLowerCase();
  if (raw.contains('not_authorized') || raw.contains('not_admin')) {
    return 'You do not have admin permissions for this action.';
  }
  if (raw.contains('not_authenticated')) {
    return 'Your admin session expired. Please sign in again.';
  }
  if (raw.contains('invalid_state')) {
    return 'This request has already been moderated.';
  }
  if (raw.contains('network') ||
      raw.contains('socket') ||
      raw.contains('timeout')) {
    return 'Server unreachable. Check your connection and try again.';
  }
  return mapSupabaseError(error);
}

// ─── private ───────────────────────────────────────────────────────────────

String _mapPostgrest(supabase.PostgrestException e) {
  // PostgREST/Postgres error codes carry machine-readable meaning.
  switch (e.code) {
    case '23505':
      return "You've already submitted an identical request. Please wait.";
    case '23514':
      return 'Please check your input and try again.';
    case '23503':
      return "We couldn't link this to your account. Please refresh and try again.";
    case '42501':
      return "You don't have permission to perform this action.";
    case 'PGRST116':
      return 'We couldn\'t find that request.';
    case 'PGRST301':
      return 'The server is taking too long. Please try again.';
    default:
      // If the message is a friendly custom error we set from an RPC, surface it.
      final msg = e.message;
      if (msg.isNotEmpty && msg.length < 120 && !msg.contains('postgres')) {
        return msg;
      }
      return 'Something went wrong. Please try again.';
  }
}

String _mapAuth(supabase.AuthException e) {
  // Supabase's AuthException.statusCode is a String (or null). Compare
  // against the textual codes that mean "auth challenge" and "denied"
  // rather than treating it as an int.
  final code = e.statusCode;
  if (code == '401' || code == '403') {
    return code == '401'
        ? 'Please sign in to continue.'
        : "You don't have permission to perform this action.";
  }
  if (code != null && (code.startsWith('5') || code == 'PGRST301')) {
    return "We couldn't reach the server. Please try again.";
  }
  return 'Please sign in to continue.';
}

String _mapRpcError(String code) {
  switch (code) {
    case 'not_authenticated':
      return 'Please sign in to continue.';
    case 'not_authorized':
      return 'You don\'t have permission to perform this action.';
    case 'invalid_state':
      return 'This prayer request is no longer pending review.';
    case 'not_found':
      return 'We couldn\'t find that request.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

/// Lifted from an RPC's custom exception. The [code] is one of the
/// stable strings the SQL functions raise ('not_authenticated',
/// 'not_authorized', 'invalid_state', 'not_found').
class PrayerRpcError implements Exception {
  PrayerRpcError(this.code, [this.message]);
  final String code;
  final String? message;
  @override
  String toString() => 'PrayerRpcError($code)';
}

/// Raised when a low-level socket / DNS / timeout failure occurs.
class PrayerNetworkError implements Exception {
  PrayerNetworkError([this.cause]);
  final Object? cause;
  @override
  String toString() => 'PrayerNetworkError';
}
