import 'package:rxdart/rxdart.dart';

/// TODO
extension FlatMapBatchesStreamExtension<T> on Stream<T> {
  Stream<List<R>> flatMapBatches<R>(Stream<R> Function(T) transform, int max) {
    Stream<List<R>> convert(List<T> streams) {
      return Rx.zip(
        streams.map(transform).toList(growable: false),
        (List<R> values) => values,
      );
    }

    return bufferCount(max).asyncExpand(convert);
  }
}

void main() async {
  await Rx.range(0, 10)
      .flatMapBatches(
        (p0) async* {
          print('Start $p0, delay ${p0 % 3}');
          await Future<void>.delayed(Duration(seconds: p0 % 3));
          print('Done $p0');
          yield p0;
        },
        3,
      )
      .scan<List<int>>((acc, value, index) => [...acc, ...value], <int>[])
      .takeLast(1)
      .forEach((v) => print('>>>>>>>>>>>>>>>>>>> $v'));

  await Stream.fromIterable([
    Stream.fromIterable([1, 2]),
    Stream.fromIterable([1, 2]),
    Stream.value(3),
    Stream.value(4),
  ]).flatMapBatches((p0) => p0, 2).forEach(print);
}
