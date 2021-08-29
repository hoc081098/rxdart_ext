import 'dart:async';

/// Converts a broadcast Stream into a single-subscription Stream.
extension ToSingleSubscriptionStreamExtension<T> on Stream<T> {
  /// Converts a broadcast Stream into a single-subscription Stream.
  /// If this [Stream] is single-subscription Stream, just return it.
  Stream<T> toSingleSubscriptionStream() {
    if (!isBroadcast) {
      return this;
    }

    StreamSubscription<T>? subscription;

    final controller = StreamController<T>(sync: true);
    controller.onListen = () {
      subscription = listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
    };
    controller.onCancel = () {
      final cancel = subscription?.cancel();
      subscription = null;
      return cancel;
    };

    return controller.stream;
  }
}
