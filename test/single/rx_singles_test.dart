// ignore_for_file: prefer_function_declarations_over_variables

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('RxSingles.zip2', () {
    test('success + success', () async {
      final build = () => RxSingles.zip2(
            Single.value(1),
            Single.timer(2, Duration(milliseconds: 100)),
            (int a, int b) => a + b,
          );
      await singleRule(
        build(),
        Either.right(3),
      );
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('success + failure', () async {
      final build = () => RxSingles.zip2(
            Single.value(1),
            Single<int>.error(Exception()),
            (int a, int b) => a + b,
          );
      await singleRule(
        build(),
        exceptionLeft,
      );
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('failure + success', () async {
      final build = () => RxSingles.zip2(
            Single<int>.error(Exception()),
            Single.timer(2, Duration(milliseconds: 100)),
            (int a, int b) => a + b,
          );
      await singleRule(build(), exceptionLeft);
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('failure + failure', () async {
      final build = () => RxSingles.zip2(
            Single<int>.error(Exception()),
            Single<int>.error(Exception()).delay(Duration(milliseconds: 10)),
            (int a, int b) => a + b,
          );
      await singleRule(build(), exceptionLeft);
      broadcastRule(build(), false);
      await cancelRule(build());
    });
  });

  group('RxSingles.forkJoin2', () {
    test('success + success', () async {
      final build = () => RxSingles.forkJoin2(
            Single.value(1),
            Single.timer(2, Duration(milliseconds: 100)),
            (int a, int b) => a + b,
          );
      await singleRule(
        build(),
        Either.right(3),
      );
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('success + failure', () async {
      final build = () => RxSingles.forkJoin2(
            Single.value(1),
            Single<int>.error(Exception()),
            (int a, int b) => a + b,
          );
      await singleRule(
        build(),
        exceptionLeft,
      );
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('failure + success', () async {
      final build = () => RxSingles.forkJoin2(
            Single<int>.error(Exception()),
            Single.timer(2, Duration(milliseconds: 100)),
            (int a, int b) => a + b,
          );
      await singleRule(build(), exceptionLeft);
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('failure + failure', () async {
      final build = () => RxSingles.forkJoin2(
            Single<int>.error(Exception()),
            Single<int>.error(Exception()).delay(Duration(milliseconds: 10)),
            (int a, int b) => a + b,
          );
      await singleRule(build(), exceptionLeft);
      broadcastRule(build(), false);
      await cancelRule(build());
    });
  });
}
