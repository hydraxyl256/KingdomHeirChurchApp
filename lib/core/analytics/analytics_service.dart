import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref);
});

class AnalyticsService {
  AnalyticsService(this._ref);

  final Ref _ref;
  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  Map<String, Object>? _globalParams;

  Future<void> _initGlobalParams() async {
    if (_globalParams != null) return;

    final platform = kIsWeb ? 'web' : Platform.operatingSystem;
    var appVersion = '1.0.0';
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = info.version;
    } catch (_) {}

    final prefs = _ref.read(sharedPreferencesProvider);
    final language = prefs.getString('user_language') ?? 'en';
    final country = prefs.getString('user_country') ?? 'Unknown';

    _globalParams = {
      'platform': platform,
      'appVersion': appVersion,
      'language': language,
      'country': country,
    };
  }

  Future<void> _logEvent(String name, [Map<String, Object>? parameters]) async {
    if (Firebase.apps.isEmpty) return;
    await _initGlobalParams();

    final finalParams = <String, Object>{};
    if (_globalParams != null) finalParams.addAll(_globalParams!);

    final user = _ref.read(supabaseClientProvider).auth.currentUser;
    if (user != null) {
      finalParams['userId'] = user.id;
    }

    if (parameters != null) {
      finalParams.addAll(parameters);
    }

    if (kDebugMode) {
      _logger.d('Analytics Event: $name | Params: $finalParams');
    }

    try {
      await _analytics.logEvent(name: name, parameters: finalParams);
    } catch (e) {
      if (kDebugMode) _logger.w('Failed to log event to Firebase: $e');
    }
  }

  Future<void> setUserId(String? userId) async {
    if (Firebase.apps.isEmpty) return;
    await _analytics.setUserId(id: userId);
    if (kDebugMode) {
      _logger.d('Analytics User ID set to: $userId');
    }
  }

  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
    await _logEvent('user_login', {'method': method});
  }

  Future<void> logRegistration({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
    await _logEvent('user_registration', {'method': method});
  }

  Future<void> logSermonPlay(
      {required String sermonId, required String title,}) async {
    await _logEvent('sermon_play', {
      'sermon_id': sermonId,
      'title': title,
    });
  }

  Future<void> logSermonCompleted(
      {required String sermonId, required int watchDuration,}) async {
    await _logEvent('sermon_completed', {
      'sermon_id': sermonId,
      'watch_duration': watchDuration,
    });

    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('sermon_analytics').insert({
          'user_id': user.id,
          'sermon_id': sermonId,
          'watch_duration': watchDuration,
          'completed': true,
        });
      }
    } catch (e) {
      _logger.w('Failed to log sermon analytics to Supabase: $e');
    }
  }

  Future<void> logDevotionalRead(
      {required String devotionalId, required String title,}) async {
    await _logEvent('devotional_read', {
      'devotional_id': devotionalId,
      'title': title,
    });
  }

  Future<void> logDevotionalCompleted(
      {required String devotionalId, required int readingDuration,}) async {
    await _logEvent('devotional_completed', {
      'devotional_id': devotionalId,
      'reading_duration': readingDuration,
    });

    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('devotional_analytics').insert({
          'user_id': user.id,
          'devotional_id': devotionalId,
          'reading_duration': readingDuration,
          'completed': true,
        });
      }
    } catch (e) {
      _logger.w('Failed to log devotional analytics to Supabase: $e');
    }
  }

  Future<void> logDonationStarted(
      {required double amount,
      required String fund,
      required String paymentMethod,}) async {
    await _logEvent('donation_started', {
      'amount': amount,
      'fund': fund,
      'payment_method': paymentMethod,
    });
  }

  Future<void> logDonationCompleted(
      {required double amount,
      required String fund,
      required String paymentMethod,}) async {
    await _logEvent('donation_completed', {
      'amount': amount,
      'fund': fund,
      'payment_method': paymentMethod,
    });
  }

  Future<void> logPrayerSubmitted(
      {required String category, required String visibility,}) async {
    await _logEvent('prayer_submitted', {
      'category': category,
      'visibility': visibility,
    });
  }

  Future<void> logEventRegistration(
      {required String eventId,
      required String title,
      required String rsvpStatus,}) async {
    await _logEvent('event_registration', {
      'event_id': eventId,
      'title': title,
      'status': rsvpStatus,
    });
  }

  Future<void> logAppInstalled() async {
    await _initGlobalParams();
    await _logEvent('app_installed');

    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;

      var deviceId = 'unknown';
      if (!kIsWeb) {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          deviceId = (await deviceInfo.androidInfo).id;
        } else if (Platform.isIOS) {
          deviceId =
              (await deviceInfo.iosInfo).identifierForVendor ?? 'unknown';
        }
      }

      await supabase.from('app_installations').upsert(
        {
          'user_id': user?.id,
          'device_id': deviceId,
          'platform': _globalParams!['platform'],
          'app_version': _globalParams!['appVersion'],
          'country': _globalParams!['country'],
          'language': _globalParams!['language'],
        },
        onConflict: 'device_id',
      );
    } catch (e) {
      _logger.w('Failed to log app installation to Supabase: $e');
    }
  }

  Future<void> logAppOpened() async {
    await _logEvent('app_opened');
  }

  Future<void> logTestimonySubmitted() async {
    await _logEvent('testimony_submitted');
  }

  Future<void> logVolunteerRegistered() async {
    await _logEvent('volunteer_registered');
  }
}
