import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/leadership/data/repositories/leadership_repository.dart';
import 'package:kingdom_heir/features/leadership/domain/entities/leader_application.dart';

final submitLeaderApplicationProvider =
    StateNotifierProvider<SubmitLeaderApplicationNotifier, AsyncValue<void>>(
        (ref) {
  return SubmitLeaderApplicationNotifier(
      ref.watch(leadershipRepositoryProvider),);
});

class SubmitLeaderApplicationNotifier extends StateNotifier<AsyncValue<void>> {
  SubmitLeaderApplicationNotifier(this._repo) : super(const AsyncData(null));

  final LeadershipRepository _repo;

  Future<void> submit(LeaderApplication application) async {
    state = const AsyncLoading();
    final result = await _repo.submitLeaderApplication(application);
    state = result.fold(
      (err) => AsyncError(err, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
