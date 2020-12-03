import 'dart:async';

/// Ignore all data events, forward error and done event.
extension IgnoreElementStreamExtension<T> on Stream<T> {
  /// Ignore all data events, forward error and done event.
  Stream<R> ignoreElements<R>() {
    return transform<R>(
      StreamTransformer.fromHandlers(
        handleData: (_, sink) {},
        handleError: (e, s, sink) => sink.addError(e, s),
        handleDone: (sink) => sink.close(),
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
        handleData: (data, sink) => sink.add(data),
        handleError: (e, s, sink) {},
        handleDone: (sink) => sink.close(),
      ),
    );
  }
}
