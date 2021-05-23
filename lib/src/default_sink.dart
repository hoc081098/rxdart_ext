import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';

export 'package:rxdart/src/utils/forwarding_sink.dart' show ForwardingSink;
export 'package:rxdart/src/utils/forwarding_stream.dart' show forwardStream;

/// This [ForwardingSink] mixin implements all [ForwardingSink] members except [add].
mixin ForwardingSinkMixin<T, R> implements ForwardingSink<T, R> {
  @override
  FutureOr<void> onCancel(EventSink<R> sink) {}

  @override
  void onPause(EventSink<R> sink) {}

  @override
  void onResume(EventSink<R> sink) {}

  @override
  void onListen(EventSink<R> sink) {}

  @override
  void add(EventSink<R> sink, T data);

  @override
  void addError(EventSink<R> sink, Object error, StackTrace st) =>
      sink.addError(error, st);

  @override
  void close(EventSink<R> sink) => sink.close();
}
