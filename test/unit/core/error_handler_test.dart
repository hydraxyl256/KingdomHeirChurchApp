// Kingdom Heir — ErrorHandler regression test
//
// Pin down that the production `ErrorHandler.handle` correctly maps a
// `PostgrestException(42501, permission denied for table auth.users)`
// into a typed `ServerFailure` whose `toString()` is the friendly
// message — never the raw `PostgrestException(...)` text.

import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/core/error/error_handler.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // `setUpAll` only takes a `VoidCallback`; the closure body is
  // required to perform multiple setup steps, hence the lambda.
  // ignore: unnecessary_lambdas
  setUpAll(() {
    // Tests must never reach Sentry / Crashlytics.
    ErrorHandler.disableRemoteReportingForTests();
  });

  group('ErrorHandler.handle — auth.users permission regression', () {
    test('maps PostgrestException(42501) to ServerFailure', () {
      final failure = ErrorHandler.handle(
        const PostgrestException(
          message: 'permission denied for table auth.users',
          code: '42501',
          details: 'forbidden',
          hint: 'Grant SELECT ON auth.users...',
        ),
        StackTrace.current,
      );

      expect(failure, isA<ServerFailure>());
      expect(failure, isA<Failure>());
    });

    test('failure.toString() does not leak the PostgrestException '
        'class name or the auth.users table name', () {
      final failure = ErrorHandler.handle(
        const PostgrestException(
          message: 'permission denied for table auth.users',
          code: '42501',
          details: 'forbidden',
          hint: 'Grant SELECT ON auth.users...',
        ),
        StackTrace.current,
      );

      // The UI will surface `failure.toString()` via
      // `AppErrorWidget`'s message. It must not contain the raw
      // exception text.
      final text = failure.toString();
      expect(text, isNot(contains('PostgrestException')));
      expect(text, isNot(contains('auth.users')));
      expect(text, isNot(contains('42501')));
    });

    test('preserves the message so the dashboard can log it '
        'for Sentry / Crashlytics', () {
      final failure = ErrorHandler.handle(
        const PostgrestException(
          message: 'permission denied for table auth.users',
          code: '42501',
        ),
        StackTrace.current,
      );

      // The Failure is the one that hits the UI. The original
      // PostgrestException goes to Sentry / Crashlytics via
      // ErrorHandler.handle (which forwards `error`, not
      // `failure`). The Failure's `message` is what the UI sees.
      expect(failure.message, 'permission denied for table auth.users');
    });
  });
}
