import 'package:rxdart/rxdart.dart' show MapToExtension;

import 'single.dart';

/// Extends the Single class with the ability to convert the item to the same value.
extension MapToSingleExtension<T> on Single<T> {
  /// Emits the given constant value on the output Single when the source
  /// Single emits a value.
  ///
  /// ### Example
  ///
  ///     Single.value(1)
  ///       .mapTo(true)
  ///       .listen(print); // prints true
  Single<R> mapTo<R>(R value) => Single.safe(MapToExtension(this).mapTo(value));
}
