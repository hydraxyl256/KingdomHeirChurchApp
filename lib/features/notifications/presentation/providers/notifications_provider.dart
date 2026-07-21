// Kingdom Heir — Notifications state providers
//
// AsyncNotifier loads the user's notifications and exposes optimistic
// mark-as-read actions.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/notifications/data/repositories/notifications_repository.dart';
import 'package:kingdom_heir/features/notifications/domain/entities/app_notification.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final repo = ref.watch(notificationsRepositoryProvider);
    return repo.getNotifications();
  }

  Future<void> markAsRead(String id) async {
    final repo = ref.read(notificationsRepositoryProvider);
    final current = state.valueOrNull;
    if (current == null) return;
    // Optimistic update.
    state = AsyncData([
      for (final n in current)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ]);
    await repo.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationsRepositoryProvider);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final n in current) n.copyWith(isRead: true),
    ]);
    await repo.markAllAsRead();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
