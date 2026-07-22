import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/logging/structured_logger.dart';
import 'package:kingdom_heir/core/storage/cache_keys.dart';
import 'package:kingdom_heir/core/storage/cache_manager.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class DevotionalSupabaseService {
  DevotionalSupabaseService(this._client, this._cacheManager);
  final supabase.SupabaseClient _client;
  final CacheManager _cacheManager;

  String get _userId => _client.auth.currentUser!.id;

  Future<Either<String, T>> _guardData<T>(
    String cacheKey,
    Duration ttl,
    Future<dynamic> Function() fetchJson,
    T Function(dynamic) parseJson,
    T emptyState,
  ) async {
    StructuredLogger.networkRequestStarted(
      feature: 'devotionals',
      repository: 'DevotionalSupabaseService',
      datasource: 'supabase',
    );
    final stopwatch = Stopwatch()..start();

    try {
      final data = await fetchJson();
      stopwatch.stop();

      StructuredLogger.networkRequestCompleted(
        feature: 'devotionals',
        repository: 'DevotionalSupabaseService',
        datasource: 'supabase',
        durationMs: stopwatch.elapsedMilliseconds,
      );

      await _cacheManager.write(
        key: cacheKey,
        payload: data,
        feature: 'devotionals',
        repository: 'DevotionalSupabaseService',
        ttl: ttl,
      );

      return right(parseJson(data));
    } catch (e) {
      stopwatch.stop();
      
      final isNetworkError = e is SocketException || e is TimeoutException || e.toString().toLowerCase().contains('network') || e.toString().toLowerCase().contains('socket');
      
      if (!isNetworkError) {
        StructuredLogger.parsingFailed(
          feature: 'devotionals',
          repository: 'DevotionalSupabaseService',
          error: e.toString(),
        );
        rethrow;
      }

      StructuredLogger.networkRequestFailed(
        feature: 'devotionals',
        repository: 'DevotionalSupabaseService',
        datasource: 'supabase',
        durationMs: stopwatch.elapsedMilliseconds,
        errorType: e.runtimeType.toString(),
      );

      final cached = _cacheManager.read(
        key: cacheKey,
        feature: 'devotionals',
        repository: 'DevotionalSupabaseService',
      );

      if (cached != null) {
        try {
          return right(parseJson(cached));
        } catch (_) {}
      }
      return right(emptyState);
    }
  }

  Future<Either<String, Devotional?>> getDailyDevotional(
      {String languageCode = 'en',}) async {
    return _guardData<Devotional?>(
      CacheKeys.devotionalsActiveSeries,
      const Duration(hours: 6),
      () async {
        return await _client.rpc<List<dynamic>>('get_devotionals_localized',
            params: {'p_lang': languageCode},);
      },
      (data) {
        final list = data as List<dynamic>;
        if (list.isEmpty) return null;

        final now = DateTime.now();
        final todayStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        
        final todayDevotional = list.firstWhere(
          (d) => (d as Map<String, dynamic>)['scheduled_for'] == todayStr,
          orElse: () => null,
        );

        if (todayDevotional != null) {
          return Devotional.fromJson(todayDevotional as Map<String, dynamic>);
        }

        final latest = list.first;
        return Devotional.fromJson(latest as Map<String, dynamic>);
      },
      null,
    );
  }

  Future<Either<String, List<Devotional>>> getPreviousDevotionals(
      {String languageCode = 'en',}) async {
    return _guardData<List<Devotional>>(
      CacheKeys.devotionalsPastSeries,
      const Duration(hours: 6),
      () async {
        return await _client.rpc<List<dynamic>>('get_devotionals_localized',
            params: {'p_lang': languageCode},);
      },
      (data) {
        final list = data as List<dynamic>;
        final now = DateTime.now();
        final todayStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        
        return list
            .map((e) => Devotional.fromJson(e as Map<String, dynamic>))
            .where((d) => d.scheduledFor.compareTo(DateTime.parse(todayStr)) < 0)
            .take(20)
            .toList();
      },
      const [],
    );
  }

  Future<Either<String, List<DevotionalReflection>>> getReflections() async {
    return _guardData<List<DevotionalReflection>>(
      'cache_devotional_reflections',
      const Duration(minutes: 30),
      () async {
        return await _client
            .from('devotional_reflections')
            .select()
            .order('created_at', ascending: false);
      },
      (data) {
        return (data as List<dynamic>)
            .map((e) => DevotionalReflection.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      const [],
    );
  }

  Future<Either<String, void>> addReflection(
    String body, {
    String? devotionalId,
  }) async {
    try {
      await _client.from('devotional_reflections').insert({
        'user_id': _userId,
        'body': body,
        if (devotionalId != null) 'devotional_id': devotionalId,
      });
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }
}
