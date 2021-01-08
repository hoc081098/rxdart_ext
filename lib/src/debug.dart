import 'dart:async';

import 'package:rxdart/rxdart.dart'
    show DoStreamTransformer, Kind, Notification;

extension _NotificationDescriptionExt<T> on Notification<T> {
  String get description {
    switch (kind) {
      case Kind.OnData:
        return 'data($requireData)';
      case Kind.OnDone:
        return 'done';
      case Kind.OnError:
        final error = errorAndStackTrace!;
        return 'error(${error.error}, ${error.stackTrace})';
    }
  }
}

/// Prints received events for all listeners on standard output.
extension DebugStreamExtension<T> on Stream<T> {
  /// Prints received events for all listeners on standard output.
  /// The [identifier] is printed together with event description to standard output.
  Stream<T> debug({
    String identifier = 'Debug',
    void Function(String) log = print,
  }) {
    void logEvent(String content) =>
        log('${DateTime.now()}: $identifier -> $content');

    return transform(
      DoStreamTransformer(
        onEach: (notification) => logEvent('Event ${notification.description}'),
        onListen: () => logEvent('Listened'),
        onCancel: () => logEvent('Cancelled'),
        onPause: () => logEvent('Paused'),
        onResume: () => logEvent('Resumed'),
      ),
    );
  }
}

/// Listen without any handler.
extension ListenNullStreamExtension<T> on Stream<T> {
  /// Listen without any handler.
  CollectStreamSubscription<T> collect() =>
      CollectStreamSubscription(listen(null));
}

/// A [StreamSubscription] cannot replace any handler.
class CollectStreamSubscription<T> extends StreamSubscription<T> {
  final StreamSubscription<T> _delegate;

  /// Construct a [CollectStreamSubscription] that delegates all implementation to other [StreamSubscription].
  CollectStreamSubscription(this._delegate);

  @override
  Future<E> asFuture<E>([E? futureValue]) => _delegate.asFuture(futureValue);

  @override
  Future<void> cancel() => _delegate.cancel();

  @override
  bool get isPaused => _delegate.isPaused;

  @override
  void onData(void Function(T data)? handleData) =>
      throw StateError('Cannot change onData');

  @override
  void onDone(void Function()? handleDone) =>
      throw StateError('Cannot change onDone');

  @override
  void onError(Function? handleError) =>
      throw StateError('Cannot change onError');

  @override
  void pause([Future<void>? resumeSignal]) => _delegate.pause(resumeSignal);

  @override
  void resume() => _delegate.resume();
}
