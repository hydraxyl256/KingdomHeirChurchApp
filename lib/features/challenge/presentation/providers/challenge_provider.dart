import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/challenge/data/repositories/challenge_repository.dart';
import 'package:kingdom_heir/features/challenge/domain/models/group_reporting_packet.dart';

final submitGroupReportProvider =
    StateNotifierProvider<SubmitGroupReportNotifier, AsyncValue<void>>((ref) {
  return SubmitGroupReportNotifier(ref.watch(challengeRepositoryProvider));
});

class SubmitGroupReportNotifier extends StateNotifier<AsyncValue<void>> {
  SubmitGroupReportNotifier(this._repo) : super(const AsyncData(null));

  final ChallengeRepository _repo;

  Future<void> submit(GroupReportingPacket packet) async {
    state = const AsyncLoading();
    final result = await _repo.submitGroupReport(packet);
    state = result.fold(
      (err) => AsyncError(err, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
