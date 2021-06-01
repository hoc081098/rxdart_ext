import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'single_test_utils.dart';

void main() {
  group('flatMapSingle', () {
    test('success -> success', () async {
      await singleRule(
        Single.value(1).flatMapSingle((i) => Single.value(i + 1)),
        Either.right(2),
      );
      await singleRule(
        Single.value(1).flatMapSingle(
            (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
        Either.right(2),
      );
    });

    test('success -> failure', () async {
      await singleRule(
        Single.value(22).flatMapSingle((i) => Single<int>.error(Exception())),
        exceptionLeft,
      );
    });

    test('failure -> success', () async {
      await singleRule(
        Single<int>.error(Exception())
            .flatMapSingle((i) => Single.value(i + 1)),
        exceptionLeft,
      );
    });

    test('failure -> failure', () async {
      await singleRule(
        Single<int>.error(Exception())
            .flatMapSingle((i) => Single<int>.error(Exception())),
        exceptionLeft,
      );
    });
  });

  group('switchMapSingle', () {
    test('success -> success', () async {
      await singleRule(
        Single.value(1).switchMapSingle((i) => Single.value(i + 1)),
        Either.right(2),
      );
      await singleRule(
        Single.value(1).switchMapSingle(
            (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
        Either.right(2),
      );
    });

    test('success -> failure', () async {
      await singleRule(
        Single.value(22).switchMapSingle((i) => Single<int>.error(Exception())),
        exceptionLeft,
      );
    });

    test('failure -> success', () async {
      await singleRule(
        Single<int>.error(Exception())
            .switchMapSingle((i) => Single.value(i + 1)),
        exceptionLeft,
      );
    });

    test('failure -> failure', () async {
      await singleRule(
        Single<int>.error(Exception())
            .switchMapSingle((i) => Single<int>.error(Exception())),
        exceptionLeft,
      );
    });
  });

  group('exhaustMapSingle', () {
    test('success -> success', () async {
      await singleRule(
        Single.value(1).exhaustMapSingle((i) => Single.value(i + 1)),
        Either.right(2),
      );
      await singleRule(
        Single.value(1).exhaustMapSingle(
            (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
        Either.right(2),
      );
    });

    test('success -> failure', () async {
      await singleRule(
        Single.value(22)
            .exhaustMapSingle((i) => Single<int>.error(Exception())),
        exceptionLeft,
      );
    });

    test('failure -> success', () async {
      await singleRule(
        Single<int>.error(Exception())
            .exhaustMapSingle((i) => Single.value(i + 1)),
        exceptionLeft,
      );
    });

    test('failure -> failure', () async {
      await singleRule(
        Single<int>.error(Exception())
            .exhaustMapSingle((i) => Single<int>.error(Exception())),
        exceptionLeft,
      );
    });
  });
}
