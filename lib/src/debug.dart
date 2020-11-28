import 'dart:async';

import 'package:rxdart/rxdart.dart'
    show DoStreamTransformer, Kind, Notification;

extension _NotificationDescriptionExt<T> on Notification<T> {
  String get description {
    switch (kind) {
      case Kind.OnData:
        return 'data($requiredData)';
      case Kind.OnDone:
        return 'done';
      case Kind.OnError:
        final error = errorAndStackTrace!;
        return 'error(${error.error}, ${error.stackTrace})';
    }
  }
}

///
extension DebugStreamExtension<T> on Stream<T> {
  ///
  Stream<T> debug([
    String identifier = 'Debug',
    void Function(String) log = print,
  ]) {
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

/// TODO
extension ListenNullStreamExtension<T> on Stream<T> {
  StreamSubscription<T> listenNull() => listen(null);
}
