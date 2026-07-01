// Kingdom Heir — Notification data model
//
// Maps the `public.notifications` Supabase row to the [AppNotification]
// domain entity.

import 'package:kingdom_heir/features/notifications/domain/entities/app_notification.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.kind,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] as String?) ?? 'general';
    final kind = switch (rawType) {
      'event' => NotificationKind.event,
      'prayer' => NotificationKind.prayer,
      'sermon' => NotificationKind.sermon,
      'devotional' => NotificationKind.devotional,
      'giving' => NotificationKind.giving,
      'general' => NotificationKind.general,
      _ => NotificationKind.unknown,
    };

    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      kind: kind,
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationKind kind;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification toEntity() => AppNotification(
        id: id,
        title: title,
        body: body,
        kind: kind,
        isRead: isRead,
        createdAt: createdAt,
        data: data,
      );
}
