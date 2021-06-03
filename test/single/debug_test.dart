import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'single_test_utils.dart';

void main() {
  final dateTimeToStringRegex =
      RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.(\d{3})?\d{3}');

  group('Single.debug', () {
    test('log all events', () async {
      // single
      {
        const identifier = 'debug_test.dart:29 (main.<fn>.<fn>)';

        const logs = [
          ': $identifier -> Listened',
          ': $identifier -> Event data(1)',
          ': $identifier -> Event done',
          ': $identifier -> Cancelled',
        ];

        var i = 0;

        await singleRule(
          Single.value(1).debug(
            log: (v) {
              expect(v.endsWith(logs[i++]), isTrue);
              expect(v.startsWith(dateTimeToStringRegex), isTrue);
            },
          ),
          Either.right(1),
        );
      }

      // error
      {
        const identifier = 'debug_test.dart:52 (main.<fn>.<fn>)';

        const logs = [
          ': $identifier -> Listened',
          ': $identifier -> Event error(Exception, )',
          ': $identifier -> Event done',
          ': $identifier -> Cancelled',
        ];
        var i = 0;

        await singleRule(
          Single<Never>.error(Exception(), StackTrace.empty).debug(
            log: (v) {
              expect(v.endsWith(logs[i++]), isTrue);
              expect(v.startsWith(dateTimeToStringRegex), isTrue);
            },
          ),
          exceptionLeft,
        );
      }
    });

    test('log all events with custom identifier', () async {
      // single
      {
        const logs = [
          ': DEBUG -> Listened',
          ': DEBUG -> Event data(1)',
          ': DEBUG -> Event done',
          ': DEBUG -> Cancelled',
        ];

        var i = 0;

        await singleRule(
          Single.value(1).debug(
              log: (v) {
                expect(v.endsWith(logs[i++]), isTrue);
                expect(v.startsWith(dateTimeToStringRegex), isTrue);
              },
              identifier: 'DEBUG'),
          Either.right(1),
        );
      }

      // error
      {
        const logs = [
          ': DEBUG -> Listened',
          ': DEBUG -> Event error(Exception, )',
          ': DEBUG -> Event done',
          ': DEBUG -> Cancelled',
        ];
        var i = 0;

        await singleRule(
          Single<Never>.error(Exception(), StackTrace.empty).debug(
            log: (v) {
              expect(v.endsWith(logs[i++]), isTrue);
              expect(v.startsWith(dateTimeToStringRegex), isTrue);
            },
            identifier: 'DEBUG',
          ),
          exceptionLeft,
        );
      }
    });

    test('trimOutput', () async {
      const logs = [
        ': DEBUG -> Listened',
        ': DEBUG -> Event data(This is a long ...ed for test purpose)',
        ': DEBUG -> Event done',
        ': DEBUG -> Cancelled',
      ];
      var i = 0;

      await singleRule(
        Single.value('This is a long string value, used for test purpose')
            .debug(
          log: (v) {
            expect(v.endsWith(logs[i++]), isTrue);
            expect(v.startsWith(dateTimeToStringRegex), isTrue);
          },
          identifier: 'DEBUG',
          trimOutput: true,
        ),
        Either.right('This is a long string value, used for test purpose'),
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
}
