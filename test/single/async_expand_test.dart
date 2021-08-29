import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('asyncExpandSingle', () {
    test('success -> success', () async {
      await singleRule(
        Single.value(1).asyncExpandSingle((i) => Single.value(i + 1)),
        Either.right(2),
      );
      await singleRule(
        Single.value(1).asyncExpandSingle(
            (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
        Either.right(2),
      );
    });

    test('success -> failure', () async {
      await singleRule(
        Single.value(22)
            .asyncExpandSingle((i) => Single<int>.error(Exception())),
        exceptionLeft,
      );
    });

    test('failure -> success', () async {
      await singleRule(
        Single<int>.error(Exception())
            .asyncExpandSingle((i) => Single.value(i + 1)),
        exceptionLeft,
      );
    });

    test('failure -> failure', () async {
      await singleRule(
        Single<int>.error(Exception())
            .asyncExpandSingle((i) => Single<int>.error(Exception())),
        exceptionLeft,
      );
    });
  });
}
