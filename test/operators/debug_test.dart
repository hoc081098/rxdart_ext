import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  final dateTimeToStringRegex =
      RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.(\d{3})?\d{3}');

  group('debug', () {
    test('log all events', () {
      // single
      {
        const identifier = 'debug_test.dart:26 (main.<fn>.<fn>)';

        const logs = [
          ': $identifier -> Listened',
          ': $identifier -> Event data(1)',
          ': $identifier -> Event done',
          ': $identifier -> Cancelled',
        ];

        var i = 0;

        expect(
          Stream.value(1).debug(
            log: (v) {
              expect(v.endsWith(logs[i++]), isTrue);
              expect(v.startsWith(dateTimeToStringRegex), isTrue);
            },
          ),
          emitsInOrder(<dynamic>[1, emitsDone]),
        );
      }

      // many
      {
        const identifier = 'debug_test.dart:51 (main.<fn>.<fn>)';

        const logs = [
          ': $identifier -> Listened',
          ': $identifier -> Event data(1)',
          ': $identifier -> Event data(2)',
          ': $identifier -> Event data(3)',
          ': $identifier -> Event done',
          ': $identifier -> Cancelled',
        ];
        var i = 0;

        expect(
          Stream.fromIterable([1, 2, 3]).debug(
            log: (v) {
              expect(v.endsWith(logs[i++]), isTrue);
              expect(v.startsWith(dateTimeToStringRegex), isTrue);
            },
          ),
          emitsInOrder(<dynamic>[1, 2, 3, emitsDone]),
        );
      }

      // many with error
      {
        const identifier = 'debug_test.dart:81 (main.<fn>.<fn>)';

        const logs = [
          ': $identifier -> Listened',
          ': $identifier -> Event data(1)',
          ': $identifier -> Event data(2)',
          ': $identifier -> Event error(Exception, )',
          ': $identifier -> Event data(3)',
          ': $identifier -> Event done',
          ': $identifier -> Cancelled',
        ];
        var i = 0;

        expect(
          Rx.concat<int>([
            Stream.fromIterable([1, 2]),
            Stream.error(Exception(), StackTrace.empty),
            Stream.value(3),
          ]).debug(
            log: (v) {
              expect(v.endsWith(logs[i++]), isTrue);
              expect(v.startsWith(dateTimeToStringRegex), isTrue);
            },
          ),
          emitsInOrder(<dynamic>[
            1,
            2,
            emitsError(isException),
            3,
            emitsDone,
          ]),
        );
      }
    });

    test('log all events with custom identifier', () {
      // single
      {
        const logs = [
          ': DEBUG -> Listened',
          ': DEBUG -> Event data(1)',
          ': DEBUG -> Event done',
          ': DEBUG -> Cancelled',
        ];

        var i = 0;

        expect(
          Stream.value(1).debug(
              log: (v) {
                expect(v.endsWith(logs[i++]), isTrue);
                expect(v.startsWith(dateTimeToStringRegex), isTrue);
              },
              identifier: 'DEBUG'),
          emitsInOrder(<dynamic>[1, emitsDone]),
        );
      }

      // many
      {
        const logs = [
          ': DEBUG -> Listened',
          ': DEBUG -> Event data(1)',
          ': DEBUG -> Event data(2)',
          ': DEBUG -> Event data(3)',
          ': DEBUG -> Event done',
          ': DEBUG -> Cancelled',
        ];
        var i = 0;

        expect(
          Stream.fromIterable([1, 2, 3]).debug(
              log: (v) {
                expect(v.endsWith(logs[i++]), isTrue);
                expect(v.startsWith(dateTimeToStringRegex), isTrue);
              },
              identifier: 'DEBUG'),
          emitsInOrder(<dynamic>[1, 2, 3, emitsDone]),
        );
      }

      // many with error
      {
        const logs = [
          ': DEBUG -> Listened',
          ': DEBUG -> Event data(1)',
          ': DEBUG -> Event data(2)',
          ': DEBUG -> Event error(Exception, )',
          ': DEBUG -> Event data(3)',
          ': DEBUG -> Event done',
          ': DEBUG -> Cancelled',
        ];
        var i = 0;

        expect(
          Rx.concat<int>([
            Stream.fromIterable([1, 2]),
            Stream.error(Exception(), StackTrace.empty),
            Stream.value(3),
          ]).debug(
            log: (v) {
              expect(v.endsWith(logs[i++]), isTrue);
              expect(v.startsWith(dateTimeToStringRegex), isTrue);
            },
            identifier: 'DEBUG',
          ),
          emitsInOrder(<dynamic>[
            1,
            2,
            emitsError(isException),
            3,
            emitsDone,
          ]),
        );
      }
    });

    test('trimOutput', () {
      const logs = [
        ': DEBUG -> Listened',
        ': DEBUG -> Event data(This is a long ...ed for test purpose)',
        ': DEBUG -> Event data(2)',
        ': DEBUG -> Event error(Exception, )',
        ': DEBUG -> Event data(3)',
        ': DEBUG -> Event done',
        ': DEBUG -> Cancelled',
      ];
      var i = 0;

      expect(
        Rx.concat<String>([
          Stream.fromIterable(
              ['This is a long string value, used for test purpose', '2']),
          Stream.error(Exception(), StackTrace.empty),
          Stream.value('3'),
        ]).debug(
          log: (v) {
            expect(v.endsWith(logs[i++]), isTrue);
            expect(v.startsWith(dateTimeToStringRegex), isTrue);
          },
          identifier: 'DEBUG',
          trimOutput: true,
        ),
        emitsInOrder(<dynamic>[
          'This is a long string value, used for test purpose',
          '2',
          emitsError(isException),
          '3',
          emitsDone,
        ]),
      );
    });

    test('pause resume', () async {
      const logs = [
        ': DEBUG -> Listened',
        ': DEBUG -> Paused',
        ': DEBUG -> Resumed',
        ': DEBUG -> Event data(1)',
        ': DEBUG -> Event done',
        ': DEBUG -> Cancelled',
      ];

      var i = 0;
      final subscription = Stream.value(1)
          .debug(
            log: (v) {
              expect(v.endsWith(logs[i++]), isTrue);
              expect(v.startsWith(dateTimeToStringRegex), isTrue);
            },
            identifier: 'DEBUG',
          )
          .listen(null);
      subscription.onData((data) => expect(data, 1));

      subscription.pause();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      subscription.resume();
    });
  });

  group('collect', () {
    test(
        'returns a StreamSubscription, any handlers of this subscription cannot be replaced',
        () {
      final streamSubscription = Stream.value(1).collect();
      expect(streamSubscription, isA<StreamSubscription<void>>());
      expect(streamSubscription, isA<StreamSubscription<int>>());

      expect(
        () => streamSubscription.onData((data) {}),
        throwsStateError,
      );
      expect(
        () => streamSubscription.onError((Object e, StackTrace s) {}),
        throwsStateError,
      );
      expect(
        () => streamSubscription.onDone(() {}),
        throwsStateError,
      );
    });

    test('pause resume isPaused', () {
      final subscription = Stream.value(1).collect();

      subscription.pause();
      expect(subscription.isPaused, isTrue);

      subscription.resume();
      expect(subscription.isPaused, isFalse);
    });

    test('asFuture', () {
      final subscription = Stream.value(1).collect();
      expect(subscription.asFuture<void>(), completes);
    });

    test('cancel', () {
      Stream.value(1).doOnData((v) => expect(true, isFalse)).collect().cancel();
    });
  });
}
