import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/kids/data/services/kids_supabase_service.dart';
import 'package:kingdom_heir/features/kids/domain/entities/kids_models.dart';

abstract class KidsRepository {
  Future<Either<String, List<Kid>>> getMyKids();
  Future<Either<String, KidsSession?>> getActiveSession();
  Future<Either<String, List<KidsCheckin>>> getMyCheckins(String sessionId);
  Future<Either<String, KidsCheckin>> checkInKid(
      String kidId, String sessionId,);
  Future<Either<String, KidsCheckin>> checkOutKid(String checkinId);
}

class KidsRepositoryImpl implements KidsRepository {
  KidsRepositoryImpl(this._service);
  final KidsSupabaseService _service;

  @override
  Future<Either<String, List<Kid>>> getMyKids() => _service.getMyKids();

  @override
  Future<Either<String, KidsSession?>> getActiveSession() =>
      _service.getActiveSession();

  @override
  Future<Either<String, List<KidsCheckin>>> getMyCheckins(String sessionId) =>
      _service.getMyCheckins(sessionId);

  @override
  Future<Either<String, KidsCheckin>> checkInKid(
          String kidId, String sessionId,) =>
      _service.checkInKid(kidId, sessionId);

  @override
  Future<Either<String, KidsCheckin>> checkOutKid(String checkinId) =>
      _service.checkOutKid(checkinId);
}
