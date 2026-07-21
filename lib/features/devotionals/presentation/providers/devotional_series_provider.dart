// Kingdom Heir — Devotional Series Riverpod Providers
//
// Covers:
//   - Published series list
//   - Per-series progress (AsyncNotifier with complete action)
//   - Unlocked entries and individual entry with locale
//   - Dashboard card state derivation
//   - Reflection read/write

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/localization/locale_provider.dart';
import 'package:kingdom_heir/features/devotionals/data/repositories/devotional_series_repository.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_series_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Published series list
// ─────────────────────────────────────────────────────────────────────────────

final publishedSeriesProvider =
    FutureProvider.autoDispose<List<DevotionalSeries>>((ref) async {
  final repo = ref.watch(devotionalSeriesRepositoryProvider);
  final result = await repo.getPublishedSeries();
  return result.fold(
    (err) => throw Exception(err),
    (list) => list,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Single series
// ─────────────────────────────────────────────────────────────────────────────

final devotionalSeriesByIdProvider = FutureProvider.autoDispose
    .family<DevotionalSeries, String>((ref, id) async {
  final repo = ref.watch(devotionalSeriesRepositoryProvider);
  final result = await repo.getSeriesById(id);
  return result.fold((err) => throw Exception(err), (s) => s);
});

// ─────────────────────────────────────────────────────────────────────────────
// Primary challenge series
// ─────────────────────────────────────────────────────────────────────────────

final primaryChallengeSeriesProvider =
    FutureProvider.autoDispose<DevotionalSeries?>((ref) async {
  final repo = ref.watch(devotionalSeriesRepositoryProvider);
  final result = await repo.getPrimaryChallengeSeries();
  return result.fold((err) => throw Exception(err), (s) => s);
});

// ─────────────────────────────────────────────────────────────────────────────
// Unlocked entries for a series (header-only, no body — for day list)
// ─────────────────────────────────────────────────────────────────────────────

final unlockedEntriesProvider =
    FutureProvider.autoDispose.family<List<DevotionalEntry>, String>(
  (ref, seriesId) async {
    final repo = ref.watch(devotionalSeriesRepositoryProvider);
    final result = await repo.getUnlockedEntries(seriesId);
    return result.fold((err) => throw Exception(err), (list) => list);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Single entry — locale-aware (body, translation fallback)
// ─────────────────────────────────────────────────────────────────────────────

typedef EntryKey = ({String seriesId, int dayNumber});

final devotionalEntryProvider =
    FutureProvider.autoDispose.family<DevotionalEntry?, EntryKey>(
  (ref, key) async {
    final repo = ref.watch(devotionalSeriesRepositoryProvider);
    final locale = ref.watch(localeProvider);
    final result = await repo.getEntry(
      key.seriesId,
      key.dayNumber,
      languageCode: locale.languageCode,
    );
    return result.fold((err) => throw Exception(err), (entry) => entry);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Progress — AsyncNotifier with completeDay action
// ─────────────────────────────────────────────────────────────────────────────

class DevotionalProgressNotifier
    extends AutoDisposeFamilyAsyncNotifier<DevotionalSeriesProgress?, String> {
  @override
  Future<DevotionalSeriesProgress?> build(String seriesId) async {
    final repo = ref.watch(devotionalSeriesRepositoryProvider);
    final result = await repo.getProgress(seriesId);
    return result.fold((err) => throw Exception(err), (p) => p);
  }

  Future<Either<String, DevotionalSeriesProgress>> joinChallenge() async {
    final repo = ref.read(devotionalSeriesRepositoryProvider);
    final result = await repo.initializeProgress(arg);
    result.fold(
      (_) {},
      (progress) => state = AsyncValue.data(progress),
    );
    return result;
  }

  Future<Either<String, DevotionalSeriesProgress>> completeDay(
    int dayNumber,
  ) async {
    final repo = ref.read(devotionalSeriesRepositoryProvider);
    final result = await repo.completeDay(arg, dayNumber);
    result.fold(
      (_) {},
      (progress) {
        state = AsyncValue.data(progress);
        // Refresh unlocked entries + dashboard state via cascade
        ref
          ..invalidate(unlockedEntriesProvider(arg))
          ..invalidate(primaryChallengeCardStateProvider);
      },
    );
    return result;
  }
}

final devotionalProgressProvider = AsyncNotifierProvider.autoDispose
    .family<DevotionalProgressNotifier, DevotionalSeriesProgress?, String>(
  DevotionalProgressNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard card state (derives from primary series + user progress)
// ─────────────────────────────────────────────────────────────────────────────

final primaryChallengeCardStateProvider =
    FutureProvider.autoDispose<DashboardDevotionalState?>((ref) async {
  final seriesAsync = await ref.watch(primaryChallengeSeriesProvider.future);
  if (seriesAsync == null) return null;

  final series = seriesAsync;
  final progressAsync =
      await ref.watch(devotionalProgressProvider(series.id).future);

  if (progressAsync == null) {
    return DashboardDevotionalState(
      status: DashboardDevotionalStatus.notJoined,
      seriesId: series.id,
      totalDays: series.totalDays,
    );
  }

  final progress = progressAsync;

  if (progress.isAllComplete) {
    return DashboardDevotionalState(
      status: DashboardDevotionalStatus.allComplete,
      seriesId: series.id,
      currentDay: series.totalDays,
      totalDays: series.totalDays,
      currentStreak: progress.longestStreak,
    );
  }

  if (progress.completedToday) {
    return DashboardDevotionalState(
      status: DashboardDevotionalStatus.completedToday,
      seriesId: series.id,
      currentDay: progress.currentDay,
      totalDays: series.totalDays,
      currentStreak: progress.currentStreak,
    );
  }

  return DashboardDevotionalState(
    status: DashboardDevotionalStatus.continueDay,
    seriesId: series.id,
    currentDay: progress.currentDay,
    totalDays: series.totalDays,
    currentStreak: progress.currentStreak,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Reflection read/write
// ─────────────────────────────────────────────────────────────────────────────

final devotionalReflectionProvider =
    FutureProvider.autoDispose.family<DevotionalJournalReflection?, String>(
  (ref, entryId) async {
    final repo = ref.watch(devotionalSeriesRepositoryProvider);
    final result = await repo.getReflection(entryId);
    return result.fold((err) => throw Exception(err), (r) => r);
  },
);

/// Simple notifier for saving reflections.
class ReflectionSaveNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Either<String, void>> save(
    String entryId,
    String text, {
    bool isPrivate = true,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(devotionalSeriesRepositoryProvider);
    final result =
        await repo.saveReflection(entryId, text, isPrivate: isPrivate);
    state = const AsyncData(null);
    if (result.isRight()) {
      ref.invalidate(devotionalReflectionProvider(entryId));
    }
    return result;
  }
}

final reflectionSaveProvider =
    AsyncNotifierProvider.autoDispose<ReflectionSaveNotifier, void>(
  ReflectionSaveNotifier.new,
);
