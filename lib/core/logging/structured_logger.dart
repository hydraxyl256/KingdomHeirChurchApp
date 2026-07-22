import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Provides structured JSON logging for production observability.
class StructuredLogger {
  const StructuredLogger();

  static void logEvent(Map<String, dynamic> payload) {
    final jsonString = jsonEncode(payload);
    if (kDebugMode) {
      developer.log(jsonString, name: 'Runtime');
    } else {
      // In release, print goes to standard output (logcat / os_log) 
      // where datadog/crashlytics or log aggregators can parse JSON.
      // ignore: avoid_print
      print(jsonString);
    }
  }

  static void cacheHit({
    required String feature,
    required String repository,
    required String cacheAge,
  }) {
    logEvent({
      'event': 'cache_hit',
      'feature': feature,
      'repository': repository,
      'age': cacheAge,
    });
  }

  static void cacheMiss({
    required String feature,
    required String repository,
  }) {
    logEvent({
      'event': 'cache_miss',
      'feature': feature,
      'repository': repository,
    });
  }

  static void cacheWrite({
    required String feature,
    required String repository,
  }) {
    logEvent({
      'event': 'cache_write',
      'feature': feature,
      'repository': repository,
    });
  }

  static void cacheInvalidated({
    required String feature,
    required String repository,
    String? key,
  }) {
    logEvent({
      'event': 'cache_invalidated',
      'feature': feature,
      'repository': repository,
      if (key != null) 'key': key,
    });
  }

  static void networkRequestStarted({
    required String feature,
    required String repository,
    required String datasource,
  }) {
    logEvent({
      'event': 'network_request_started',
      'feature': feature,
      'repository': repository,
      'datasource': datasource,
    });
  }

  static void networkRequestCompleted({
    required String feature,
    required String repository,
    required String datasource,
    required int durationMs,
  }) {
    logEvent({
      'event': 'network_request_completed',
      'feature': feature,
      'repository': repository,
      'datasource': datasource,
      'duration_ms': durationMs,
      'status': 'success',
    });
  }

  static void networkRequestFailed({
    required String feature,
    required String repository,
    required String datasource,
    required int durationMs,
    required String errorType,
  }) {
    logEvent({
      'event': 'network_request_failed',
      'feature': feature,
      'repository': repository,
      'datasource': datasource,
      'duration_ms': durationMs,
      'status': 'failed',
      'error_type': errorType,
    });
  }

  static void parsingFailed({
    required String feature,
    required String repository,
    required String error,
  }) {
    logEvent({
      'event': 'parsing_failed',
      'feature': feature,
      'repository': repository,
      'status': 'error',
      'error': error,
    });
  }
}
