import 'dart:async';

import 'package:meta/meta.dart';

import '../../single.dart';

/// DO NOT USE this extension.
@internal
extension TakeFirstDataOrFirstErrorExtension<T> on Stream<T> {
  /// DO NOT USE this extension.
  @internal
  Single<T> takeFirstDataOrFirstErrorAndClose() {
    final controller = isBroadcast
        ? StreamController<T>(sync: true)
        : StreamController<T>.broadcast(sync: true);
    StreamSubscription<T>? subscription;

    controller.onListen = () {
      subscription = listen(
        (v) {
          subscription!.cancel();
          subscription = null;

          controller.add(v);
          controller.close();
        },
        onError: (Object e, StackTrace s) {
          subscription!.cancel();
          subscription = null;

          controller.addError(e, s);
          controller.close();
        },
        onDone: () {
          throw APIContractViolationError(
              'Internal API error! Please file a bug at: https://github.com/hoc081098/rxdart_ext/issues/new');
        },
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
