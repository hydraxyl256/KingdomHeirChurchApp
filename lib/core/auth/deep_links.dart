/// Centralised, production-only deep-link + redirect-URL helpers.
///
/// All Supabase email-template redirects, OAuth redirects, and mobile
/// app links MUST route through this class so we can swap a dev domain
/// for production without combing the codebase. There are intentionally
/// no localhost / 127.0.0.1 / 10.0.2.2 references in production code.
///
/// The two URL forms we ship are:
///   • Custom scheme  — kingdomheir://verify, kingdomheir://reset-password,
///     kingdomheir://login-callback. Used as a fallback when the user
///     installs a build before the App Links / Universal Links assets
///     are deployed.
///   • Universal link — https://https://kingdomheirsfoundation.com/<path>. Used
///     in production because the app verifies ownership via
///     .well-known/apple-app-site-association and assetlinks.json.
library;

abstract final class DeepLinks {
  /// The verified production domain. The owner of this domain must
  /// publish:
  ///   • /.well-known/assetlinks.json (Android App Links)
  ///   • /.well-known/apple-app-site-association (iOS Universal Links)
  /// referencing this app's package id + team id, otherwise the OS will
  /// hand the URL to the browser instead of the app.
  static const String _domain = 'https://kingdomheirsfoundation.com';

  /// Custom-scheme host used by GoRouter for the verify screen.
  static const String verifyHost = 'verify';

  /// Custom-scheme host used by GoRouter for the password-reset screen.
  static const String resetPasswordHost = 'reset-password';

  /// Custom-scheme host used by GoRouter for the OAuth callback.
  static const String loginCallbackHost = 'login-callback';

  /// Supabase redirect URL used in the verification-email template.
  static String verifyEmailUrl() =>
      'https://$_domain/verify';

  /// Supabase redirect URL used in the password-reset email template.
  static String resetPasswordUrl() =>
      'https://$_domain/reset-password';

  /// Supabase redirect URL used for Google OAuth.
  static String loginCallbackUrl() =>
      'https://$_domain/login-callback';

  /// Path that GoRouter watches for incoming verification deep links.
  /// Matches both the universal-link form and the custom-scheme form.
  static const String verifyRoute = '/verify';

  /// Path that GoRouter watches for incoming reset-password deep links.
  static const String resetPasswordRoute = '/reset-password';

  /// Path that GoRouter watches for incoming OAuth callbacks.
  /// Path that GoRouter watches for incoming OAuth callbacks.
  static const String loginCallbackRoute = '/login-callback';
}
