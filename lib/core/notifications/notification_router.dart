import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:logger/logger.dart';

class NotificationRouter {
  /// The global navigator key must be set in your MaterialApp.router configuration
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Parses the data payload from FCM and navigates to the appropriate screen.
  ///
  /// Routes are looked up via [RouteNames] constants and resolved
  /// through GoRouter's path-based `go`/`push` API. We intentionally
  /// avoid `goNamed` / `pushNamed` because none of the routes in
  /// `app_router.dart` define a `name:` parameter — calling those
  /// would throw `GoException: no GoRoute named "sermonPlayer"` on
  /// every notification tap.
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
            // Sermon player lives at /home/sermons/:id/player
            context.push('/home/sermons/$id/player');
          } else {
            context.go(RouteNames.sermons);
          }
        case 'devotional':
          if (id != null) {
            // Devotional reader lives at /home/devotionals/:id/content
            context.push('/home/devotionals/$id/content');
          } else {
            context.go(RouteNames.dashboard);
          }
        case 'event':
          if (id != null) {
            context.push('/home/events/$id');
          } else {
            context.go(RouteNames.events);
          }
        case 'prayer':
          // Prayer has no per-item detail route — drop into the feed
          // either way. If we add one later, fall back to id-based path.
          context.go(RouteNames.prayerFeed);
        case 'announcement':
          // Land on the news feed — announcements live alongside
          // regular news articles.
          context.go(RouteNames.news);
        case 'giving':
          context.go(RouteNames.giving);
        default:
          logger.w('Unknown notification type: $type');
      }
    } catch (e) {
      logger.e('Error navigating from notification: $e');
    }
  }
}
