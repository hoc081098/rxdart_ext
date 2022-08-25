import 'package:dart_either/dart_either.dart';
import 'single.dart';
import 'flat_map.dart';

/// Extends the Single class with the ability to transform the [Either] events.
extension FlatMapEitherSingleExtension<L, R1> on Single<Either<L, R1>> {
  /// `flatMap` the [Either] in the [Single] context.
  ///
  /// When this [Single] emits a [Right] value,
  /// calling [transform] callback with [Right.value].
  /// And returns a new [Single] which emits the result of the call to [transform].
  ///
  /// If this [Single] emits a [Left] value,
  /// returns a [Single] that emits a [Left] which containing original [Left.value].
  ///
  /// This operator does not handle any errors. See [flatMapSingle].
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
