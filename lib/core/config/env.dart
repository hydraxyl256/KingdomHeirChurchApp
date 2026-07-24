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

  // Google Sign-In — Web OAuth Client ID (from Google Cloud Console).
  // Must match the client configured in Supabase Auth → Providers → Google.
  // Obtain from: console.cloud.google.com → APIs & Services → Credentials
  //              → Web application OAuth 2.0 Client.
  // Injected at build time via: --dart-define=GOOGLE_WEB_CLIENT_ID=<value>
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '256630981662-t2h8g129vrdrk7vj2c39itoqnn6gehdl.apps.googleusercontent.com',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue:
        'https://68fdf02e00592149ace23ef579e9f07b@o4510588022226944.ingest.de.sentry.io/4511545273942096',
  );

  // static const String stripePublishableKey = String.fromEnvironment(
  //   'STRIPE_PUBLISHABLE_KEY',
  // );

  // YouVersion Platform API key — obtained from platform.youversion.com
  // Injected at build time via: --dart-define=YOU_VERSION_KEY=<your_key>
  //
  // **Default is intentionally empty.** The previous default was a
  // hard-coded key that api.youversion.com has been rejecting with
  // 403 Forbidden — every chapter open in production failed until
  // the user rebuilt with a real key. An empty default means the
  // app still builds (handy for CI), but every Bible request fails
  // loud with the 403 → `Unable to load this chapter` UI instead of
  // silently rendering broken pages. See BIBLE_API_AUDIT.md.
  static const String youVersionKey = String.fromEnvironment(
    'YOU_VERSION_KEY',
  );

  static const String biblePreferredVersionIds = String.fromEnvironment(
    'BIBLE_PREFERRED_VERSION_IDS',
  );

  static const int bibleFallbackVersionId = int.fromEnvironment(
    'BIBLE_FALLBACK_VERSION_ID',
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
