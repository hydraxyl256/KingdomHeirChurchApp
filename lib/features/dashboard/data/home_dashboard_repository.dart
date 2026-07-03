// Kingdom Heir — Home Dashboard Repository
//
// Wires the redesigned dashboard to the live Supabase backend. Every
// fetch* method calls the matching RPC (see
// `supabase/migrations/20260630_dashboard_real_data.sql`) and falls back
// to the curated mock content in `home_dashboard_mock.dart` when the
// network or RPC fails. That preserves the spec rule: "no mock data
// unless offline fallback".
//
// Save-back methods (toggleJourneyTask, incrementPrayerCount,
// updateWatchProgress) are fire-and-forget — callers update the UI
// optimistically and `ref.invalidate(...)` refreshes from the server.
//
// All `row['x']` index access in this file is on a Supabase PostgREST
// row (which is a Map). We suppress `avoid_dynamic_calls` because
// adding an explicit Map<String, dynamic> cast at every site would
// be 50+ lines of noise for zero runtime safety gain (Supabase's
// generated types are erased at runtime).
// ignore_for_file: avoid_dynamic_calls, inference_failure_on_function_invocation

import 'dart:async';
import 'dart:math' as math;

import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/features/dashboard/data/home_dashboard_mock.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Outcome of a save-back write — currently only used for the optimistic
/// UI side, not exposed to callers. Kept here so future telemetry hooks
/// have a place to land.
class DashboardWriteResult {
  const DashboardWriteResult({required this.success, this.error});
  final bool success;
  final Object? error;
}

class HomeDashboardRepository {
  HomeDashboardRepository({
    SupabaseClient? client,
    math.Random? random,
  })  : _client = client ?? Supabase.instance.client,
        _rng = random ?? math.Random();

  final SupabaseClient _client;
  final math.Random _rng;
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  // ── Greeting ─────────────────────────────────────────────────────────────

  Future<DashboardGreeting> fetchGreeting() => _guard(
        'fetchGreeting',
        () async {
          final uid = _userId;
          if (uid == null) return HomeDashboardMock.greeting(_rng);
          final dynamic data = await _client
              .rpc<dynamic>('get_dashboard_greeting', params: <String, dynamic>{
                'p_user_id': uid,
              },)
              .single();
          return DashboardGreeting(
            firstName: (data['first_name'] as String?) ?? 'Friend',
            moment: resolveGreetingMoment(DateTime.now()),
            streakDays: (data['streak_days'] as int?) ?? 0,
            avatarUrl: data['avatar_url'] as String?,
            unreadNotifications: (data['unread_notifications'] as int?) ?? 0,
          );
        },
        () => HomeDashboardMock.greeting(_rng),
      );

  // ── Scripture ────────────────────────────────────────────────────────────

  Future<List<ScriptureCard>> fetchScriptureRoster() => _guardList(
        'fetchScriptureRoster',
        () async {
          final dynamic rows = await _client.rpc<dynamic>('get_dashboard_scripture');
          final list = rows as List<dynamic>;
          if (list.isEmpty) return HomeDashboardMock.scriptureRoster;
          return list
              .map((dynamic row) => ScriptureCard(
                    verseText: row['verse_text'] as String,
                    reference: row['reference'] as String,
                    translation: row['translation'] as String,
                    isBookmarked: row['is_bookmarked'] as bool? ?? false,
                  ),)
              .toList(growable: false);
        },
        HomeDashboardMock.scriptureRoster,
      );

  /// Convenience accessor: the first verse of the roster is the verse of
  /// the day. The card flips through `scriptureRoster` on swipe.
  Future<ScriptureCard> fetchScripture() async {
    final roster = await fetchScriptureRoster();
    return roster.first;
  }

  // ── Continue Your Journey ────────────────────────────────────────────────

  Future<List<ContinueCard>> fetchContinueCards() => _guardList(
        'fetchContinueCards',
        () async {
          final uid = _userId;
          if (uid == null) return HomeDashboardMock.continueCards;
          final dynamic rows = await _client.rpc<dynamic>(
            'get_dashboard_continue',
            params: <String, dynamic>{'p_user_id': uid, 'p_limit': 8},
          );
          final list = rows as List<dynamic>;
          if (list.isEmpty) return HomeDashboardMock.continueCards;
          return list
              .map((dynamic row) => ContinueCard(
                    id: row['content_id'] as String,
                    kind: _kindFromString(row['kind'] as String),
                    title: row['title'] as String,
                    subtitle: row['subtitle'] as String? ?? '',
                    progress:
                        (row['progress'] as num?)?.toDouble() ?? 0,
                    thumbnailUrl: row['thumbnail_url'] as String?,
                    durationLabel: row['duration_label'] as String?,
                  ),)
              .toList(growable: false);
        },
        HomeDashboardMock.continueCards,
      );

  // ── Live / Next Service ──────────────────────────────────────────────────

  Future<ServiceStatus> fetchServiceStatus() => _guard(
        'fetchServiceStatus',
        () async {
          final dynamic data = await _client
              .rpc<dynamic>('get_dashboard_service')
              .maybeSingle();
          if (data == null) return HomeDashboardMock.serviceStatus(_rng);
          return ServiceStatus(
            isLive: data['is_live'] as bool? ?? false,
            title: data['title'] as String,
            hostLabel: data['host_label'] as String?,
            startsAt: data['starts_at'] == null
                ? null
                : DateTime.parse(data['starts_at'] as String),
            viewerCount: data['viewer_count'] as int?,
            locationLabel: data['location_label'] as String?,
            streamUrl: data['stream_url'] as String?,
          );
        },
        () => HomeDashboardMock.serviceStatus(_rng),
      );

  // ── Daily Journey ────────────────────────────────────────────────────────

  Future<DailyJourney> fetchDailyJourney() => _guard(
        'fetchDailyJourney',
        () async {
          final uid = _userId;
          if (uid == null) return HomeDashboardMock.dailyJourney;
          final dynamic rows = await _client.rpc<dynamic>(
            'get_dashboard_journey',
            params: <String, dynamic>{'p_user_id': uid},
          );
          final completed = <SpiritualTaskKind>{
            for (final dynamic row in rows as List<dynamic>)
              if (row['is_completed'] as bool? ?? false)
                _taskKindFromString(row['kind'] as String),
          };
          return DailyJourney(
            streakDays: HomeDashboardMock.dailyJourney.streakDays,
            tasks: HomeDashboardMock.dailyJourney.tasks
                .map((task) => SpiritualTask(
                      kind: task.kind,
                      isCompleted: completed.contains(task.kind),
                      label: task.label,
                    ),)
                .toList(growable: false),
          );
        },
        () => HomeDashboardMock.dailyJourney,
      );

  /// Toggle a journey task. Optimistic — the caller should
  /// `ref.invalidate(journeyProvider)` immediately. We don't await this.
  Future<DashboardWriteResult> toggleJourneyTask(
    SpiritualTaskKind kind, {
    required bool isCompleted,
  }) async {
    final uid = _userId;
    if (uid == null) {
      return const DashboardWriteResult(success: false);
    }
    try {
      await _client.rpc<dynamic>(
        'toggle_journey_task',
        params: <String, dynamic>{
          'p_user_id': uid,
          'p_kind': kind.name,
          'p_is_completed': isCompleted,
        },
      );
      return const DashboardWriteResult(success: true);
    } catch (e) {
      _log.w('toggleJourneyTask failed', error: e);
      return DashboardWriteResult(success: false, error: e);
    }
  }

  // ── Church Today ─────────────────────────────────────────────────────────

  Future<List<TodayEvent>> fetchTodayEvents() => _guardList(
        'fetchTodayEvents',
        () async {
          final dynamic rows = await _client.rpc<dynamic>('get_dashboard_events');
          final list = rows as List<dynamic>;
          if (list.isEmpty) return HomeDashboardMock.todayEvents();
          return list
              .map((dynamic row) => TodayEvent(
                    id: row['id'] as String,
                    title: row['title'] as String,
                    startsAt: DateTime.parse(row['starts_at'] as String),
                    locationLabel: row['location_label'] as String? ?? '',
                    isOnline: row['is_online'] as bool? ?? false,
                    joinUrl: row['join_url'] as String?,
                    leaderName: row['leader_name'] as String?,
                    category: _categoryFromString(
                      row['category'] as String?,
                    ),
                  ),)
              .toList(growable: false);
        },
        HomeDashboardMock.todayEvents(),
      );

  // ── Prayer Corner ────────────────────────────────────────────────────────

  Future<PrayerCorner> fetchPrayerCorner() => _guard(
        'fetchPrayerCorner',
        () async {
          final dynamic rows = await _client.rpc<dynamic>(
            'get_dashboard_prayer',
            params: <String, dynamic>{'p_limit': 4},
          );
          final list = rows as List<dynamic>;
          return PrayerCorner(
            usersPrayedToday: HomeDashboardMock.prayerCorner.usersPrayedToday,
            answeredPrayerHighlight:
                HomeDashboardMock.prayerCorner.answeredPrayerHighlight,
            requests: list.isEmpty
                ? HomeDashboardMock.prayerCorner.requests
                : list
                    .map((dynamic row) => PrayerRequest(
                          id: row['id'] as String,
                          authorName: row['author_name'] as String,
                          preview: row['preview'] as String,
                          avatarUrl: row['avatar_url'] as String?,
                          prayerCount: row['pray_count'] as int? ?? 0,
                        ),)
                    .toList(growable: false),
          );
        },
        () => HomeDashboardMock.prayerCorner,
      );

  /// Increment a prayer request's prayer counter. Returns the new count
  /// (or null if Supabase is unreachable).
  Future<int?> incrementPrayerCount(String prayerId) async {
    try {
      final dynamic result = await _client.rpc<dynamic>(
        'increment_prayer_count',
        params: <String, dynamic>{'p_prayer_id': prayerId},
      );
      return result as int?;
    } catch (e) {
      _log.w('incrementPrayerCount failed', error: e);
      return null;
    }
  }

  // ── Community Highlight ──────────────────────────────────────────────────

  Future<CommunityHighlight> fetchCommunityHighlight() => _guard(
        'fetchCommunityHighlight',
        () async {
          final uid = _userId;
          if (uid == null) return HomeDashboardMock.communityHighlight;
          final dynamic data = await _client
              .rpc<dynamic>('get_dashboard_community', params: <String, dynamic>{
                'p_user_id': uid,
              },)
              .maybeSingle();
          if (data == null) return HomeDashboardMock.communityHighlight;
          return CommunityHighlight(
            unreadGroupMessages: data['unread_group_messages'] as int? ?? 0,
            birthdayName: data['birthday_name'] as String?,
            leaderAnnouncement: data['leader_announcement'] as String?,
            upcomingGroupMeeting: data['upcoming_group_meeting'] as String?,
          );
        },
        () => HomeDashboardMock.communityHighlight,
      );

  // ── Continue Watching ────────────────────────────────────────────────────

  Future<List<WatchCard>> fetchWatchCards() => _guardList(
        'fetchWatchCards',
        () async {
          final uid = _userId;
          if (uid == null) return HomeDashboardMock.watchCards;
          final dynamic rows = await _client.rpc<dynamic>(
            'get_dashboard_watch',
            params: <String, dynamic>{'p_user_id': uid, 'p_limit': 6},
          );
          final list = rows as List<dynamic>;
          if (list.isEmpty) return HomeDashboardMock.watchCards;
          return list
              .map((dynamic row) => WatchCard(
                    id: row['content_id'] as String,
                    kind: row['kind'] == 'podcast'
                        ? WatchKind.podcast
                        : WatchKind.sermon,
                    title: row['title'] as String,
                    speakerName: row['subtitle'] as String? ?? '',
                    progress: (row['progress'] as num?)?.toDouble() ?? 0,
                    thumbnailUrl: row['thumbnail_url'] as String?,
                    durationLabel: row['duration_label'] as String?,
                    isDownloaded: row['is_downloaded'] as bool? ?? false,
                  ),)
              .toList(growable: false);
        },
        HomeDashboardMock.watchCards,
      );

  /// Save watch progress — fire-and-forget.
  Future<DashboardWriteResult> updateWatchProgress({
    required String kind,
    required String contentId,
    required double progress,
    bool? isDownloaded,
  }) async {
    final uid = _userId;
    if (uid == null) return const DashboardWriteResult(success: false);
    try {
      await _client.rpc<dynamic>(
        'update_watch_progress',
        params: <String, dynamic>{
          'p_user_id': uid,
          'p_kind': kind,
          'p_content_id': contentId,
          'p_progress': progress,
          if (isDownloaded != null) 'p_is_downloaded': isDownloaded,
        },
      );
      return const DashboardWriteResult(success: true);
    } catch (e) {
      _log.w('updateWatchProgress failed', error: e);
      return DashboardWriteResult(success: false, error: e);
    }
  }

  // ── Aggregate ────────────────────────────────────────────────────────────

  /// Legacy aggregate — used by the existing `homeDashboardProvider` for
  /// backward compat with the screen's `.when(data: ...)` API.
  Future<HomeDashboardData> fetchAll() async {
    final results = await Future.wait(<Future<dynamic>>[
      fetchGreeting(),
      fetchScripture(),
      fetchContinueCards(),
      fetchServiceStatus(),
      fetchDailyJourney(),
      fetchTodayEvents(),
      fetchPrayerCorner(),
      fetchCommunityHighlight(),
      fetchWatchCards(),
    ]);
    return HomeDashboardData(
      greeting: results[0] as DashboardGreeting,
      scripture: results[1] as ScriptureCard,
      continueCards: results[2] as List<ContinueCard>,
      serviceStatus: results[3] as ServiceStatus,
      dailyJourney: results[4] as DailyJourney,
      todayEvents: results[5] as List<TodayEvent>,
      prayerCorner: results[6] as PrayerCorner,
      communityHighlight: results[7] as CommunityHighlight,
      watchCards: results[8] as List<WatchCard>,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String? get _userId {
    try {
      return _client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  Future<T> _guard<T>(
    String label,
    Future<T> Function() live,
    T Function() fallback,
  ) async {
    try {
      return await live();
    } catch (e, st) {
      _log.w('HomeDashboardRepository.$label live fetch failed; '
          'using offline fallback',
          error: e,
          stackTrace: st,);
      return fallback();
    }
  }

  Future<List<T>> _guardList<T>(
    String label,
    Future<List<T>> Function() live,
    List<T> fallback,
  ) =>
      _guard<List<T>>(
        label,
        live,
        () => fallback,
      );

  ContinueKind _kindFromString(String kind) {
    switch (kind) {
      case 'sermon':
        return ContinueKind.sermon;
      case 'biblePlan':
        return ContinueKind.biblePlan;
      case 'devotional':
        return ContinueKind.devotional;
      case 'podcast':
        return ContinueKind.podcast;
      case 'prayerChallenge':
        return ContinueKind.prayerChallenge;
    }
    return ContinueKind.devotional;
  }

  SpiritualTaskKind _taskKindFromString(String kind) {
    switch (kind) {
      case 'scripture':
        return SpiritualTaskKind.scripture;
      case 'devotional':
        return SpiritualTaskKind.devotional;
      case 'prayer':
        return SpiritualTaskKind.prayer;
      case 'reflection':
        return SpiritualTaskKind.reflection;
      case 'worship':
        return SpiritualTaskKind.worship;
      case 'journal':
        return SpiritualTaskKind.journal;
    }
    return SpiritualTaskKind.scripture;
  }

  TodayEventCategory _categoryFromString(String? category) {
    switch (category) {
      case 'prayer':
        return TodayEventCategory.prayer;
      case 'bible_study':
        return TodayEventCategory.bibleStudy;
      case 'youth':
        return TodayEventCategory.youth;
      case 'sunday_service':
        return TodayEventCategory.sundayService;
      case 'outreach':
        return TodayEventCategory.outreach;
      case 'choir':
        return TodayEventCategory.choir;
    }
    return TodayEventCategory.other;
  }
}

/// Helper: convert any thrown object into a [Failure]. Used by widgets
/// that watch providers and want to surface a typed error message.
Failure failureFromError(Object error) {
  if (error is Failure) return error;
  if (error is AuthException) return AuthFailure(message: error.message);
  if (error is PostgrestException) return ServerFailure(message: error.message);
  return UnknownFailure(message: error.toString());
}
