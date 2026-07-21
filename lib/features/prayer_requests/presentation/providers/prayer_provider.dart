// Kingdom Heir — Prayer providers
//
// Riverpod state for the public Prayer Wall, the "My Prayer Requests"
// screen, and the admin Prayer Moderation screen.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:kingdom_heir/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:kingdom_heir/features/prayer_requests/data/models/prayer_request_model.dart';
import 'package:kingdom_heir/features/prayer_requests/data/repositories/prayer_repository.dart';
import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public Prayer Wall
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
      repo.getApprovedPrayerWall(),
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
        repo.streamApprovedPrayerWall().listen(_handleRealtimeUpdates);

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
        final status = raw['status'] as String? ?? 'pending';
        final visibility = raw['visibility'] as String? ?? 'public';

        // Skip non-public or non-approved entries — the public wall only
        // shows approved public + approved leaders_only rows.
        if (status != 'approved' || visibility == 'private') {
          if (index != -1) updatedList.removeAt(index);
          continue;
        }

        if (index != -1) {
          final current = updatedList[index];
          final parsed = PrayerRequestModel.fromJson(raw);
          updatedList[index] = current.copyWith(
            title: parsed.title,
            content: parsed.content,
            status: parsed.toEntity().status,
            prayerCount: parsed.prayerCount,
            category: parsed.category,
            visibility: parsed.visibility,
            isAnonymous: parsed.isAnonymous,
            approvedAt: parsed.approvedAt,
          );
        } else {
          // New approval: stream row won't have the profiles join, so
          // build a partial entity and trigger a full refresh to backfill
          // the author name / avatar.
          final parsed = PrayerRequestModel.fromJson(raw).toEntity();
          updatedList.insert(0, parsed);
          _refetchInBackground();
        }
      }

      state = AsyncData(updatedList);
    });
  }

  void _refetchInBackground() {
    final repo = ref.read(prayerRepositoryProvider);
    repo.getApprovedPrayerWall().then((result) {
      result.fold(
        (_) {}, // silently ignore errors — the optimistic entry remains
        (models) {
          state.whenData((current) {
            final intercededIds =
                current.where((e) => e.hasPrayed).map((e) => e.id).toSet();
            state = AsyncData(
              models
                  .map(
                    (m) => m.toEntity(
                      hasPrayed: intercededIds.contains(m.id),
                    ),
                  )
                  .toList(),
            );
          });
        },
      );
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
    final result =
        await repo.togglePrayerIntercession(id, isPraying: targetState);

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

  /// Resets the state to `AsyncData(null)` so the submit screen can
  /// transition back to the form for a second submission.
  void reset() {
    state = const AsyncData(null);
  }
}

/// Thrown when the repository returns a Left for `getApprovedPrayerWall`.
/// `toString()` returns just the underlying message (no "Exception: " prefix).
class _PrayerLoadFailure implements Exception {
  _PrayerLoadFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

// ─────────────────────────────────────────────────────────────────────────────
// My Prayers  (current user's own history: pending + approved + rejected)
// ─────────────────────────────────────────────────────────────────────────────

final myPrayersProvider =
    FutureProvider.autoDispose<List<PrayerRequest>>((ref) async {
  final repo = ref.watch(prayerRepositoryProvider);
  final result = await repo.getMyPrayerRequests();
  return result.fold(
    (err) => throw _PrayerLoadFailure(err),
    (models) => models.map((m) => m.toEntity()).toList(),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Admin Prayer Moderation
// ─────────────────────────────────────────────────────────────────────────────

/// Pending tab. Auto-disposes when no longer watched.
final pendingPrayersForAdminProvider =
    FutureProvider.autoDispose<List<PrayerRequest>>((ref) async {
  final repo = ref.watch(prayerRepositoryProvider);
  final result = await repo.getPendingPrayerRequestsForAdmin();
  return result.fold(
    (err) => throw _PrayerLoadFailure(err),
    (models) => models.map((m) => m.toEntity()).toList(),
  );
});

/// Approved tab.
final approvedPrayersForAdminProvider =
    FutureProvider.autoDispose<List<PrayerRequest>>((ref) async {
  final repo = ref.watch(prayerRepositoryProvider);
  final result = await repo.getApprovedPrayerRequestsForAdmin();
  return result.fold(
    (err) => throw _PrayerLoadFailure(err),
    (models) => models.map((m) => m.toEntity()).toList(),
  );
});

/// Rejected (not-published) tab.
final rejectedPrayersForAdminProvider =
    FutureProvider.autoDispose<List<PrayerRequest>>((ref) async {
  final repo = ref.watch(prayerRepositoryProvider);
  final result = await repo.getRejectedPrayerRequestsForAdmin();
  return result.fold(
    (err) => throw _PrayerLoadFailure(err),
    (models) => models.map((m) => m.toEntity()).toList(),
  );
});

/// In-flight set of request IDs so the admin UI can show a per-card
/// spinner and prevent double-taps.
final moderationInFlightProvider =
    StateProvider.autoDispose<Set<String>>((ref) => <String>{});

/// Single entry point for the admin moderation actions (approve / reject
/// / return-to-pending). All three flows invalidate the three admin tab
/// providers, the public wall, and the member's notifications.
class AdminPrayerModeration {
  AdminPrayerModeration(this.ref);
  final Ref ref;

  /// Approve a pending request. On success, [onSuccess] is invoked with
  /// the success message so the caller can show a SnackBar.
  Future<String?> approve(
    String id, {
    String? adminNote,
    void Function(String successMessage)? onSuccess,
  }) =>
      _runModeration(
        id: id,
        apply: () => ref
            .read(prayerRepositoryProvider)
            .approvePrayerRequest(id: id, adminNote: adminNote),
        successMessage: 'Prayer request approved for the Prayer Wall.',
        onSuccess: onSuccess,
      );

  /// Reject (do-not-publish) a pending or approved request.
  Future<String?> reject(
    String id, {
    String? adminNote,
    void Function(String successMessage)? onSuccess,
  }) =>
      _runModeration(
        id: id,
        apply: () => ref
            .read(prayerRepositoryProvider)
            .rejectPrayerRequest(id: id, adminNote: adminNote),
        successMessage: 'Prayer request marked as not published.',
        onSuccess: onSuccess,
      );

  /// Move a previously approved or rejected request back into pending.
  Future<String?> returnToPending(
    String id, {
    void Function(String successMessage)? onSuccess,
  }) =>
      _runModeration(
        id: id,
        apply: () => ref
            .read(prayerRepositoryProvider)
            .returnPrayerRequestToPending(id: id),
        successMessage: 'Prayer request moved back to the pending queue.',
        onSuccess: onSuccess,
      );

  /// Returns `null` on success (after invoking [onSuccess]) or the
  /// user-facing error message on failure.
  Future<String?> _runModeration({
    required String id,
    required Future<fpdart.Either<String, void>> Function() apply,
    required String successMessage,
    void Function(String successMessage)? onSuccess,
  }) async {
    final inFlight = ref.read(moderationInFlightProvider.notifier);
    inFlight.state = {...inFlight.state, id};

    try {
      final result = await apply();
      return result.fold(
        (err) => err,
        (_) {
          // Invalidate all three admin tabs + the public wall +
          // the notifications list. The member's myPrayersProvider
          // is not invalidated from here because we don't know which
          // user the row belongs to; the RPC's notification insert
          // surfaces the change.
          ref
            ..invalidate(pendingPrayersForAdminProvider)
            ..invalidate(approvedPrayersForAdminProvider)
            ..invalidate(rejectedPrayersForAdminProvider)
            ..invalidate(prayerFeedProvider)
            ..invalidate(notificationsProvider);
          onSuccess?.call(successMessage);
          return null;
        },
      );
    } finally {
      inFlight.state = {...inFlight.state}..remove(id);
    }
  }
}

final adminPrayerModerationProvider =
    Provider<AdminPrayerModeration>(AdminPrayerModeration.new);
