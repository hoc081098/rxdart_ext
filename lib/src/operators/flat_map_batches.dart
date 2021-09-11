import 'package:rxdart/rxdart.dart';

import '../single/internal.dart';
import '../single/single.dart';
import '../utils/identity.dart';

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
    Stream<List<R>> convert(List<T> streams) {
      return Rx.zip(
        streams.map(transform).toList(growable: false),
        identity,
      );
    }

    return bufferCount(size).asyncExpand(convert);
  }

  /// Similar to [flatMapBatches], but collect all output result batches into a [List],
  /// and emit final result when source [Stream] emits done event.
  /// ```text
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
    Stream<List<R>> convert(List<T> streams) {
      return Rx.forkJoin(
        streams.map(transform).toList(growable: false),
        identity,
      );
    }

    return bufferCount(size)
        .asyncExpand(convert)
        .scan<List<R>>((acc, value, _) => acc..addAll(value), [])
        .takeLast(1)
        .map((value) => List<R>.unmodifiable(value))
        .takeFirstDataOrFirstErrorAndClose();
  }
}
