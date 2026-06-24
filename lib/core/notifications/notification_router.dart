import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class NotificationRouter {
  /// The global navigator key must be set in your MaterialApp.router configuration
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Parses the data payload from FCM and navigates to the appropriate screen.
  static void handleNotificationTap(Map<String, dynamic> data) {
    final logger = Logger(printer: PrettyPrinter(methodCount: 0))
      ..d('Handling deep link from notification payload: $data');

    if (data.isEmpty) return;

    final type = data['type'] as String?;
    final id = data['id'] as String?;

    if (type == null) return;

    final context = navigatorKey.currentContext;
    if (context == null) {
      logger.w('Navigator context is null. Cannot deep link.');
      return;
    }

    try {
      switch (type) {
        case 'sermon':
          if (id != null) {
            context.pushNamed('sermonPlayer', pathParameters: {'id': id});
          } else {
            context.goNamed('sermons');
          }
        case 'devotional':
          if (id != null) {
            context.pushNamed('devotionalDetails', pathParameters: {'id': id});
          } else {
            context.goNamed('dashboard');
          }
        case 'event':
          if (id != null) {
            context.pushNamed('eventDetails', pathParameters: {'id': id});
          } else {
            context.goNamed('events');
          }
        case 'prayer':
          if (id != null) {
            context.pushNamed('prayerDetails', pathParameters: {'id': id});
          } else {
            context.goNamed('prayer');
          }
        case 'announcement':
          // Can pop up a dialog or navigate to announcements feed
          context.goNamed('dashboard');
        case 'giving':
          context.goNamed('giving');
        default:
          logger.w('Unknown notification type: $type');
      }
    } catch (e) {
      logger.e('Error navigating from notification: $e');
    }
  }
}
