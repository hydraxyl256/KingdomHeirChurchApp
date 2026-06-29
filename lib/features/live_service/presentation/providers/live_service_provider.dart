// Kingdom Heir — Live Service: Riverpod Providers
//
// All state management for the live worship experience.
// Supabase-backed, Realtime-powered, offline-aware.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/live_service/data/repositories/live_service_repository.dart';
import 'package:kingdom_heir/features/live_service/domain/entities/live_service_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Supabase client shorthand
// ─────────────────────────────────────────────────────────────────────────────

final _db = Supabase.instance.client;

final liveServiceRepositoryProvider = Provider<LiveServiceRepository>((ref) {
  return LiveServiceRepository(Supabase.instance.client);
});

// ─────────────────────────────────────────────────────────────────────────────
// 1. Live Service State  (polls activeLiveStreamProvider + enriches)
// ─────────────────────────────────────────────────────────────────────────────

final liveServiceStateProvider =
    StreamProvider.autoDispose<LiveServiceState>((ref) async* {
  final repo = ref.watch(liveServiceRepositoryProvider);
  
  Future<LiveServiceState> build() async {
    return repo.getActiveLiveService();
  }

  // First yield
  yield await build();

  // Poll every 30 seconds
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 30));
    yield await build();
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// 2. Live Chat  (Supabase Realtime stream)
// ─────────────────────────────────────────────────────────────────────────────

final _chatMessagesProvider =
    StreamProvider.autoDispose<List<LiveChatMessage>>((ref) {
  final repo = ref.watch(liveServiceRepositoryProvider);
  final state = ref.watch(liveServiceStateProvider).valueOrNull;
  
  if (state == null || !state.isLive || state.serviceId == null) {
    return Stream.value([]);
  }
  
  return repo.streamChatMessages(state.serviceId!);
});

// Public alias used by widgets
final liveChatMessagesProvider = _chatMessagesProvider;

// ─────────────────────────────────────────────────────────────────────────────
// 3. Chat Notifier  (send, pin, delete)
// ─────────────────────────────────────────────────────────────────────────────

class LiveChatNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendMessage({
    required String serviceId,
    required String body,
    String? replyToId,
    String? replyToDisplayName,
    String? replyToBody,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    final displayName = user.userMetadata?['full_name'] as String? ??
        user.email?.split('@').first ??
        'Member';
    final avatarUrl = user.userMetadata?['avatar_url'] as String?;

    final msg = LiveChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: user.id,
      displayName: displayName,
      body: body.trim(),
      sentAt: DateTime.now(),
      avatarUrl: avatarUrl,
      replyToId: replyToId,
      replyToDisplayName: replyToDisplayName,
      replyToBody: replyToBody,
    );

    try {
      await _db
          .from('live_chat_messages')
          .insert(msg.toInsertJson(serviceId));
    } catch (_) {
      // Offline queue: store locally and retry on reconnect
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('chat_offline_queue') ?? [];
      await prefs.setStringList(
        'chat_offline_queue',
        queue..add('$serviceId|${msg.body}'),
      );
    }
  }

  Future<void> pinMessage(String messageId, {required bool pin}) async {
    try {
      await _db
          .from('live_chat_messages')
          .update({'is_pinned': pin})
          .eq('id', messageId);
    } catch (_) {}
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _db
          .from('live_chat_messages')
          .update({'is_deleted': true})
          .eq('id', messageId);
    } catch (_) {}
  }
}

final liveChatNotifierProvider =
    AsyncNotifierProvider<LiveChatNotifier, void>(LiveChatNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// 4. Chat UI State
// ─────────────────────────────────────────────────────────────────────────────

/// Slow mode: true = 30s cooldown between messages
final chatSlowModeProvider = StateProvider<bool>((ref) => false);

/// The message being replied to
final chatReplyToProvider = StateProvider<LiveChatMessage?>((ref) => null);

/// Typing indicator (local; real impl uses Supabase Presence)
final chatTypingProvider = StateProvider<bool>((ref) => false);

// Last time current user sent a message (for slow mode enforcement)
final chatLastSentProvider = StateProvider<DateTime?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// 5. Announcements
// ─────────────────────────────────────────────────────────────────────────────

final liveAnnouncementsProvider =
    FutureProvider.autoDispose<List<LiveAnnouncement>>((ref) async {
  final rows = await _db
      .from('live_announcements')
      .select()
      .or('expires_at.is.null,expires_at.gt.${DateTime.now().toIso8601String()}')
      .order('created_at', ascending: false)
      .limit(6);
  return rows
      .map(LiveAnnouncement.fromJson,)
      .toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// 6. Upcoming Services
// ─────────────────────────────────────────────────────────────────────────────

final upcomingServicesProvider =
    FutureProvider.autoDispose<List<UpcomingService>>((ref) async {
  final rows = await _db
      .from('upcoming_services')
      .select()
      .gte('scheduled_at', DateTime.now().toIso8601String())
      .order('scheduled_at')
      .limit(5);
  return rows
      .map(UpcomingService.fromJson,)
      .toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// 7. Sermon Notes  (local + Supabase sync)
// ─────────────────────────────────────────────────────────────────────────────

class SermonNotesNotifier extends AutoDisposeFamilyNotifier<SermonNote?, String> {
  static const _prefixKey = 'sermon_note_';

  @override
  SermonNote? build(String arg) {
    // Load from SharedPreferences synchronously via a future scheduled at init
    _loadFromPrefs(arg);
    return null;
  }

  Future<void> _loadFromPrefs(String sermonId) async {
    final prefs = await SharedPreferences.getInstance();
    final body = prefs.getString('$_prefixKey$sermonId') ?? '';
    final scriptureRef =
        prefs.getString('${_prefixKey}scripture_$sermonId');
    if (body.isNotEmpty) {
      state = SermonNote(
        id: sermonId,
        sermonId: sermonId,
        body: body,
        createdAt: DateTime.now(),
        scriptureRef: scriptureRef,
      );
    }
  }

  Future<void> updateNote(String sermonId, String body,
      {String? scriptureRef,}) async {
    final now = DateTime.now();
    final note = SermonNote(
      id: sermonId,
      sermonId: sermonId,
      body: body,
      createdAt: state?.createdAt ?? now,
      updatedAt: now,
      scriptureRef: scriptureRef ?? state?.scriptureRef,
    );
    state = note;

    // Local persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixKey$sermonId', body);
    if (scriptureRef != null) {
      await prefs.setString('${_prefixKey}scripture_$sermonId', scriptureRef);
    }

    // Background Supabase sync
    _syncToSupabase(note);
  }

  void _syncToSupabase(SermonNote note) {
    final user = _db.auth.currentUser;
    if (user == null) return;
    unawaited(
      _db.from('sermon_notes').upsert({
        'id': note.id,
        'user_id': user.id,
        'sermon_id': note.sermonId,
        'body': note.body,
        'scripture_ref': note.scriptureRef,
        'updated_at': note.updatedAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      }).then((_) {
        if (state?.id == note.id) {
          state = SermonNote(
            id: note.id,
            sermonId: note.sermonId,
            body: note.body,
            createdAt: note.createdAt,
            updatedAt: note.updatedAt,
            scriptureRef: note.scriptureRef,
            isSynced: true,
          );
        }
      }).catchError((_) {}),
    );
  }

  Future<void> clearNote(String sermonId) async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefixKey$sermonId');
    await prefs.remove('${_prefixKey}scripture_$sermonId');
  }
}

final sermonNotesProvider =
    NotifierProvider.family.autoDispose<SermonNotesNotifier, SermonNote?, String>(
  SermonNotesNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// 8. Prayer Requests
// ─────────────────────────────────────────────────────────────────────────────

class PrayerRequestNotifier extends AutoDisposeNotifier<List<LivePrayerRequest>> {
  @override
  List<LivePrayerRequest> build() => [];

  Future<void> submitRequest({
    required PrayerRequestType type,
    required String message,
    bool isFollowUp = false,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    final request = LivePrayerRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      message: message,
      submittedAt: DateTime.now(),
      isFollowUp: isFollowUp,
    );

    state = [...state, request];

    try {
      await _db
          .from('live_prayer_requests')
          .insert(request.toInsertJson(user.id));
    } catch (_) {
      // Prayer submitted locally even if Supabase fails
    }
  }

  Future<void> loadHistory() async {
    final user = _db.auth.currentUser;
    if (user == null) return;
    try {
      final rows = await _db
          .from('live_prayer_requests')
          .select()
          .eq('user_id', user.id)
          .order('submitted_at', ascending: false)
          .limit(10);
      state = (rows as List)
          .map((r) =>
              LivePrayerRequest.fromJson(r as Map<String, dynamic>),)
          .toList();
    } catch (_) {}
  }
}

final prayerRequestProvider =
    NotifierProvider.autoDispose<PrayerRequestNotifier, List<LivePrayerRequest>>(
  PrayerRequestNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// 9. Current scripture ref (for BibleReferencePanel)
// ─────────────────────────────────────────────────────────────────────────────

final currentLiveScriptureProvider = StateProvider.autoDispose<String?>((ref) {
  final state = ref.watch(liveServiceStateProvider).valueOrNull;
  return state?.currentScriptureRef;
});

// ─────────────────────────────────────────────────────────────────────────────
// 10. Active tab for the expandable panels
// ─────────────────────────────────────────────────────────────────────────────

enum LivePanelTab { chat, notes, prayer, bible }

final livePanelTabProvider =
    StateProvider<LivePanelTab>((ref) => LivePanelTab.chat);

// ─────────────────────────────────────────────────────────────────────────────
// 11. Viewer count (Supabase Presence)
// ─────────────────────────────────────────────────────────────────────────────

final liveViewerCountProvider =
    StreamProvider.autoDispose<int>((ref) async* {
  final state = ref.watch(liveServiceStateProvider).valueOrNull;
  if (state == null || !state.isLive || state.serviceId == null) {
    yield 0;
    return;
  }

  final serviceId = state.serviceId!;
  final channel = _db.channel('viewers:$serviceId');
  final controller = StreamController<int>();

  final sub = channel
      .onPresenceSync(
        (payload) {
          final count = channel.presenceState().length;
          if (!controller.isClosed) controller.add(count);
        },
      )
      .subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          unawaited(
            channel.track({'user_id': _db.auth.currentUser?.id ?? 'guest'}),
          );
        }
      });

  ref.onDispose(() {
    unawaited(sub.unsubscribe());
    unawaited(controller.close());
  });

  yield* controller.stream;
});
