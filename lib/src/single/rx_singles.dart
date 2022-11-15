import 'dart:async';

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

  /// When listener listens to it, creates a resource object from resource factory function,
  /// and creates a [Single] from the given factory function and resource as argument.
  /// Finally when the Single finishes emitting items or stream subscription
  /// is cancelled (call [StreamSubscription.cancel] or `Single.listen(cancelOnError: true)`),
  /// call the disposer function on resource object.
  ///
  /// This method is a way you can instruct an Single to create
  /// a resource that exists only during the lifespan of the Single
  /// and is disposed of when the Single terminates.
  ///
  /// The returned [Single] is single-subscription Stream.
  ///
  /// [Marble diagram](http://reactivex.io/documentation/operators/images/using.c.png)
  ///
  /// ### Example
  ///
  ///     class Resource {
  ///       void close() => print('Closed');
  ///       int get value => 0;
  ///     }
  ///
  ///     RxSingles.using<int, Resource>(
  ///       () => Resource(),
  ///       (r) => Single.value(r.value),
  ///       (r) => r.close(),
  ///     ).listen(print); // prints 0, Closed
  ///
  /// See [Rx.using] and [UsingStream].
  static Single<T> using<T, R>(
    R Function() resourceFactory,
    Single<T> Function(R) singleFactory,
    FutureOr<void> Function(R) disposer,
  ) =>
      Single.safe(
        Rx.using(
          resourceFactory,
          singleFactory,
          disposer,
        ),
      );
}
