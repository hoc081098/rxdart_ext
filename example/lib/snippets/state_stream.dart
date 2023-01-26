import 'package:rxdart_ext/rxdart_ext.dart';

Future<void> runStateStreamExample() async {
  final StateSubject<int> state$ = StateSubject(0);
  final subscription = state$.debug(identifier: '[StateStream]').collect();

  state$.value++;
  state$.update((value) => value + 1);
  state$.updateAndGet((value) => value + 1);
  state$.getAndUpdate((value) => value + 1);

  await delay(100);
  await subscription.cancel();
}
