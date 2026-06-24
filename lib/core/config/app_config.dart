import 'package:kingdom_heir/core/config/env.dart';

/// Flavor-aware application configuration model.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.sentryDsn,
    required this.stripePublishableKey,
    required this.enableAnalytics,
    required this.enableCrashReporting,
  });

  factory AppConfig.fromEnv() => const AppConfig(
        flavor: Env.flavor,
        appName: Env.appName,
        supabaseUrl: Env.supabaseUrl,
        supabaseAnonKey: Env.supabaseAnonKey,
        sentryDsn: Env.sentryDsn,
        stripePublishableKey: Env.stripePublishableKey,
        enableAnalytics: Env.enableAnalytics,
        enableCrashReporting: Env.enableCrashReporting,
      );

  final String flavor;
  final String appName;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String sentryDsn;
  final String stripePublishableKey;
  final bool enableAnalytics;
  final bool enableCrashReporting;

  bool get isDevelopment => flavor == 'development';
  bool get isStaging => flavor == 'staging';
  bool get isProduction => flavor == 'production';
}
