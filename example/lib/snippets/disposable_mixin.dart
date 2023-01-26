import 'package:rxdart_ext/rxdart_ext.dart';

Future<void> runDisposableMixinExample() async {
  final dateTimeStream = BehaviorSubject<DateTime>.seeded(
    DateTime.now().toUtc(),
  );

  print('[DisposableMixin] Created');
  final disposableExample = DisposableExample(
    dateTimeStream: dateTimeStream,
  );

  print('[DisposableMixin] Stream created');
  final periodicStreamSub = Stream<void>.periodic(
    const Duration(milliseconds: 100),
  ).listen((_) {
    final value = DateTime.now().toUtc();
    print('[DisposableMixin] Emits >>> : $value');
    dateTimeStream.add(value);
  });

  await delay(500);
  disposableExample.dispose();
  print('[DisposableMixin] Disposed');

  await delay(500);
  await periodicStreamSub.cancel();
  print('[DisposableMixin] Stream disposed');
}

class DisposableExample with DisposableMixin {
  DisposableExample({
    required Stream<DateTime> dateTimeStream,
  }) {
    dateTimeStream.takeUntil(dispose$).listen(
          (value) => print('[DisposableMixin] Receives <<< : $value'),
        );
  }
}
