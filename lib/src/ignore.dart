import 'dart:async';

import 'default_sink.dart';

/// Ignore all data events, forward error and done event.
extension IgnoreElementStreamExtension<T> on Stream<T> {
  /// Ignore all data events, forward error and done event.
  Stream<R> ignoreElements<R>() {
    return transform<R>(
      StreamTransformer.fromHandlers(
        handleData: (_, sink) {},
      ),
    );
  }
}

class _IgnoreErrorsStreamSink<T>
    with ForwardingSinkMixin<T, T>
    implements ForwardingSink<T, T> {
  @override
  void add(EventSink<T> sink, T data) {}

  @override
  void addError(EventSink<T> sink, Object error, [StackTrace? st]) {}
}

/// Ignore all error events, forward data and done event.
extension IgnoreErrorsStreamExtension<T> on Stream<T> {
  /// Ignore all error events, forward data and done event.
  Stream<T> ignoreErrors() => forwardStream(this, _IgnoreErrorsStreamSink());
}
