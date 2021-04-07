import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('asVoid', () {
    test('.works', () {
      expect(
        Stream.fromIterable([1, 2, 3, 4]).asVoid(),
        isA<Stream<void>>(),
      );
      expect(
        Stream.fromIterable([1, 2, 3, 4]).asVoid(),
        emitsInOrder(<Matcher>[isNull, isNull, isNull, isNull]),
      );
    });

    test('.shouldThrow', () {
      expect(
        Stream<bool>.error(Exception()).asVoid(),
        emitsError(isA<Exception>()),
      );

      expect(
        Rx.concat<int?>([
          Stream.fromIterable([1, 2]),
          Stream.error(Exception()),
          Stream.value(3),
        ]).asVoid(),
        emitsInOrder(<dynamic>[
          null,
          null,
          emitsError(isException),
          null,
          emitsDone,
        ]),
      );
    });

    test('.asBroadcastStream', () {
      final stream =
          Stream.fromIterable([1, 2, null]).asVoid().asBroadcastStream();

      // listen twice on same stream
      stream.listen(null);
      stream.listen(null);

      // code should reach here
      expect(true, true);
    });

    test('.singleSubscription', () {
      final stream = StreamController<int?>().stream.asVoid();

      expect(stream.isBroadcast, isFalse);
      stream.listen(null);
      expect(() => stream.listen(null), throwsStateError);
    });

    test('.pause.resume', () async {
      final subscription =
          Stream.fromIterable([1, 2, 3, null, 4, 5, 6]).asVoid().listen(null);

      subscription
        ..pause()
        ..onData(expectAsync1((data) {
          expect(data as dynamic, null);
          subscription.cancel();
        }))
        ..resume();
    });
  });
}
