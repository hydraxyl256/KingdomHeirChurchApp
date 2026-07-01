// Kingdom Heir — Notifications domain entity
//
// Pure Dart value type — no Flutter, no Supabase.

import 'package:flutter/foundation.dart';

enum NotificationKind {
  general,
  event,
  prayer,
  sermon,
  devotional,
  giving,
  unknown,
}

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  final String id;
  final String title;
  final String body;
  final NotificationKind kind;
  final bool isRead;
  final DateTime createdAt;

  /// Optional deep-link payload (e.g. `{ "sermon_id": "..." }`).
  final Map<String, dynamic>? data;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        kind: kind,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        data: data,
      );
}
