import 'dart:async';

import '../utils/default_sink.dart';

final class _IgnoreErrorsEventSink<T> extends BaseEventSink<T, T> {
  _IgnoreErrorsEventSink(super.sink);

  @override
  void add(T event) => sink.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
}

/// Ignore all error events, forward only data and done event.
extension IgnoreErrorsStreamExtension<T> on Stream<T> {
  /// Ignore all error events, forward only data and done event.
  Stream<T> ignoreErrors() => Stream<T>.eventTransformed(
      this, (sink) => _IgnoreErrorsEventSink<T>(sink));
}
