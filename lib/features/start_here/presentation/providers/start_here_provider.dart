import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/start_here/data/repositories/start_here_repository.dart';

final startHereContentProvider =
    FutureProvider.family<StartHereContent, String>((ref, key) async {
  final repo = ref.watch(startHereRepositoryProvider);
  final result = await repo.getContent(key);

  return result.fold(
    (err) => throw Exception(err),
    (content) => content,
  );
});
