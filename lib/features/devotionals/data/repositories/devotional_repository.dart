import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/devotionals/data/services/devotional_local_cache.dart';
import 'package:kingdom_heir/features/devotionals/data/services/devotional_supabase_service.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';

abstract class DevotionalRepository {
  Future<Either<String, Devotional?>> getDailyDevotional();
  Future<Either<String, List<Devotional>>> getPreviousDevotionals();
  Future<Either<String, List<DevotionalReflection>>> getReflections();
  Future<Either<String, void>> addReflection(
    String body, {
    String? devotionalId,
  });
}

class DevotionalRepositoryImpl implements DevotionalRepository {
  DevotionalRepositoryImpl({
    required this.supabaseService,
    required this.localCache,
  });

  final DevotionalSupabaseService supabaseService;
  final DevotionalLocalCache localCache;

  @override
  Future<Either<String, Devotional?>> getDailyDevotional() async {
    try {
      final cached = localCache.getCachedDailyDevotional();
      // If we have a cached devotional and it is for today, return it immediately for fast UI load
      if (cached != null) {
        final now = DateTime.now();
        if (cached.scheduledFor.year == now.year &&
            cached.scheduledFor.month == now.month &&
            cached.scheduledFor.day == now.day) {
          // Fire and forget fetch to update cache in background
          unawaited(
            supabaseService.getDailyDevotional().then(
              (res) => res.fold(
                (l) => null,
                (d) {
                  if (d != null) localCache.cacheDailyDevotional(d);
                },
              ),
            ),
          );
          return right(cached);
        }
      }

      final result = await supabaseService.getDailyDevotional();
      return result.fold(
        left,
        (d) {
          if (d != null) {
            localCache.cacheDailyDevotional(d);
          }
          return right(d);
        },
      );
    } catch (e) {
      return left('Failed to get daily devotional: $e');
    }
  }

  @override
  Future<Either<String, List<Devotional>>> getPreviousDevotionals() async {
    try {
      final cached = localCache.getCachedPreviousDevotionals();
      if (cached != null && cached.isNotEmpty) {
        // Fire and forget
        unawaited(
          supabaseService.getPreviousDevotionals().then(
            (res) => res.fold(
              (l) => null,
              localCache.cachePreviousDevotionals,
            ),
          ),
        );
        return right(cached);
      }

      final result = await supabaseService.getPreviousDevotionals();
      return result.fold(
        left,
        (list) {
          localCache.cachePreviousDevotionals(list);
          return right(list);
        },
      );
    } catch (e) {
      return left('Failed to get previous devotionals: $e');
    }
  }

  @override
  Future<Either<String, List<DevotionalReflection>>> getReflections() =>
      supabaseService.getReflections();

  @override
  Future<Either<String, void>> addReflection(
    String body, {
    String? devotionalId,
  }) =>
      supabaseService.addReflection(body, devotionalId: devotionalId);
}
