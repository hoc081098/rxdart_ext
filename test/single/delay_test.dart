import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'single_test_utils.dart';

void main() {
  group('Single.delay', () {
    test('.success', () async {
      await singleRule(
        Single.value(1).delay(const Duration(milliseconds: 100)),
        Either.right(1),
      );
      broadcastRule(
        Single.value(1).delay(const Duration(milliseconds: 100)),
        false,
      );
      await cancelRule(
          Single.value(1).delay(const Duration(milliseconds: 100)));
    });

    test('.failure', () async {
      await singleRule(
        Single<int>.error(Exception()).delay(const Duration(milliseconds: 100)),
        exceptionLeft,
      );
      broadcastRule(
        Single<int>.error(Exception()).delay(const Duration(milliseconds: 100)),
        false,
      );
      await cancelRule(Single<int>.error(Exception()));
    });
  });
}
