import 'package:dart_either/dart_either.dart';
import 'single.dart';
import 'flat_map.dart';

/// TODO(flatMapEitherSingle)
extension FlatMapEitherSingleExtension<L, R1> on Single<Either<L, R1>> {
  /// TODO(flatMapEitherSingle)
  Single<Either<L, R2>> flatMapEitherSingle<R2>(
    Single<Either<L, R2>> Function(R1 value) transform,
  ) =>
      flatMapSingle(
        (either) => either.fold(
          ifLeft: (v) => Single.value(v.left<R2>()),
          ifRight: transform,
        ),
      );
}
