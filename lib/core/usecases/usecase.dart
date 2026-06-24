// ignore_for_file: one_member_abstracts

import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/core/error/failure.dart';

/// Base contract for all synchronous use cases.
abstract class UseCase<ReturnType, Params> {
  Future<Either<Failure, ReturnType>> call(Params params);
}

/// Base contract for use cases with no parameters.
abstract class UseCaseNoParams<ReturnType> {
  Future<Either<Failure, ReturnType>> call();
}

/// Base contract for streaming use cases.
abstract class StreamUseCase<ReturnType, Params> {
  Stream<Either<Failure, ReturnType>> call(Params params);
}

/// Sentinel type for use cases that take no params.
class NoParams {
  const NoParams();
}
