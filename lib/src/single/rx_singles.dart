import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'internal.dart';
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
      Rx.zip2(singleA, singleB, zipper).takeFirstDataOrFirstErrorAndClose();

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
          .takeFirstDataOrFirstErrorAndClose();
}
