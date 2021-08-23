// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'single_test_utils.dart';

void main() {
  group('Single.doX', () {
    group('.unified', () {
      test('.success', () async {
        final expected = 99;

        final build =
            () => Single.timer(expected, const Duration(milliseconds: 500))
                .doOnListen(expectAsync0(() => print('onListen'), count: 1))
                .doOnData(expectAsync1((event) {
                  print('onData $event');
                  expect(event, expected);
                }, count: 1))
                .doOnError(expectAsync2((p0, p1) {}, count: 0))
                .doOnCancel(expectAsync0(() => print('onCancel'), count: 1));

        await singleRule(build(), Either.right(expected));
      });

      test('.failure', () async {
        final build = () => Single<int>.error(Exception())
            .delay(const Duration(milliseconds: 300))
            .doOnListen(expectAsync0(() => print('onListen'), count: 1))
            .doOnData(expectAsync1((event) {}, count: 0))
            .doOnError(expectAsync2((e, s) {
              print('onError $e');
              expect(e, isException);
            }, count: 1))
            .doOnCancel(expectAsync0(() => print('onCancel'), count: 1));

        await singleRule(build(), exceptionLeft);
      });
    });

    final stateError = StateError('Caught by Zone');
    void expectStateError(Object e, StackTrace s) {
      expect(
        e,
        isStateError.having(
          (s) => s.message,
          'message',
          stateError.message,
        ),
      );
      expect(e, stateError);
    }

    group('doOnCancel', () {
      test('.success', () async {
        final build = () => Single.value(1).doOnCancel(() => null);
        await singleRule(build(), Either.right(1));
        broadcastRule(build(), false);
        await cancelRule(build());

        await runZonedGuarded(
          () async {
            final build =
                () => Single.value(1).doOnCancel(() => throw stateError);
            await singleRule(build(), Either.right(1));
            broadcastRule(build(), false);
            await cancelRule(build());
          },
          expectStateError,
        );
      });

      test('.failure', () async {
        final build =
            () => Single<int>.error(Exception()).doOnCancel(() => null);
        await singleRule(build(), exceptionLeft);
        broadcastRule(build(), false);
        await cancelRule(build());

        await runZonedGuarded(
          () async {
            final build = () => Single<int>.error(Exception())
                .doOnCancel(() => throw stateError);
            await singleRule(build(), exceptionLeft);
            broadcastRule(build(), false);
            await cancelRule(build());
          },
          expectStateError,
        );
      });
    });

    group('doOnData', () {
      test('.success', () async {
        final build = () => Single.value(1).doOnData((_) {});
        await singleRule(build(), Either.right(1));
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('.failure', () async {
        {
          final build =
              () => Single.value(1).doOnData((_) => throw Exception());
          await singleRule(build(), exceptionLeft);
          broadcastRule(build(), false);
          await cancelRule(build());
        }

        {
          final build = () => Single<int>.error(Exception()).doOnData((_) {});
          await singleRule(build(), exceptionLeft);
          broadcastRule(build(), false);
          await cancelRule(build());
        }

        {
          final build = () =>
              Single<int>.error(Exception()).doOnData((_) => throw stateError);
          await singleRule(build(), exceptionLeft);
          broadcastRule(build(), false);
          await cancelRule(build());
        }
      });
    });
  });
}
