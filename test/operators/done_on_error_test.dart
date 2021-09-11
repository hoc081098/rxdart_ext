import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('doneOnError', () {
    test('works', () {
      expect(
        Rx.concat<int>([
          Stream.fromIterable([1, 2, 3]),
          Stream.error(Exception('1')),
          Stream.value(4),
          Stream.error(Exception('2')),
          Stream.fromIterable([5, 6, 7]),
        ]).doneOnError(),
        emitsInOrder(<Object>[1, 2, 3, emitsError(isException), emitsDone]),
      ); // prints 1, 2, 3, Exception: 1

      expect(
        Rx.concat<int>([
          Stream.fromIterable([1, 2, 3]),
          Stream.error(Exception('1')),
          Stream.value(4),
          Stream.error(Exception('2')),
          Stream.fromIterable([5, 6, 7]),
        ]).doneOnError(
            (e, s) => e is Exception && e.toString() == 'Exception: 2'),
        emitsInOrder(<Object>[
          1,
          2,
          3,
          emitsError(isException),
          4,
          emitsError(isException),
          emitsDone,
        ]),
      );
    });

    test('should catch error thrown from predicate function', () {
      expect(
        Rx.concat<int>([
          Stream.fromIterable([1, 2, 3]),
          Stream.error(Exception('1')),
          Stream.value(4),
          Stream.error(Exception('2')),
          Stream.fromIterable([5, 6, 7]),
        ]).doneOnError((e, s) => throw StateError('')),
        emitsInOrder(<Object>[
          1,
          2,
          3,
          emitsError(isException),
          emitsError(isStateError),
          4,
          emitsError(isException),
          emitsError(isStateError),
          5,
          6,
          7,
          emitsDone,
        ]),
      );

      expect(
        Rx.concat<int>([
          Stream.fromIterable([1, 2, 3]),
          Stream.error(Exception('1')),
          Stream.value(4),
          Stream.error(Exception('2')),
          Stream.fromIterable([5, 6, 7]),
        ]).doneOnError((e, s) => throw e),
        emitsInOrder(<Object>[
          1,
          2,
          3,
          emitsError(isException),
          emitsError(isException),
          4,
          emitsError(isException),
          emitsError(isException),
          5,
          6,
          7,
          emitsDone,
        ]),
      );
    });

    test('asBroadcastStream', () {
      final stream = Stream.fromIterable([2, 3, 4, 5, 6])
          .doneOnError()
          .asBroadcastStream();

      // listen twice on same stream
      stream.listen(null);
      stream.listen(null);

      // code should reach here
      expect(true, true);
    });

    test('pause.resume', () async {
      late StreamSubscription<num> subscription;

      subscription = Stream.fromIterable([2, 3, 4, 5, 6]).doneOnError().listen(
        expectAsync1(
          (data) {
            expect(data, 2);
            subscription.cancel();
          },
        ),
      );

      subscription.pause();
      subscription.resume();
    });

    test('broadcast', () {
      final streamController = StreamController<int>.broadcast();
      final stream = streamController.stream.doneOnError();

      expect(stream.isBroadcast, isTrue);
      stream.listen(null);
      stream.listen(null);

      expect(true, true);
    });

    test('single-subscription', () {
      final streamController = StreamController<int>();
      final stream = streamController.stream.doneOnError();

      expect(stream.isBroadcast, isFalse);
      stream.listen(null);
      expect(() => stream.listen(null), throwsStateError);

      streamController.add(1);
    });
  });
}
