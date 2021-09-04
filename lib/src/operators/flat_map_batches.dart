import 'package:rxdart/rxdart.dart';

import '../single/internal.dart';
import '../single/single.dart';
import '../utils/identity.dart';

/// TODO
extension FlatMapBatchesStreamExtension<T> on Stream<T> {
  /// TODO
  Stream<List<R>> flatMapBatches<R>(
    Stream<R> Function(T) transform,
    int maxConcurrent,
  ) {
    Stream<List<R>> convert(List<T> streams) {
      return Rx.zip(
        streams.map(transform).toList(growable: false),
        identity,
      );
    }

    return bufferCount(maxConcurrent).asyncExpand(convert);
  }

  /// TODO
  Single<List<R>> flatMapBatchesSingle<R>(
    Single<R> Function(T) transform,
    int maxConcurrent,
  ) {
    Stream<List<R>> convert(List<T> streams) {
      return Rx.forkJoin(
        streams.map(transform).toList(growable: false),
        identity,
      );
    }

    return bufferCount(maxConcurrent)
        .asyncExpand(convert)
        .scan<List<R>>((acc, value, _) => acc..addAll(value), [])
        .takeLast(1)
        .map((value) => List<R>.unmodifiable(value))
        .takeFirstDataOrFirstErrorAndClose();
  }
}
