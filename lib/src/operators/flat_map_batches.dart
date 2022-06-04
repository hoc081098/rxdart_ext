import 'package:rxdart/rxdart.dart';

import '../single/single.dart';
import '../single/single_or_error.dart';
import 'done_on_error.dart';

/// Extends the Stream class with the ability to convert each element to a [Stream],
/// then listen to at most `size` [Stream](s) at a time
/// and outputs their results in `size`-sized batches, while maintaining
/// order within each batch — subsequent batches of [Stream]s are only
/// listened to when the batch before it successfully completes.
extension FlatMapBatchesStreamExtension<T> on Stream<T> {
  /// Convert each element to a [Stream], then listen to at most `size` [Stream](s)
  /// at a time and outputs their results in `size`-sized batches, while maintaining
  /// order within each batch — subsequent batches of [Stream]s are only
  /// listened to when the batch before it successfully completes.
  /// Errors will be forwarded downstream.
  ///
  /// ### Marble
  ///
  /// ```text
  /// input     : --a---b---c---x---d-------e--|
  /// transform : a -> a| (Stream.value)
  /// size      : 3
  /// output    : --------[a,b,c]---x----------[d,e]--|
  ///
  /// NOTE: x is error event
  /// ```
  Stream<List<R>> flatMapBatches<R>(
    Stream<R> Function(T value) transform,
    int size,
  ) {
    Stream<List<R>> convert(List<T> streams) =>
        Rx.zipList(streams.map(transform).toList(growable: false));

    return bufferCount(size).asyncExpand(convert);
  }

  /// Similar to [flatMapBatches], but collect all output result batches into a [List],
  /// and emit final result as a [Single] when source [Stream] emits done event.
  ///
  /// If source [Stream] is empty, returns a [Single] that emits a empty list.
  /// Errors will be forwarded downstream, the first will cause the returned [Single]
  /// completes with that error.
  ///
  /// ```text
  /// input     : --|
  /// transform : a -> a| (Single.value)
  /// size      : 2
  /// output    : --[]|
  ///
  /// input     : --a---b---c----d--e--|
  /// transform : a -> a| (Single.value)
  /// size      : 3
  /// output    : --------------[a,b,c,d,e]|
  ///
  /// input     : --a---b---c--x--d--e--|
  /// transform : a -> a| (Single.value)
  /// size      : 3
  /// output    : ----------x|
  ///
  /// input     : --a---b---c--x--d--e--|
  /// transform : a -> x| (Single.error)
  /// size      : 3
  /// output    : --x|
  ///
  /// NOTE: x is error event
  /// ```
  Single<List<R>> flatMapBatchesSingle<R>(
    Single<R> Function(T value) transform,
    int size,
  ) {
    Stream<List<R>> convert(List<T> streams) =>
        Rx.forkJoinList(streams.map(transform).toList(growable: false));

    final seed = <R>[];
    return bufferCount(size)
        .asyncExpand(convert)
        .startWith(seed)
        .scan<List<R>>((acc, value, _) => acc..addAll(value), seed)
        .takeLast(1)
        .map((value) => List<R>.unmodifiable(value))
        .doneOnError()
        .singleOrError();
  }
}
