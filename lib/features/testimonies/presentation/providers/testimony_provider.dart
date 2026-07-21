import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/localization/locale_provider.dart';
import 'package:kingdom_heir/features/testimonies/data/repositories/testimony_repository.dart';
import 'package:kingdom_heir/features/testimonies/domain/entities/testimony.dart';

final testimonyCategoryFilterProvider = StateProvider<String>((ref) => 'All');

final testimoniesFeedProvider =
    FutureProvider.autoDispose<List<Testimony>>((ref) async {
  final repo = ref.watch(testimonyRepositoryProvider);
  final category = ref.watch(testimonyCategoryFilterProvider);

  final locale = ref.watch(localeProvider);
  final result = await repo.getTestimonies(
      category: category == 'All' ? null : category,
      languageCode: locale.languageCode,);
  return result.fold(
    (err) => throw Exception(err),
    (list) => list,
  );
});

final submitTestimonyProvider =
    StateNotifierProvider<SubmitTestimonyNotifier, AsyncValue<void>>((ref) {
  return SubmitTestimonyNotifier(ref.watch(testimonyRepositoryProvider));
});

class SubmitTestimonyNotifier extends StateNotifier<AsyncValue<void>> {
  SubmitTestimonyNotifier(this._repo) : super(const AsyncData(null));

  final TestimonyRepository _repo;

  Future<void> submit(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final result = await _repo.submitTestimony(data);
    state = result.fold(
      (err) => AsyncError(err, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
