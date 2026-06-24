import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/volunteers/data/services/volunteer_supabase_service.dart';
import 'package:kingdom_heir/features/volunteers/domain/entities/volunteer_models.dart';

abstract class VolunteerRepository {
  Future<Either<String, List<VolunteerOpportunity>>> getOpportunities();
  Future<Either<String, List<VolunteerApplication>>> getMyApplications();
  Future<Either<String, VolunteerApplication>> applyForOpportunity(
      String opportunityId,);
}

class VolunteerRepositoryImpl implements VolunteerRepository {
  VolunteerRepositoryImpl(this._service);
  final VolunteerSupabaseService _service;

  @override
  Future<Either<String, List<VolunteerOpportunity>>> getOpportunities() =>
      _service.getOpportunities();

  @override
  Future<Either<String, List<VolunteerApplication>>> getMyApplications() =>
      _service.getMyApplications();

  @override
  Future<Either<String, VolunteerApplication>> applyForOpportunity(
          String opportunityId,) =>
      _service.applyForOpportunity(opportunityId);
}
