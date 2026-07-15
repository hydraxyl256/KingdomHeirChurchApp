/// Kingdom Heir — Environment configuration reader.
/// All values are injected at build time via --dart-define-from-file.
/// Hardcoded defaults allow the app to run in development without dart-define flags.
abstract final class Env {
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'development',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Kingdom Heir',
  );

  // Supabase — default values allow development builds without dart-define flags
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://spmkdnnyepvdxsrlccnq.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwbWtkbm55ZXB2ZHhzcmxjY25xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMzA1MzMsImV4cCI6MjA5NjcwNjUzM30'
        '.y2buTHSDPTBNSvKWSOYZjCW764IqWDEmyrAfri7Vlog',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue:
        'https://68fdf02e00592149ace23ef579e9f07b@o4510588022226944.ingest.de.sentry.io/4511545273942096',
  );

  // static const String stripePublishableKey = String.fromEnvironment(
  //   'STRIPE_PUBLISHABLE_KEY',
  // );

  static const String apiBibleKey = String.fromEnvironment(
    'YOU_VERSION_KEY',
    defaultValue: '490kxH8f7HvmTZuMvG4c1Fnec6ARpWAr9gE6atPAvBnwJTNa',
  );

  // NOTE: In production, secret keys should be kept in your Supabase backend (.env)
  // and not exposed in the Flutter app. These are provided here for local/admin testing.
  // static const String paystackSecretKey = String.fromEnvironment(
  //   'PAYSTACK_SECRET_KEY',
  // );

  // static const String flutterwaveSecretHash = String.fromEnvironment(
  //   'FLUTTERWAVE_SECRET_HASH',
  // );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
  );

  static bool get isDevelopment => flavor == 'development';
  static bool get isStaging => flavor == 'staging';
  static bool get isProduction => flavor == 'production';

  /// Validates that all required env vars are present.
  /// Call this in bootstrap.dart before any app code runs.
  static void validate() {
    assert(supabaseUrl.isNotEmpty, 'SUPABASE_URL must be set via dart-define');
    assert(
      supabaseAnonKey.isNotEmpty,
      'SUPABASE_ANON_KEY must be set via dart-define',
    );
  }
}
