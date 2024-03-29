import 'dart:async';

import 'package:rxdart/rxdart.dart'
    show DoStreamTransformer, StreamNotification;

/// Invokes the given callback at the corresponding point the the stream
/// lifecycle. For example, if you pass in an onDone callback, it will
/// be invoked when the stream finishes emitting items.
extension DoOnStreamExtensions<T> on Stream<T> {
  /// Invokes the given callback at the corresponding point the the stream
  /// lifecycle. For example, if you pass in an onDone callback, it will
  /// be invoked when the stream finishes emitting items.
  Stream<T> doOn({
    void Function()? listen,
    FutureOr<void> Function()? cancel,
    void Function()? pause,
    void Function()? resume,
    void Function(T data)? data,
    void Function(Object error, StackTrace stackTrace)? error,
    void Function()? done,
    void Function(StreamNotification<T> notification)? each,
  }) =>
      DoStreamTransformer(
        onListen: listen,
        onCancel: cancel,
        onPause: pause,
        onResume: resume,
        onData: data,
        onError: error,
        onDone: done,
        onEach: each,
      ).bind(this);
}
