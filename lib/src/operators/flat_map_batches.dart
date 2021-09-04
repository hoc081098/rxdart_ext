import 'package:rxdart/rxdart.dart';

import '../single/internal.dart';
import '../single/single.dart';

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
        (List<R> values) => values,
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
        (List<R> values) => values,
      );
    }

    return bufferCount(maxConcurrent)
        .asyncExpand(convert)
        .scan<List<R>>((acc, value, _) => [...acc, ...value], [])
        .takeLast(1)
        .takeFirstDataOrFirstErrorAndClose();
  }
}
//
// Single<int> api(int count) {
//   return Single.fromCallable(() async {
//     print('Call.. $count');
//     await Future<void>.delayed(const Duration(seconds: 1));
//     return count;
//   });
// }
//
// void main() async {
//   final ids = List.generate(10, (index) => index);
//   Stream.fromIterable(ids)
//       .flatMapBatchesSingle(api, 3)
//       .listen(print, onError: print);
//
//   await Future<void>.delayed(const Duration(seconds: 2));
//
//   return;
//
//   await Rx.range(0, 10)
//       .flatMapBatches(
//         (p0) async* {
//           print('Start $p0, delay ${p0 % 3}');
//           await Future<void>.delayed(Duration(seconds: p0 % 3));
//           print('Done $p0');
//           yield p0;
//         },
//         3,
//       )
//       .scan<List<int>>((acc, value, index) => [...acc, ...value], <int>[])
//       .takeLast(1)
//       .forEach((v) => print('>>>>>>>>>>>>>>>>>>> $v'));
//
//   await Stream.fromIterable([
//     Stream.fromIterable([1, 2]),
//     Stream.fromIterable([1, 2]),
//     Stream.value(3),
//     Stream.value(4),
//   ]).flatMapBatches((p0) => p0, 2).forEach(print);
// }
