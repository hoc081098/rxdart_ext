import 'dart:async';

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

/// Ignore all error events, forward data and done event.
extension IgnoreErrorsStreamExtension<T> on Stream<T> {
  /// Ignore all error events, forward data and done event.
  Stream<T> ignoreErrors() {
    return transform<T>(
      StreamTransformer.fromHandlers(
        handleError: (e, s, sink) {},
      ),
    );
  }
}
