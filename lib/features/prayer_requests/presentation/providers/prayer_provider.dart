import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:kingdom_heir/features/prayer_requests/data/models/prayer_request_model.dart';
import 'package:kingdom_heir/features/prayer_requests/data/repositories/prayer_repository.dart';
import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Prayer Feed State
// ─────────────────────────────────────────────────────────────────────────────

final prayerFeedProvider =
    AsyncNotifierProvider<PrayerFeedNotifier, List<PrayerRequest>>(
  PrayerFeedNotifier.new,
);

class PrayerFeedNotifier extends AsyncNotifier<List<PrayerRequest>> {
  StreamSubscription<List<Map<String, dynamic>>>? _streamSubscription;

  @override
  Future<List<PrayerRequest>> build() async {
    final repo = ref.watch(prayerRepositoryProvider);

    // Fetch initial list and the user's intercession state
    final results = await Future.wait([
      repo.getPrayerRequests(),
      repo.getIntercededPrayerIds(),
    ]);

    final requestsResult =
        results[0] as fpdart.Either<String, List<PrayerRequestModel>>;
    final intercededIds = results[1] as List<String>;

    // Surface the repository's failure message verbatim rather than wrapping
    // it in `Exception(err)` (which becomes "Exception: ..." noise in the UI).
    final initialList = requestsResult.fold(
      (err) => throw _PrayerLoadFailure(err),
      (models) => models
          .map((m) => m.toEntity(hasPrayed: intercededIds.contains(m.id)))
          .toList(),
    );

    // Setup Realtime Subscription to update counts and statuses dynamically
    unawaited(_streamSubscription?.cancel());
    _streamSubscription =
        repo.streamPrayerRequests().listen(_handleRealtimeUpdates);

    // Cleanup on dispose
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    return initialList;
  }

  void _handleRealtimeUpdates(List<Map<String, dynamic>> rawUpdates) {
    state.whenData((currentList) {
      final updatedList = [...currentList];

      for (final raw in rawUpdates) {
        final id = raw['id'] as String;
        final index = updatedList.indexWhere((e) => e.id == id);

        if (index != -1) {
          // Update existing request (e.g. prayer_count, status)
          // We preserve authorName/Avatar since the stream doesn't join profiles
          final current = updatedList[index];
          final parsed = PrayerRequestModel.fromJson(raw);
          updatedList[index] = current.copyWith(
            title: parsed.title,
            content: parsed.content,
            status: parsed.toEntity().status,
            prayerCount: parsed.prayerCount,
            category: parsed.category,
            isPublic: parsed.isPublic,
            isAnonymous: parsed.isAnonymous,
          );
        } else {
          // New request arrived. In a real app, you might want to fetch the profile manually here
          // or just append it as Anonymous until refresh if the stream doesn't have the profile.
          // For now, we'll append it.
          final parsed = PrayerRequestModel.fromJson(raw).toEntity();
          updatedList.insert(0, parsed);
        }
      }

      state = AsyncData(updatedList);
    });
  }

  /// Optimistically toggles the prayer intercession.
  Future<void> togglePray(String id, {required bool currentlyPraying}) async {
    final repo = ref.read(prayerRepositoryProvider);
    final targetState = !currentlyPraying;

    // Optimistic UI update
    state = state.whenData((list) {
      return list.map((e) {
        if (e.id == id) {
          return e.copyWith(
            hasPrayed: targetState,
            prayerCount: e.prayerCount + (targetState ? 1 : -1),
          );
        }
        return e;
      }).toList();
    });

    // Network request
    final result = await repo.togglePrayerIntercession(id, isPraying: targetState);

    // Revert on failure
    if (result.isLeft()) {
      state = state.whenData((list) {
        return list.map((e) {
          if (e.id == id) {
            return e.copyWith(
              hasPrayed: currentlyPraying,
              prayerCount: e.prayerCount + (currentlyPraying ? 1 : -1),
            );
          }
          return e;
        }).toList();
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit Prayer State
// ─────────────────────────────────────────────────────────────────────────────

final submitPrayerProvider =
    StateNotifierProvider<SubmitPrayerNotifier, AsyncValue<void>>((ref) {
  return SubmitPrayerNotifier(ref.watch(prayerRepositoryProvider));
});

class SubmitPrayerNotifier extends StateNotifier<AsyncValue<void>> {
  SubmitPrayerNotifier(this._repo) : super(const AsyncData(null));
  final PrayerRepository _repo;

  Future<void> submit(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final result = await _repo.submitPrayerRequest(data);

    result.fold(
      (err) => state = AsyncError(err, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }
}

/// Thrown when the repository returns a Left for `getPrayerRequests`.
/// `toString()` returns just the underlying message (no "Exception: " prefix).
class _PrayerLoadFailure implements Exception {
  _PrayerLoadFailure(this.message);
  final String message;
  @override
  String toString() => message;
}
