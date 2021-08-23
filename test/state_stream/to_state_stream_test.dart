import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('toStateStream', () {
    test('allows access to latest value', () {
      final controller = StreamController<int>(sync: true);
      final stream = controller.stream.toStateStream(0)..collect();
      expect(stream.value, 0);

      for (var i = 0; i < 10; i++) {
        controller.add(i);
        expect(stream.value, i);
        expect(stream.errorOrNull, isNull);
      }
    });

    test('distinct until changed', () {
      {
        final stream =
            Stream.fromIterable([1, 2, 2, 3, 3, 4, 5, 6, 7]).toStateStream(1);

        expect(
          stream,
          emitsInOrder(<Object>[
            2,
            3,
            4,
            5,
            6,
            7,
            emitsDone,
          ]),
        );
      }

      {
        final stream =
            Stream.fromIterable([1, 2, 2, 3, 3, 4, 5, 6, 7]).toStateStream(2);

        expect(
          stream,
          emitsInOrder(<Object>[
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            emitsDone,
          ]),
        );
      }
    });

    test('does not handle error', () async {
      await runZonedGuarded(
        () => Stream<int>.error(Exception())
            .toStateStream(0)
            .collect()
            .asFuture<void>(),
        (e, s) => expect(e, isException),
      );
    });

    test('is single-subscription Stream', () {
      final stream = Stream.value(1).toStateStream(0);
      expect(stream.isBroadcast, isFalse);

      stream.collect();
      expect(() => stream.collect(), throwsStateError);
    });

    test('asBroadcastStream', () {
      final broadcastStream =
          Stream.value(1).toStateStream(0).asBroadcastStream();

      broadcastStream.collect();
      broadcastStream.collect();

      expect(true, isTrue);
    });

    test('pause resume', () {
      {
        final stream = Stream.value(1).toStateStream(0);

        final subscription = stream.listen(null);
        subscription.onData(
          expectAsync1(
            (data) {
              expect(data, 1);
              subscription.cancel();
            },
            count: 1,
          ),
        );

        subscription.pause();
        subscription.resume();
      }

      {
        final stream = Stream.value(1).toStateStream(1);

        final subscription = stream.listen(null);
        subscription.onData(expectAsync1((_) {}, count: 0));
        subscription.onDone(expectAsync0(() {}, count: 1));

        subscription.pause();
        subscription.resume();
      }
    });

    test('getters', () {
      final stream = Stream.value(1).toStateStream(0);
      expect(stream.valueOrNull, 0);
      expect(stream.hasValue, true);
      expect(stream.value, 0);

      expect(stream.stackTrace, isNull);
      expect(stream.hasError, false);
      expect(stream.errorOrNull, null);
      expect(() => stream.error, throwsA(isA<ValueStreamError>()));
    });
  });
}
