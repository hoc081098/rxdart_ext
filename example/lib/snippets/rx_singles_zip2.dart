import 'package:rxdart_ext/rxdart_ext.dart';

Future<void> runRxSinglesZip2Example() async {
  final state$ = StateSubject(1);
  state$.debug(identifier: '[zip2] state').collect();
  print('[zip2] Initial state=${state$.value}');

  await RxSingles.zip2(
    Single.value(1).delay(const Duration(milliseconds: 100)),
    Single.fromCallable(() => delay(200).then((_) => 2)),
    (int v1, int v2) => v1 + v2,
  )
      .doOnData(state$.add)
      .forEach((_) => print('[zip2] Emits state=${state$.value}'));
}
