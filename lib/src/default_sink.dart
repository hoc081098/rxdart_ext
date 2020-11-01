import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';

///
abstract class DefaultForwardingSink<T, R> implements ForwardingSink<T, R> {
  @override
  FutureOr onCancel(EventSink<R> sink) {}

  @override
  void onPause(EventSink<R> sink) {}

  @override
  void onResume(EventSink<R> sink) {}

  @override
  void onListen(EventSink<R> sink) {}

  @override
  void add(EventSink<R> sink, T data);

  @override
  void addError(EventSink<R> sink, dynamic error, [StackTrace st]) =>
      sink.addError(error, st);

  @override
  void close(EventSink<R> sink) => sink.close();
}
