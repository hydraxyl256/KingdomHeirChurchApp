import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppProviderObserver extends ProviderObserver {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  @override
  void didAddProvider(ProviderBase<dynamic> provider, Object? value,
      ProviderContainer container,) {
    // _logger.d('ProviderAdded: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<dynamic> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Filter out high-frequency or noisy providers if needed
    final name = provider.name ?? provider.runtimeType.toString();
    if (name.contains('StateProvider') || name.contains('NotifierProvider')) {
      _logger.d('ProviderUpdated: $name\nFrom: $previousValue\nTo: $newValue');
    }
  }

  @override
  void didDisposeProvider(
      ProviderBase<dynamic> provider, ProviderContainer container,) {
    // _logger.d('ProviderDisposed: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void providerDidFail(
    ProviderBase<dynamic> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    final name = provider.name ?? provider.runtimeType.toString();
    _logger.e('ProviderFailed: $name', error: error, stackTrace: stackTrace);

    // Forward to Sentry
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('provider', name);
      },
    );

    // Forward to Crashlytics
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Riverpod Provider Failure: $name',
    );
  }
}
