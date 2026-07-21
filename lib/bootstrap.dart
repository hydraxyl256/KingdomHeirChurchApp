import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/analytics/analytics_service.dart';
import 'package:kingdom_heir/core/analytics/app_provider_observer.dart';
import 'package:kingdom_heir/core/analytics/presence_service.dart';
import 'package:kingdom_heir/core/config/app_config.dart';
import 'package:kingdom_heir/core/config/env.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/notifications/push_notification_service.dart';
import 'package:kingdom_heir/firebase_options.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initialises all services and returns a configured [ProviderContainer].
Future<ProviderContainer> bootstrap() async {
  // 1. Build config
  final config = AppConfig.fromEnv();

  // 2. Configure logger
  final logger = Logger(
    level: config.isDevelopment ? Level.debug : Level.warning,
  )..i('Kingdom Heir starting in ${config.flavor} mode');

  // 3. Load local storage
  final prefs = await SharedPreferences.getInstance();

  // 4. Initialise Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
    debug: Env.isDevelopment,
  );

  // 5. Initialise Firebase
  try {
    // TODO(kingdom-heir): Replace with Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
    // after running `flutterfire configure`
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    logger.w(
      'Firebase initialization skipped/failed. Ensure flutterfire configure was run: $e',
    );
  }

  // 6. Setup Flutter error handling (Crashlytics + Sentry)
  FlutterError.onError = (details) {
    logger.e(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );

    if (config.enableCrashReporting) {
      // Send to Sentry
      Sentry.captureException(details.exception, stackTrace: details.stack);

      // Send to Crashlytics
      try {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } catch (_) {}
    }
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    if (config.enableCrashReporting) {
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (_) {}
      Sentry.captureException(error, stackTrace: stack);
    }
    return true;
  };

  // 7. Create ProviderContainer
  final container = ProviderContainer(
    observers: [AppProviderObserver()],
    overrides: [
      appConfigProvider.overrideWithValue(config),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // 8. Initialize Push Notifications
  try {
    await container.read(pushNotificationServiceProvider).initialize();
  } catch (e) {
    logger.e('Failed to initialize push notifications: $e');
  }

  // 9. Initialize Presence & Analytics
  try {
    container.read(presenceServiceProvider).initialize();

    // Log app opened event
    await container.read(analyticsServiceProvider).logAppOpened();

    // Check if this is a first install (if not handled natively)
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    if (isFirstLaunch) {
      await container.read(analyticsServiceProvider).logAppInstalled();
      await prefs.setBool('is_first_launch', false);
    }
  } catch (e) {
    logger.e('Failed to initialize analytics: $e');
  }

  // 10. Return container
  return container;
}
