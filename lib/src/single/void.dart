import '../operators/void.dart';
import 'single.dart';

/// Extends the Single class with the ability to convert the source Single to a `Single<void>`.
extension AsVoidSingleExtension<T> on Single<T> {
  /// Returns a `Single<void>`.
  ///
  /// ### Example
  ///
  ///     Single.value(1)
  ///       .asVoid()
  ///       .listen(print); // prints null
  ///
  ///     // equivalent to:
  ///
  ///     Single.value(1)
  ///       .mapTo<void>(null)
  ///       .listen(print); // prints null
  Single<void> asVoid() => Single.safe(AsVoidStreamExtension(this).asVoid());
}
