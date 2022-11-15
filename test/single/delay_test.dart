import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Single.delay', () {
    test('.success', () async {
      await singleRule(
        Single.value(1).delay(const Duration(milliseconds: 100)),
        Either.right(1),
      );
      await broadcastRule(
        Single.value(1).delay(const Duration(milliseconds: 100)),
        false,
      );
      await cancelRule(
          Single.value(1).delay(const Duration(milliseconds: 100)));

      Single.value(1)
          .delay(const Duration(milliseconds: 500))
          .timeInterval()
          .listen(expectAsync1(
            (v) => expect(v.interval.inMilliseconds, greaterThanOrEqualTo(500)),
            count: 1,
          ));
    });

    test('.failure', () async {
      await singleRule(
        Single<int>.error(Exception()).delay(const Duration(milliseconds: 100)),
        exceptionLeft,
      );
      await broadcastRule(
        Single<int>.error(Exception()).delay(const Duration(milliseconds: 100)),
        false,
      );
      await cancelRule(Single<int>.error(Exception()));
    });
  });
}
