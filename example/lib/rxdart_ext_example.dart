import 'package:rxdart_ext/rxdart_ext.dart';

void main() async {
  Stream.fromIterable([1, 2, 3, 4]).debug(identifier: '[DEBUG]').collect();
  await delay(0);

  Stream.fromIterable([1, 2, 3, 4])
      .flatMapBatchesSingle(
          (v) => Single.timer(v, const Duration(milliseconds: 100)), 2)
      .debug(identifier: '[flatMapBatchesSingle]')
      .collect();
  await delay(500);

  Stream.fromIterable(['1', '.', '3', '5', '@'])
      .mapNotNull(int.tryParse)
      .debug(identifier: '[mapNotNull]')
      .collect();
  await delay(0);

  final state$ = StateSubject(1);
  state$.debug(identifier: '<<State>>').collect();
  print('<<State>> ${state$.value}');

  await RxSingles.zip2(
    Single.value(1).delay(const Duration(milliseconds: 100)),
    Single.fromCallable(() => delay(200).then((_) => 2)),
    (int p0, int p1) => p0 + p1,
  ).doOnData(state$.add).forEach((_) => print('<<State>> ${state$.value}'));

  final dateTimeStream = BehaviorSubject<DateTime>.seeded(
    DateTime.now().toUtc(),
  );
  print('Disposable example created');
  final disposableExample = DisposableExample(
    dateTimeStream: dateTimeStream,
  );
  print('Periodic stream created');
  final periodicStreamSub = Stream.periodic(
    const Duration(milliseconds: 100),
  ).listen((_) {
    final value = DateTime.now().toUtc();
    print('Periodic stream: $value');
    dateTimeStream.add(value);
  });
  await delay(500);
  disposableExample.dispose();
  print('Disposable example disposed');
  await delay(500);
  periodicStreamSub.cancel();
  print('Periodic stream disposed');
}

class DisposableExample with Disposable {
  DisposableExample({
    required Stream<DateTime> dateTimeStream,
  }) {
    dateTimeStream.takeUntil(dispose$).listen(
          (value) => print('Disposable example: $value'),
        );
  }
}
