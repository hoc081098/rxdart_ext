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
        const logs = [
          ': Debug -> Listened',
          ': Debug -> Event data(1)',
          ': Debug -> Event done',
          ': Debug -> Cancelled',
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
        const logs = [
          ': Debug -> Listened',
          ': Debug -> Event data(1)',
          ': Debug -> Event data(2)',
          ': Debug -> Event data(3)',
          ': Debug -> Event done',
          ': Debug -> Cancelled',
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
        const logs = [
          ': Debug -> Listened',
          ': Debug -> Event data(1)',
          ': Debug -> Event data(2)',
          ': Debug -> Event error(Exception, )',
          ': Debug -> Event data(3)',
          ': Debug -> Event done',
          ': Debug -> Cancelled',
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
  });

  test('collect', () {
    final streamSubscription = Stream.value(1).collect();
    expect(streamSubscription, isA<StreamSubscription<void>>());

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
}
