import 'dart:async';

import 'package:meta/meta.dart';

import 'api_contract_violation_error.dart';
import 'single.dart';

/// DO NOT USE this extension.
extension TakeFirstDataOrFirstErrorExtension<T> on Stream<T> {
  /// DO NOT USE this extension.
  @internal
  Single<T> takeFirstDataOrFirstErrorAndClose() {
    final controller = isBroadcast
        ? StreamController<T>.broadcast(sync: true)
        : StreamController<T>(sync: true);
    StreamSubscription<T>? subscription;

    controller.onListen = () {
      subscription = listen(
        (v) {
          controller.add(v);

          // Closing also unsubscribes all subscribers, which unsubscribes
          // this from source.
          controller.close();
        },
        onError: (Object e, StackTrace s) {
          // cancelOnError=true cause the subscription to be canceled before
          // the error event is delivered to the listener.
          subscription = null;

          controller.addError(e, s);
          controller.close();
        },
        onDone: () {
          throw APIContractViolationError(
              'Internal API error! Please file a bug at: https://github.com/hoc081098/rxdart_ext/issues/new');
        },
        cancelOnError: true,
      );

      if (!isBroadcast) {
        controller.onPause = subscription!.pause;
        controller.onResume = subscription!.resume;
      }
    };
    controller.onCancel = () {
      final toCancel = subscription;
      subscription = null;
      return toCancel?.cancel();
    };

    return Single.safe(controller.stream);
  }
}
