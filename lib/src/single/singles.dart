import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'single.dart';

abstract class Singles {
  Singles._();

  /// Merges the specified [Single]s into one [Single] sequence using the given
  /// [zipper] function whenever all of the [Single] sequences have produced
  /// an element.
  ///
  /// ## Marble
  ///
  /// ```text
  /// singleA: ----------a|
  /// singleB: ---------------b|
  /// result : ---------------ab|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------b|
  /// result : ----------x|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------x|
  /// result : ----------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#zip)
  ///
  /// See [Rx.zip2] and [ZipStream].
  static Single<T> zip2<A, B, T>(
    Single<A> singleA,
    Single<B> singleB,
    T Function(A, B) zipper,
  ) {
    final controller = StreamController<T>(sync: true);
    StreamSubscription<T>? subscription;

    controller.onListen = () {
      subscription = Rx.zip2(singleA, singleB, zipper).listen(
        (v) {
          controller.add(v);
          controller.close();
        },
        onError: (Object e, StackTrace s) {
          controller.addError(e, s);
          controller.close();
        },
        onDone: controller.close,
      );
    };
    controller.onPause = () => subscription!.pause();
    controller.onResume = () => subscription!.resume();
    controller.onCancel = () {
      final toCancel = subscription;
      subscription = null;
      return toCancel?.cancel();
    };

    return Single.safe(controller.stream);
  }
}
