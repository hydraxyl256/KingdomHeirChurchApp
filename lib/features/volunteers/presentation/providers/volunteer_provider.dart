import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/volunteers/data/repositories/volunteer_repository.dart';
import 'package:kingdom_heir/features/volunteers/data/services/volunteer_supabase_service.dart';
import 'package:kingdom_heir/features/volunteers/domain/entities/volunteer_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  return VolunteerRepositoryImpl(
    VolunteerSupabaseService(Supabase.instance.client),
  );
});

final volunteerOpportunitiesProvider =
    FutureProvider<List<VolunteerOpportunity>>((ref) async {
  final repo = ref.watch(volunteerRepositoryProvider);
  final result = await repo.getOpportunities();
  return result.fold((l) => throw Exception(l), (r) => r);
});

final myVolunteerApplicationsProvider =
    FutureProvider<List<VolunteerApplication>>((ref) async {
  final repo = ref.watch(volunteerRepositoryProvider);
  final result = await repo.getMyApplications();
  return result.fold((l) => throw Exception(l), (r) => r);
});

class VolunteerApplicationNotifier extends StateNotifier<AsyncValue<void>> {
  VolunteerApplicationNotifier(this.ref, this.repo)
      : super(const AsyncData(null));

  final Ref ref;
  final VolunteerRepository repo;

  Future<void> apply(String opportunityId) async {
    state = const AsyncLoading();
    final result = await repo.applyForOpportunity(opportunityId);
    state = result.fold(
      (err) => AsyncError(err, StackTrace.current),
      (_) {
        ref.invalidate(myVolunteerApplicationsProvider);
        return const AsyncData(null);
      },
    );
  }
}

final volunteerApplicationNotifierProvider =
    StateNotifierProvider<VolunteerApplicationNotifier, AsyncValue<void>>(
        (ref) {
  return VolunteerApplicationNotifier(
    ref,
    ref.watch(volunteerRepositoryProvider),
  );
});
