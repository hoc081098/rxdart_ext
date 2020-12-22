import 'dart:async';

/// Converts a broadcast Stream into a single-subscription Stream.
extension ToSingleSubscriptionStreamExtension<T> on Stream<T> {
  /// Converts a broadcast Stream into a single-subscription Stream.
  Stream<T> toSingleSubscriptionStream() {
    assert(isBroadcast);

    late StreamSubscription<T> subscription;

    final controller = StreamController<T>(sync: true);
    controller.onListen = () {
      subscription = listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
    };
    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }
}
