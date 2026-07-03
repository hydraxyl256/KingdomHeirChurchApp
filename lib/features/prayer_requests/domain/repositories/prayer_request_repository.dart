import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';

abstract interface class PrayerRequestRepository {
  /// Fetch the public prayer feed (paginated).
  Future<Either<Failure, List<PrayerRequest>>> getPublicRequests({
    int page = 0,
    int pageSize = 30,
  });

  /// Fetch the current user's own requests.
  Future<Either<Failure, List<PrayerRequest>>> getMyRequests();

  /// Submit a new prayer request.
  Future<Either<Failure, PrayerRequest>> submitRequest({
    required String title,
    required String body,
    required String category,
    required bool isPublic,
    required bool isAnonymous,
  });

  /// Mark a prayer as answered.
  Future<Either<Failure, PrayerRequest>> markAnswered({
    required String requestId,
    required String answeredNote,
  });

  /// Delete a prayer request (owner only).
  Future<Either<Failure, Unit>> deleteRequest(String requestId);

  /// Pray for a request — adds an intercession record.
  Future<Either<Failure, Unit>> prayForRequest(String requestId);

  /// Remove an intercession.
  Future<Either<Failure, Unit>> stopPraying(String requestId);

  /// Check if the current user has prayed for a request.
  Future<Either<Failure, bool>> hasPrayed(String requestId);

  /// Add a comment to a prayer request.
  Future<Either<Failure, Unit>> addComment({
    required String requestId,
    required String body,
    bool isAnonymous = false,
  });
}
