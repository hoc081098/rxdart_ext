import 'package:rxdart_ext/rxdart_ext.dart';

void main() {
  Stream.fromIterable([1, 2, 3, 4]).debug().collect();

  final state$ = StateSubject(1);
  state$.debug(identifier: '<<State>>').collect();
  print(state$.value);

  RxSingles.zip2(
    Single.value(1).delay(const Duration(milliseconds: 100)),
    Single.fromCallable(
        () => Future.delayed(const Duration(milliseconds: 200), () => 2)),
    (int p0, int p1) => p0 + p1,
  ).doOnData(state$.add).listen((_) => print(state$.value));
}
