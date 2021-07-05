import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart' show forwardStream;

import 'single/single.dart';

export 'package:rxdart/src/utils/forwarding_sink.dart' show ForwardingSink;

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

/// TODO
abstract class BaseEventSink<T, R> implements EventSink<T> {
  @protected
  final EventSink<R> sink;

  /// TODO
  @visibleForOverriding
  BaseEventSink(this.sink);

  @override
  void add(T event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      sink.addError(error, stackTrace);

  @override
  void close() => sink.close();
}

/// Forward [Single] events.
extension ForwardSingleExtension<T> on Single<T> {
  /// Helper method which forwards the events from an incoming [Single]
  /// to a new [Single].
  /// It captures events such as onListen, onPause, onResume and onCancel,
  /// which can be used in pair with a [ForwardingSink].
  Single<R> forwardSingleWithSink<R>(ForwardingSink<T, R> sink) =>
      Single.safe(forwardStream(stream, sink));
}

/// Forward [Stream] events.
extension ForwardStreamExtension<T> on Stream<T> {
  /// Helper method which forwards the events from an incoming [Stream]
  /// to a new [StreamController].
  /// It captures events such as onListen, onPause, onResume and onCancel,
  /// which can be used in pair with a [ForwardingSink]
  Stream<R> forwardStreamWithSink<R>(ForwardingSink<T, R> sink) =>
      forwardStream(this, sink);
}
