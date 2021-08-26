import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('doOn', () {
    test('works', () async {
      var i = 1;
      final sub = Rx.concat<int>([
        Stream.fromIterable([1, 2, 3]),
        Stream.error(Exception()),
        Stream.value(4),
      ])
          .doOn(
            listen: expectAsync0(() {}, count: 1),
            cancel: expectAsync0(() {}, count: 1),
            pause: expectAsync0(() {}, count: 1),
            resume: expectAsync0(() {}, count: 1),
            data: expectAsync1((v) => expect(v, i++), count: 4),
            error: expectAsync2((e, s) => expect(e, isException), count: 1),
            done: expectAsync0(() {}, count: 1),
            each: expectAsync1((n) {}, count: 6),
          )
          .map((event) => event)
          .whereNotNull()
          .listen(
            null,
            onError: (Object e, StackTrace s) {},
          );

      sub
        ..pause()
        ..resume();

      await Future<void>.delayed(const Duration(seconds: 10));
    });
  });
}
