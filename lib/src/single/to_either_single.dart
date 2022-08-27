import 'package:dart_either/dart_either.dart';
import 'single.dart';

/// Extends the Single class with the ability to convert the events to [Either] values.
extension ToEitherSingleExtension<R> on Single<R> {
  /// Transform data events to [Right]s and error events to [Left]s.
  ///
  /// When the source [Single] emits a data event, the result stream will emit
  /// a [Right] wrapping that data event.
  ///
  /// When the source [Single] emits a error event, calling [errorMapper] with that error
  /// and the result stream will emits a [Left] wrapping the result.
  ///
  /// The done events will be forwarded.
  ///
  /// ### Marble
  /// ```text
  /// single      : ----------a|
  /// errorMapper : (e, s) => e
  /// result      : ----------R(a)|
  ///
  /// single      : ----------x|
  /// errorMapper : (e, s) => e
  /// result      : ----------L(x)|
  ///
  /// NOTE:
  /// x is error event
  /// R is Right
  /// L is Left
  /// ```
  ///
  /// ### Example
  /// ```dart
  /// Single.value(1)
  ///     .toEitherSingle((e, s) => e)
  ///     .listen(print); // prints Either.Right(1);
  ///
  /// Single<int>.error(Exception())
  ///     .toEitherSingle((e, s) => e)
  ///     .listen(print); // prints Either.Left(Exception);
  /// ```
  Single<Either<L, R>> toEitherSingle<L>(ErrorMapper<L> errorMapper) =>
      Single.safe(toEitherStream(errorMapper));
}
