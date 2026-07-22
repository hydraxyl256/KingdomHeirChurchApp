// Kingdom Heir — Home Dashboard Repository
//
// Wires the redesigned dashboard to the live Supabase backend.
// Implements robust SharedPreferences caching for offline support.

// ignore_for_file: avoid_dynamic_calls, inference_failure_on_function_invocation

import 'dart:convert';

import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Outcome of a save-back write
class DashboardWriteResult {
  const DashboardWriteResult({required this.success, this.error});
  final bool success;
  final Object? error;
}

class HomeDashboardRepository {
  HomeDashboardRepository(
    this._prefs, {
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final SharedPreferences _prefs;
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  // ── Greeting ─────────────────────────────────────────────────────────────

  Future<DashboardGreeting> fetchGreeting() => _guardData<DashboardGreeting>(
        'fetchGreeting',
        () async {
          final uid = _userId;
          if (uid == null) throw Exception('No user');
          return await _client.rpc<dynamic>(
            'get_dashboard_greeting',
            params: <String, dynamic>{
              'p_user_id': uid,
            },
          ).single();
        },
        (dynamic data) => DashboardGreeting(
          firstName: (data['first_name'] as String?) ?? 'Friend',
          moment: resolveGreetingMoment(DateTime.now()),
          streakDays: (data['streak_days'] as int?) ?? 0,
          avatarUrl: data['avatar_url'] as String?,
          unreadNotifications: (data['unread_notifications'] as int?) ?? 0,
        ),
        () => DashboardGreeting(
          firstName: 'Friend',
          moment: resolveGreetingMoment(DateTime.now()),
          streakDays: 0,
        ),
      );

  // ── Scripture ────────────────────────────────────────────────────────────

  Future<List<ScriptureCard>> fetchScriptureRoster() => _guardData<List<ScriptureCard>>(
        'fetchScriptureRoster',
        () async {
          return await _client.rpc<dynamic>('get_dashboard_scripture');
        },
        (dynamic rows) {
          final list = rows as List<dynamic>;
          return list
              .map(
                (dynamic row) => ScriptureCard(
                  verseText: row['verse_text'] as String,
                  reference: row['reference'] as String,
                  translation: row['translation'] as String,
                  isBookmarked: row['is_bookmarked'] as bool? ?? false,
                ),
              )
              .toList(growable: false);
        },
        () => [],
      );

  Future<ScriptureCard> fetchScripture() async {
    final roster = await fetchScriptureRoster();
    if (roster.isEmpty) {
      return const ScriptureCard(
        verseText: 'Welcome to Kingdom Heirs',
        reference: '',
        translation: '',
      );
    }
    return roster.first;
  }

  // ── Continue Your Journey ────────────────────────────────────────────────

  Future<List<ContinueCard>> fetchContinueCards() => _guardData<List<ContinueCard>>(
        'fetchContinueCards',
        () async {
          final uid = _userId;
          if (uid == null) throw Exception('No user');
          return await _client.rpc<dynamic>(
            'get_dashboard_continue',
            params: <String, dynamic>{'p_user_id': uid, 'p_limit': 8},
          );
        },
        (dynamic rows) {
          final list = rows as List<dynamic>;
          return list
              .map(
                (dynamic row) => ContinueCard(
                  id: row['content_id'] as String,
                  kind: _kindFromString(row['kind'] as String),
                  title: row['title'] as String,
                  subtitle: row['subtitle'] as String? ?? '',
                  progress: (row['progress'] as num?)?.toDouble() ?? 0,
                  thumbnailUrl: row['thumbnail_url'] as String?,
                  durationLabel: row['duration_label'] as String?,
                ),
              )
              .toList(growable: false);
        },
        () => [],
      );

  // ── Live / Next Service ──────────────────────────────────────────────────

  Future<ServiceStatus> fetchServiceStatus() => _guardData<ServiceStatus>(
        'fetchServiceStatus',
        () async {
          return await _client.rpc<dynamic>('get_dashboard_service').maybeSingle();
        },
        (dynamic data) {
          if (data == null) {
            return const ServiceStatus(isLive: false, title: 'No Service Expected');
          }
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
        () => const ServiceStatus(isLive: false, title: 'No Service Expected'),
      );

  // ── Daily Journey ────────────────────────────────────────────────────────

  Future<DailyJourney> fetchDailyJourney() => _guardData<DailyJourney>(
        'fetchDailyJourney',
        () async {
          final uid = _userId;
          if (uid == null) throw Exception('No user');
          return await _client.rpc<dynamic>(
            'get_dashboard_journey',
            params: <String, dynamic>{'p_user_id': uid},
          );
        },
        (dynamic rows) {
          final completed = <SpiritualTaskKind>{
            for (final dynamic row in rows as List<dynamic>)
              if (row['is_completed'] as bool? ?? false)
                _taskKindFromString(row['kind'] as String),
          };
          
          final defaultTasks = [
            const SpiritualTask(kind: SpiritualTaskKind.scripture, isCompleted: false, label: 'Daily Word'),
            const SpiritualTask(kind: SpiritualTaskKind.prayer, isCompleted: false, label: 'Prayer'),
            const SpiritualTask(kind: SpiritualTaskKind.devotional, isCompleted: false, label: 'Devotional'),
          ];

          return DailyJourney(
            streakDays: 0,
            tasks: defaultTasks
                .map((task) => SpiritualTask(
                  kind: task.kind,
                  isCompleted: completed.contains(task.kind),
                  label: task.label,
                ),)
                .toList(growable: false),
          );
        },
        () => const DailyJourney(streakDays: 0, tasks: []),
      );

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

  Future<List<TodayEvent>> fetchTodayEvents() => _guardData<List<TodayEvent>>(
        'fetchTodayEvents',
        () async {
          return await _client.rpc<dynamic>('get_dashboard_events');
        },
        (dynamic rows) {
          final list = rows as List<dynamic>;
          return list
              .map(
                (dynamic row) => TodayEvent(
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
                ),
              )
              .toList(growable: false);
        },
        () => [],
      );

  // ── Prayer Corner ────────────────────────────────────────────────────────

  Future<PrayerCorner> fetchPrayerCorner() => _guardData<PrayerCorner>(
        'fetchPrayerCorner',
        () async {
          return await _client.rpc<dynamic>(
            'get_dashboard_prayer',
            params: <String, dynamic>{'p_limit': 4},
          );
        },
        (dynamic rows) {
          final list = rows as List<dynamic>;
          return PrayerCorner(
            usersPrayedToday: 0,
            requests: list
                .map(
                  (dynamic row) => PrayerRequest(
                    id: row['id'] as String,
                    authorName: row['author_name'] as String,
                    preview: row['preview'] as String,
                    avatarUrl: row['avatar_url'] as String?,
                    prayerCount: row['pray_count'] as int? ?? 0,
                  ),
                )
                .toList(growable: false),
          );
        },
        () => const PrayerCorner(usersPrayedToday: 0, requests: []),
      );

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

  Future<CommunityHighlight> fetchCommunityHighlight() => _guardData<CommunityHighlight>(
        'fetchCommunityHighlight',
        () async {
          final uid = _userId;
          if (uid == null) throw Exception('No user');
          return await _client.rpc<dynamic>(
            'get_dashboard_community',
            params: <String, dynamic>{
              'p_user_id': uid,
            },
          ).maybeSingle();
        },
        (dynamic data) {
          if (data == null) return const CommunityHighlight();
          return CommunityHighlight(
            unreadGroupMessages: data['unread_group_messages'] as int? ?? 0,
            birthdayName: data['birthday_name'] as String?,
            leaderAnnouncement: data['leader_announcement'] as String?,
            upcomingGroupMeeting: data['upcoming_group_meeting'] as String?,
          );
        },
        () => const CommunityHighlight(),
      );

  // ── Continue Watching ────────────────────────────────────────────────────

  Future<List<WatchCard>> fetchWatchCards() => _guardData<List<WatchCard>>(
        'fetchWatchCards',
        () async {
          final uid = _userId;
          if (uid == null) throw Exception('No user');
          return await _client.rpc<dynamic>(
            'get_dashboard_watch',
            params: <String, dynamic>{'p_user_id': uid, 'p_limit': 6},
          );
        },
        (dynamic rows) {
          final list = rows as List<dynamic>;
          return list
              .map(
                (dynamic row) => WatchCard(
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
                ),
              )
              .toList(growable: false);
        },
        () => [],
      );

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

  Future<T> _guardData<T>(
    String label,
    Future<dynamic> Function() fetchJson,
    T Function(dynamic) parseJson,
    T Function() emptyState,
  ) async {
    final cacheKey = 'dashboard_cache_$label';
    try {
      final data = await fetchJson();
      final cachePayload = {
        'data': data,
        'cached_at': DateTime.now().toIso8601String(),
      };
      await _prefs.setString(cacheKey, jsonEncode(cachePayload));
      return parseJson(data);
    } catch (e, st) {
      _log.w('HomeDashboardRepository.$label live fetch failed; using offline fallback', error: e, stackTrace: st);
      final cachedString = _prefs.getString(cacheKey);
      if (cachedString != null) {
        try {
          final cached = jsonDecode(cachedString) as Map<String, dynamic>;
          final data = cached['data'];
          if (data != null) {
            return parseJson(data);
          }
        } catch (_) {}
      }
      return emptyState();
    }
  }

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

Failure failureFromError(Object error) {
  if (error is Failure) return error;
  if (error is AuthException) return AuthFailure(message: error.message);
  if (error is PostgrestException) return ServerFailure(message: error.message);
  return UnknownFailure(message: error.toString());
}
