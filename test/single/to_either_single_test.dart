// ignore_for_file: prefer_function_declarations_over_variables

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Single.toEitherSingle', () {
    test('.success', () async {
      final build = () => Single.value(1).toEitherSingle((e, s) => e);
      await singleRule(build(), 1.right<Object>().right());
      await broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('.failure', () async {
      final build =
          () => Single<int>.error(Exception()).toEitherSingle((e, s) => e);
      await singleRule(
        build(),
        isA<Left<Object, int>>()
            .having((l) => l.value, 'Left.value', isException)
            .right(),
      );
      await broadcastRule(build(), false);
      await cancelRule(build());
    });
  });
}
