import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/localization/locale_provider.dart';
import 'package:kingdom_heir/features/devotionals/data/repositories/devotional_repository.dart';
import 'package:kingdom_heir/features/devotionals/data/services/devotional_local_cache.dart';
import 'package:kingdom_heir/features/devotionals/data/services/devotional_supabase_service.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final devotionalRepositoryProvider = Provider<DevotionalRepository>((ref) {
  return DevotionalRepositoryImpl(
    supabaseService: DevotionalSupabaseService(Supabase.instance.client),
    localCache: DevotionalLocalCache(ref.watch(sharedPreferencesProvider)),
  );
});

final dailyDevotionalProvider = FutureProvider<Devotional?>((ref) async {
  final repo = ref.watch(devotionalRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final result =
      await repo.getDailyDevotional(languageCode: locale.languageCode);
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

final previousDevotionalsProvider =
    FutureProvider<List<Devotional>>((ref) async {
  final repo = ref.watch(devotionalRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final result =
      await repo.getPreviousDevotionals(languageCode: locale.languageCode);
  return result.fold(
    (l) => throw Exception(l),
    (r) => r,
  );
});

class ReflectionsNotifier
    extends StateNotifier<AsyncValue<List<DevotionalReflection>>> {
  ReflectionsNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  final DevotionalRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repo.getReflections();
    state = result.fold(
      (l) => AsyncValue.error(l, StackTrace.current),
      AsyncValue.data,
    );
  }

  Future<void> addReflection(String body, {String? devotionalId}) async {
    final result = await _repo.addReflection(body, devotionalId: devotionalId);
    result.fold(
      (l) => null, // handle error via ui callback if needed
      (_) => unawaited(load()), // reload reflections
    );
  }
}

final reflectionsProvider = StateNotifierProvider<ReflectionsNotifier,
    AsyncValue<List<DevotionalReflection>>>((ref) {
  return ReflectionsNotifier(ref.watch(devotionalRepositoryProvider));
});
