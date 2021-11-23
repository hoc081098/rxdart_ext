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
}
