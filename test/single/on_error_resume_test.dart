import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'single_test_utils.dart';

void main() {
  group('Single.onErrorReturn', () {
    test('.success', () async {
      final build = () => Single.value(1).onErrorReturn(99);
      await singleRule(build(), Either.right(1));
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('.failure', () async {
      final build = () => Single<int>.error(Exception()).onErrorReturn(1);
      await singleRule(build(), Either.right(1));
      broadcastRule(build(), false);
      await cancelRule(build());
    });
  });

  group('Single.onErrorReturnWith', () {
    test('.success', () async {
      final build = () =>
          Single.value(1).onErrorReturnWith((e, s) => e is Exception ? 99 : 0);
      await singleRule(build(), Either.right(1));
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('.failure', () async {
      final build = () => Single<int>.error(Exception())
          .onErrorReturnWith((e, s) => e is Exception ? 99 : 0);
      await singleRule(build(), Either.right(99));
      broadcastRule(build(), false);
      await cancelRule(build());
    });
  });
}
