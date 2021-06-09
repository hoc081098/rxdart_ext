import 'dart:async';

import '../default_sink.dart';
import 'single.dart';

class _DoStreamSink<S>
    with ForwardingSinkMixin<S, S>
    implements ForwardingSink<S, S> {
  final FutureOr<void> Function()? onCancelCallback;
  final void Function(S event)? onDataCallback;
  final void Function(Object, StackTrace)? onErrorCallback;
  final void Function()? onListenCallback;

  _DoStreamSink({
    this.onCancelCallback,
    this.onDataCallback,
    this.onErrorCallback,
    this.onListenCallback,
  });

  @override
  void add(EventSink<S> sink, S data) {
    try {
      onDataCallback?.call(data);
    } catch (e, s) {
      sink.addError(e, s);
      sink.close();
      return;
    }
    sink.add(data);
  }

  @override
  void addError(EventSink<S> sink, Object e, StackTrace st) {
    try {
      onErrorCallback?.call(e, st);
    } catch (e, s) {
      sink.addError(e, s);
      sink.close();
      return;
    }
    sink.addError(e, st);
  }

  @override
  FutureOr<void> onCancel(EventSink<S> sink) => onCancelCallback?.call();

  @override
  void onListen(EventSink<S> sink) {
    try {
      onListenCallback?.call();
    } catch (e, s) {
      sink.addError(e, s);
      sink.close();
    }
  }
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
      forwardSingleWithSink(_DoStreamSink(onCancelCallback: onCancel));

  /// Invokes the given callback function when the Single emits an item. In
  /// other implementations, this is called doOnNext.
  ///
  /// ### Example
  ///
  ///     Single.value(1)
  ///       .doOnData(print)
  ///       .listen(null); // prints 1
  Single<T> doOnData(void Function(T event) onData) =>
      forwardSingleWithSink(_DoStreamSink(onDataCallback: onData));

  /// Invokes the given callback function when the Single emits an error.
  ///
  /// ### Example
  ///
  ///     Single<int>.error(Exception())
  ///       .doOnError((error, stacktrace) => print('oh no'))
  ///       .listen(null); // prints 'Oh no'
  Single<T> doOnError(void Function(Object, StackTrace) onError) =>
      forwardSingleWithSink(_DoStreamSink(onErrorCallback: onError));

  /// Invokes the given callback function when the Single is first listened to.
  ///
  /// ### Example
  ///
  ///     Single.value(1)
  ///       .doOnListen(() => print('Is someone there?'))
  ///       .listen(null); // prints 'Is someone there?'
  Single<T> doOnListen(void Function() onListen) =>
      forwardSingleWithSink(_DoStreamSink(onListenCallback: onListen));
}
