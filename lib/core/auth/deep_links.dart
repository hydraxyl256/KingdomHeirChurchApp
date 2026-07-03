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
  /// Supabase callback URL used for email verification, password resets, and OAuth.
  static const String authCallbackUrl = 'kingdomheirs://auth/callback';

  /// Path that GoRouter watches for incoming auth callbacks.
  static const String authCallbackRoute = '/callback';
}
