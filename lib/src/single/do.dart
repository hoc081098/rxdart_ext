import 'dart:async';

import '../utils/default_sink.dart';
import 'single.dart';

class _DoStreamSingleSink<S> extends ForwardingSink<S, S>
    with ForwardingSinkMixin<S, S> {
  final FutureOr<void> Function()? onCancelCallback;
  final void Function(S event)? onDataCallback;
  final void Function(Object, StackTrace)? onErrorCallback;
  final void Function()? onListenCallback;
  var closed = false;

  _DoStreamSingleSink({
    this.onCancelCallback,
    this.onDataCallback,
    this.onErrorCallback,
    this.onListenCallback,
  });

  @override
  void onData(S data) {
    if (closed) {
      return;
    }

    try {
      onDataCallback?.call(data);
    } catch (e, s) {
      sink.addError(e, s);
      sink.close();
      closed = true;
      return;
    }
    sink.add(data);
  }

  @override
  void onError(Object e, StackTrace st) {
    if (closed) {
      return;
    }

    try {
      onErrorCallback?.call(e, st);
    } catch (e, s) {
      sink.addError(e, s);
      sink.close();
      closed = true;
      return;
    }
    sink.addError(e, st);
  }

  @override
  FutureOr<void> onCancel() => onCancelCallback?.call();

  @override
  void onListen() {
    try {
      onListenCallback?.call();
    } catch (e, s) {
      sink.addError(e, s);
      sink.close();
      closed = true;
    }
  }

  @override
  void onPause() {}

  @override
  void onResume() {}
}

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
      forwardSingleWithSink(
          () => _DoStreamSingleSink(onCancelCallback: onCancel), true);

  /// Invokes the given callback function when the Single emits an item. In
  /// other implementations, this is called doOnNext.
  ///
  /// ### Example
  ///
  ///     Single.value(1)
  ///       .doOnData(print)
  ///       .listen(null); // prints 1
  Single<T> doOnData(void Function(T event) onData) => forwardSingleWithSink(
      () => _DoStreamSingleSink(onDataCallback: onData), true);

  /// Invokes the given callback function when the Single emits an error.
  ///
  /// ### Example
  ///
  ///     Single<int>.error(Exception())
  ///       .doOnError((error, stacktrace) => print('oh no'))
  ///       .listen(null); // prints 'Oh no'
  Single<T> doOnError(void Function(Object, StackTrace) onError) =>
      forwardSingleWithSink(
          () => _DoStreamSingleSink(onErrorCallback: onError), true);

  /// Invokes the given callback function when the Single is first listened to.
  ///
  /// ### Example
  ///
  ///     Single.value(1)
  ///       .doOnListen(() => print('Is someone there?'))
  ///       .listen(null); // prints 'Is someone there?'
  Single<T> doOnListen(void Function() onListen) => forwardSingleWithSink(
      () => _DoStreamSingleSink(onListenCallback: onListen), true);
}
