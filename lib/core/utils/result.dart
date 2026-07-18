import 'package:fpdart/fpdart.dart';
import 'package:traqio/core/errors/failures.dart';

/// Standard return type for every repository/use case method in Traqio.
/// Left = Failure, Right = Success value.
typedef Result<T> = Either<Failure, T>;
