import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'single_test_utils.dart';

void main() {
  group('Single.onErrorReturn', () {
    test('.success', () async {
      final build = () => Single.value(1);
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
}
