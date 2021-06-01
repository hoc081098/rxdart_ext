import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'single.dart';

/// Extends the Single class with the ability to execute a callback function
/// at different points in the Single's lifecycle.
extension DoSingleExtensions<T> on Single<T> {
  /// Invokes the given callback function when the Single subscription is
  /// cancelled. Often called doOnUnsubscribe or doOnDispose in other
  /// implementations.
  ///
  /// ### Example
  ///
  ///     final subscription = Single.timer(1, Duration(minutes: 1))
  ///       .doOnCancel(() => print('hi'))
  ///       .listen(null);
  ///
  ///     subscription.cancel(); // prints 'hi'
  Single<T> doOnCancel(FutureOr<void> Function() onCancel) =>
      Single.safe(DoExtensions(this).doOnCancel(onCancel));

  /// Invokes the given callback function when the Single emits an item. In
  /// other implementations, this is called doOnNext.
  ///
  /// ### Example
  ///
  ///     Single.value(1)
  ///       .doOnData(print)
  ///       .listen(null); // prints 1
  Single<T> doOnData(void Function(T event) onData) =>
      Single.safe(DoExtensions(this).doOnData(onData));
}
