import 'dart:async';

import 'default_sink.dart';

class _IgnoreElementsStreamSink<T>
    with ForwardingSinkMixin<T, T>
    implements ForwardingSink<T, T> {
  @override
  void add(EventSink<T> sink, T data) {}
}

/// Ignore all data events, forward only error and done event.
extension IgnoreElementStreamExtension<T> on Stream<T> {
  /// Ignore all data events, forward only error and done event.
  Stream<R> ignoreElements<R>() =>
      forwardStream(this, _IgnoreElementsStreamSink());
}

class _IgnoreErrorsStreamSink<T>
    with ForwardingSinkMixin<T, T>
    implements ForwardingSink<T, T> {
  @override
  void add(EventSink<T> sink, T data) => sink.add(data);

  @override
  void addError(EventSink<T> sink, Object error, [StackTrace? st]) {}
}

/// Ignore all error events, forward only data and done event.
extension IgnoreErrorsStreamExtension<T> on Stream<T> {
  /// Ignore all error events, forward only data and done event.
  Stream<T> ignoreErrors() => forwardStream(this, _IgnoreErrorsStreamSink());
}
