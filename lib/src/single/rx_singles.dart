import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'api_contract_violation_error.dart';
import 'single.dart';

/// A utility class that provides static methods to create the various [Single]s
/// provided by `rxdart_ext`.
///
/// Similar to [Rx] of `rxdart`, but for [Single].
@sealed
abstract class RxSingles {
  /// Merges the specified [Single]s into one [Single] sequence using the given
  /// [zipper] function whenever all of the [Single] sequences have produced
  /// an element.
  ///
  /// The returned [Single] is single-subscription Stream.
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
  ) =>
      Rx.zip2(singleA, singleB, zipper)._takeFirstDataOrFirstErrorAndClose();

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// The returned [Single] is single-subscription Stream.
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
  /// See [Rx.forkJoin2] and [ForkJoinStream].
  static Single<T> forkJoin2<A, B, T>(
    Single<A> singleA,
    Single<B> singleB,
    T Function(A, B) combiner,
  ) =>
      Rx.forkJoin2(singleA, singleB, combiner)
          ._takeFirstDataOrFirstErrorAndClose();
}

extension _TakeFirstDataOrFirstErrorExtension<T> on Stream<T> {
  Single<T> _takeFirstDataOrFirstErrorAndClose() {
    final controller = StreamController<T>(sync: true);
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
