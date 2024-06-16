import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'internal.dart';
import 'single.dart';

/// A utility class that provides static methods to create the various [Single]s
/// provided by `rxdart_ext`.
///
/// Similar to [Rx] of `rxdart`, but for [Single]s.
@sealed
abstract class RxSingles {
  RxSingles._();

  //
  //--------------------------------- ZIP ---------------------------------------
  //

  /// Merges the specified [Single]s into one [Single] sequence using the given
  /// [zipper] function whenever all of the [Single] sequences have produced
  /// an element.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
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

  //
  //------------------------------ FORK JOIN ------------------------------------
  //

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
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

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
  /// The returned [Single] is single-subscription Stream.
  ///
  /// ## Marble
  ///
  /// ```text
  /// singleA: ----------a|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// result : ---------------------abc|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// result : ----------x|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------x|
  /// singleC: ---------------------x|
  /// result : ----------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// See [Rx.forkJoin3] and [ForkJoinStream].
  static Single<T> forkJoin3<A, B, C, T>(
    Single<A> singleA,
    Single<B> singleB,
    Single<C> singleC,
    T Function(A, B, C) combiner,
  ) =>
      Rx.forkJoin3(singleA, singleB, singleC, combiner)
          .takeFirstDataOrFirstErrorAndClose();

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
  /// The returned [Single] is single-subscription Stream.
  ///
  /// ## Marble
  ///
  /// ```text
  /// singleA: ----------a|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: -----------------------------d|
  /// result : -----------------------------abcd|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: -----------------------------d|
  /// result : ----------x|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------x|
  /// singleC: ---------------------x|
  /// singleD: -----------------------------x|
  /// result : ----------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// See [Rx.forkJoin4] and [ForkJoinStream].
  static Single<T> forkJoin4<A, B, C, D, T>(
    Single<A> singleA,
    Single<B> singleB,
    Single<C> singleC,
    Single<D> singleD,
    T Function(A, B, C, D) combiner,
  ) =>
      Rx.forkJoin4(singleA, singleB, singleC, singleD, combiner)
          .takeFirstDataOrFirstErrorAndClose();

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
  /// The returned [Single] is single-subscription Stream.
  ///
  /// ## Marble
  ///
  /// ```text
  /// singleA: ----------a|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// result : -------------------------------abcde|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// result : ----------x|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------x|
  /// singleC: ---------------------x|
  /// singleD: --------------------------x|
  /// singleE: --------------------------------x|
  /// result : ----------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// See [Rx.forkJoin5] and [ForkJoinStream].
  static Single<T> forkJoin5<A, B, C, D, E, T>(
    Single<A> singleA,
    Single<B> singleB,
    Single<C> singleC,
    Single<D> singleD,
    Single<E> singleE,
    T Function(A, B, C, D, E) combiner,
  ) =>
      Rx.forkJoin5(singleA, singleB, singleC, singleD, singleE, combiner)
          .takeFirstDataOrFirstErrorAndClose();

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
  /// The returned [Single] is single-subscription Stream.
  ///
  /// ## Marble
  ///
  /// ```text
  /// singleA: ----------a|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// singleF: ------------------------------------f|
  /// result : ------------------------------------abcdef|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// singleF: ------------------------------------f|
  /// result : ----------x|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------x|
  /// singleC: ---------------------x|
  /// singleD: --------------------------x|
  /// singleE: --------------------------------x|
  /// singleF: ------------------------------------x|
  /// result : ----------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// See [Rx.forkJoin6] and [ForkJoinStream].
  static Single<T> forkJoin6<A, B, C, D, E, F, T>(
    Single<A> singleA,
    Single<B> singleB,
    Single<C> singleC,
    Single<D> singleD,
    Single<E> singleE,
    Single<F> singleF,
    T Function(A, B, C, D, E, F) combiner,
  ) =>
      Rx.forkJoin6(
              singleA, singleB, singleC, singleD, singleE, singleF, combiner)
          .takeFirstDataOrFirstErrorAndClose();

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
  /// The returned [Single] is single-subscription Stream.
  ///
  /// ## Marble
  ///
  /// ```text
  /// singleA: ----------a|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// singleF: ------------------------------------f|
  /// singleG: ---------------------------------------g|
  /// result : ---------------------------------------abcdefg|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// singleF: -----------------------------------f|
  /// singleG: ---------------------------------------g|
  /// result : ----------x|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------x|
  /// singleC: ---------------------x|
  /// singleD: --------------------------x|
  /// singleE: --------------------------------x|
  /// singleF: ------------------------------------x|
  /// singleG: ---------------------------------------x|
  /// result : ----------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// See [Rx.forkJoin7] and [ForkJoinStream].
  static Single<T> forkJoin7<A, B, C, D, E, F, G, T>(
    Single<A> singleA,
    Single<B> singleB,
    Single<C> singleC,
    Single<D> singleD,
    Single<E> singleE,
    Single<F> singleF,
    Single<G> singleG,
    T Function(A, B, C, D, E, F, G) combiner,
  ) =>
      Rx.forkJoin7(singleA, singleB, singleC, singleD, singleE, singleF,
              singleG, combiner)
          .takeFirstDataOrFirstErrorAndClose();

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
  /// The returned [Single] is single-subscription Stream.
  ///
  /// ## Marble
  ///
  /// ```text
  /// singleA: ----------a|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// singleF: ------------------------------------f|
  /// singleG: ---------------------------------------g|
  /// singleH: ------------------------------------------h|
  /// result : ------------------------------------------abcdefgh|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// singleF: -----------------------------------f|
  /// singleG: ---------------------------------------g|
  /// singleH: ------------------------------------------h|
  /// result : ----------x|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------x|
  /// singleC: ---------------------x|
  /// singleD: --------------------------x|
  /// singleE: --------------------------------x|
  /// singleF: ------------------------------------x|
  /// singleG: ---------------------------------------x|
  /// singleH: ------------------------------------------x|
  /// result : ----------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// See [Rx.forkJoin8] and [ForkJoinStream].
  static Single<T> forkJoin8<A, B, C, D, E, F, G, H, T>(
    Single<A> singleA,
    Single<B> singleB,
    Single<C> singleC,
    Single<D> singleD,
    Single<E> singleE,
    Single<F> singleF,
    Single<G> singleG,
    Single<H> singleH,
    T Function(A, B, C, D, E, F, G, H) combiner,
  ) =>
      Rx.forkJoin8(singleA, singleB, singleC, singleD, singleE, singleF,
              singleG, singleH, combiner)
          .takeFirstDataOrFirstErrorAndClose();

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
  /// The returned [Single] is single-subscription Stream.
  ///
  /// ## Marble
  ///
  /// ```text
  /// singleA: ----------a|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// singleF: ------------------------------------f|
  /// singleG: ---------------------------------------g|
  /// singleH: ------------------------------------------h|
  /// singleI: ---------------------------------------------i|
  /// result : ---------------------------------------------abcdefghi|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------b|
  /// singleC: ---------------------c|
  /// singleD: --------------------------d|
  /// singleE: -------------------------------e|
  /// singleF: -----------------------------------f|
  /// singleG: ---------------------------------------g|
  /// singleH: ------------------------------------------h|
  /// singleI: ---------------------------------------------i|
  /// result : ----------x|
  ///
  /// singleA: ----------x|
  /// singleB: ---------------x|
  /// singleC: ---------------------x|
  /// singleD: --------------------------x|
  /// singleE: -------------------------------x|
  /// singleF: ------------------------------------x|
  /// singleG: ---------------------------------------x|
  /// singleH: ------------------------------------------x|
  /// singleI: ---------------------------------------------x|
  /// result : ----------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// See [Rx.forkJoin9] and [ForkJoinStream].
  static Single<T> forkJoin9<A, B, C, D, E, F, G, H, I, T>(
    Single<A> singleA,
    Single<B> singleB,
    Single<C> singleC,
    Single<D> singleD,
    Single<E> singleE,
    Single<F> singleF,
    Single<G> singleG,
    Single<H> singleH,
    Single<I> singleI,
    T Function(A, B, C, D, E, F, G, H, I) combiner,
  ) =>
      Rx.forkJoin9(singleA, singleB, singleC, singleD, singleE, singleF,
              singleG, singleH, singleI, combiner)
          .takeFirstDataOrFirstErrorAndClose();

  /// Merges the given [Single]s into a single [Single] sequence by using the
  /// [combiner] function when all of the [Single] sequences emits their
  /// last item.
  ///
  /// When the first data event or error event is emitted,
  /// the returned [Single] will emit that event and then close with a done-event.
  /// The returned [Single] is single-subscription Stream.
  ///
  /// See [Rx.forkJoinList] and [ForkJoinStream].
  static Single<List<T>> forkJoinList<T>(Iterable<Single<T>> singles) =>
      Rx.forkJoinList(singles).takeFirstDataOrFirstErrorAndClose();

  //
  //-------------------------------- USING --------------------------------------
  //

  /// When listener listens to it, creates a resource object from resource factory function,
  /// and creates a [Single] from the given factory function and resource as argument.
  /// Finally when the Single finishes emitting items or stream subscription
  /// is cancelled (call [StreamSubscription.cancel] or `Single.listen(cancelOnError: true)`),
  /// call the disposer function on resource object.
  ///
  /// This method is a way you can instruct a Single to create
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
  ///       resourceFactory: () => Resource(),
  ///       singleFactory: (r) => Single.value(r.value),
  ///       disposer: (r) => r.close(),
  ///     ).listen(print); // prints 0, Closed
  ///
  /// See [Rx.using] and [UsingStream].
  static Single<T> using<T, R>({
    required R Function() resourceFactory,
    required Single<T> Function(R) singleFactory,
    required FutureOr<void> Function(R) disposer,
  }) =>
      Single.safe(
        Rx.using(
          resourceFactory: resourceFactory,
          streamFactory: singleFactory,
          disposer: disposer,
        ),
      );
}
