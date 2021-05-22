import 'package:rxdart/rxdart.dart';

import 'single.dart';

/// Extends the Single class with the ability to delay events being emitted
extension DelaySingleExtension<T> on Single<T> {
  /// The Delay operator modifies its source Single by pausing for a particular
  /// increment of time (that you specify) before emitting each of the source
  /// Stream’s items. This has the effect of shifting the entire sequence of
  /// items emitted by the Single forward in time by that specified increment.
  ///
  /// ## Marble
  /// ```text
  ///source: ---------a-------|
  ///result: -------------a---|
  ///
  ///source: ---------a-------|
  ///result: --------------------a|
  /// ```
  /// [Interactive marble diagram](http://rxmarbles.com/#delay)
  Single<T> delay(Duration duration) =>
      Single.safe(transform(DelayStreamTransformer<T>(duration)));
}
