import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/kids/data/repositories/kids_repository.dart';
import 'package:kingdom_heir/features/kids/data/services/kids_supabase_service.dart';
import 'package:kingdom_heir/features/kids/domain/entities/kids_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final kidsRepositoryProvider = Provider<KidsRepository>((ref) {
  return KidsRepositoryImpl(KidsSupabaseService(Supabase.instance.client));
});

final activeKidsSessionProvider = FutureProvider<KidsSession?>((ref) async {
  final repo = ref.watch(kidsRepositoryProvider);
  final result = await repo.getActiveSession();
  return result.fold((l) => throw Exception(l), (r) => r);
});

final myKidsProvider = FutureProvider<List<Kid>>((ref) async {
  final repo = ref.watch(kidsRepositoryProvider);
  final result = await repo.getMyKids();
  return result.fold((l) => throw Exception(l), (r) => r);
});

final myCheckinsProvider =
    FutureProvider.family<List<KidsCheckin>, String>((ref, sessionId) async {
  final repo = ref.watch(kidsRepositoryProvider);
  final result = await repo.getMyCheckins(sessionId);
  return result.fold((l) => throw Exception(l), (r) => r);
});

class KidsCheckinNotifier extends StateNotifier<AsyncValue<void>> {
  KidsCheckinNotifier(this.ref, this.repo) : super(const AsyncData(null));

  final Ref ref;
  final KidsRepository repo;

  Future<void> checkIn(String kidId, String sessionId) async {
    state = const AsyncLoading();
    final result = await repo.checkInKid(kidId, sessionId);
    state = result.fold(
      (err) => AsyncError(err, StackTrace.current),
      (_) {
        ref.invalidate(myCheckinsProvider(sessionId));
        return const AsyncData(null);
      },
    );
  }

  Future<void> checkOut(String checkinId, String sessionId) async {
    state = const AsyncLoading();
    final result = await repo.checkOutKid(checkinId);
    state = result.fold(
      (err) => AsyncError(err, StackTrace.current),
      (_) {
        ref.invalidate(myCheckinsProvider(sessionId));
        return const AsyncData(null);
      },
    );
  }
}

final kidsCheckinNotifierProvider =
    StateNotifierProvider<KidsCheckinNotifier, AsyncValue<void>>((ref) {
  return KidsCheckinNotifier(ref, ref.watch(kidsRepositoryProvider));
});
