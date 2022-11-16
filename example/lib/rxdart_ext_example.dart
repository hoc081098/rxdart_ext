import 'package:rxdart_ext/rxdart_ext.dart';

import 'utils.dart';

void main() async {
  await runDebugAndCollectOperatorExample();
  printSeparator();

  await runFlatMapBatchesSingleExample();
  printSeparator();

  await runRxSinglesZip2Example();
  printSeparator();

  await runRxSinglesUsingExample();
  printSeparator();

  await runDisposableMixinExample();
}

Future<void> runDebugAndCollectOperatorExample() async {
  Stream.fromIterable([1, 2, 3, 4]).debug(identifier: '[DEBUG]').collect();
  await delay(0);
}

Future<void> runFlatMapBatchesSingleExample() async {
  Stream.fromIterable([1, 2, 3, 4])
      .flatMapBatchesSingle(
          (v) => Single.timer(v, const Duration(milliseconds: 100)), 2)
      .debug(identifier: '[flatMapBatchesSingle]')
      .collect();
  await delay(500);
}

Future<void> runRxSinglesZip2Example() async {
  final state$ = StateSubject(1);
  state$.debug(identifier: '<<State>>').collect();
  print('<<State>> [1] state\$.value=${state$.value}');

  await RxSingles.zip2(
    Single.value(1).delay(const Duration(milliseconds: 100)),
    Single.fromCallable(() => delay(200).then((_) => 2)),
    (int v1, int v2) => v1 + v2,
  )
      .doOnData(state$.add)
      .forEach((_) => print('<<State>> [2] state\$.value=${state$.value}'));
}

class MyResource {
  var _disposed = false;

  MyResource() {
    print('[using] MyResource()');
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    print('[using] MyResource.dispose()');
  }

  Future<int> work() async {
    await delay(200);
    if (_disposed) {
      print('[using] MyResource.work() - disposed');
      throw Exception('MyResource is disposed');
    }
    return 42;
  }
}

Future<void> runRxSinglesUsingExample() async {
  final subscription = RxSingles.using<int, MyResource>(
    () => MyResource(),
    (r) => r.work().asSingle(),
    (r) => r.dispose(),
  ).debug(identifier: '[using]').collect();

  await delay(100);
  await subscription.cancel();
  await delay(200);
}

Future<void> runDisposableMixinExample() async {
  final dateTimeStream = BehaviorSubject<DateTime>.seeded(
    DateTime.now().toUtc(),
  );

  print('[DisposableMixin] Disposable example created');
  final disposableExample = DisposableExample(
    dateTimeStream: dateTimeStream,
  );

  print('[DisposableMixin] Periodic stream created');
  final periodicStreamSub = Stream<void>.periodic(
    const Duration(milliseconds: 100),
  ).listen((_) {
    final value = DateTime.now().toUtc();
    print('[DisposableMixin] Periodic stream emits: $value');
    dateTimeStream.add(value);
  });

  await delay(500);
  disposableExample.dispose();
  print('[DisposableMixin] Disposable example disposed');

  await delay(500);
  await periodicStreamSub.cancel();
  print('[DisposableMixin] Periodic stream disposed');
}

class DisposableExample with DisposableMixin {
  DisposableExample({
    required Stream<DateTime> dateTimeStream,
  }) {
    dateTimeStream.takeUntil(dispose$).listen(
          (value) =>
              print('[DisposableMixin] Disposable example receives: $value'),
        );
  }
}
