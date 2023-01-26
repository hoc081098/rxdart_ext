import 'package:rxdart_ext/rxdart_ext.dart';

Future<void> runFlatMapBatchesSingleExample() async {
  Stream.fromIterable([1, 2, 3, 4])
      .flatMapBatchesSingle(
          (v) => Single.timer(v, const Duration(milliseconds: 100)), 2)
      .debug(identifier: '[flatMapBatchesSingle]')
      .collect();
  await delay(500);
}
