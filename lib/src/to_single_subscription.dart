import 'dart:async';

/// A transformer that converts a broadcast stream into a single-subscription
/// stream.
class _SingleSubscriptionTransformer<T> extends StreamTransformerBase<T, T> {
  ///
  const _SingleSubscriptionTransformer();

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamSubscription<T> subscription;
    late StreamController<T> controller;

    controller = StreamController<T>(
      sync: true,
      onListen: () {
        subscription = stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onCancel: () => subscription.cancel(),
    );

    return controller.stream;
  }
}

///
extension ToSingleSubscriptionStreamExtension<T> on Stream<T> {
  ///
  Stream<T> toSingleSubscriptionStream() =>
      transform(_SingleSubscriptionTransformer<T>());
}
