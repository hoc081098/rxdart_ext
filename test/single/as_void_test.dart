// ignore_for_file: prefer_function_declarations_over_variables

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'single_test_utils.dart';

void main() {
  group('Single.asVoid', () {
    test('.success', () async {
      final build = () => Single.value(1).asVoid();
      expect(build(), isA<Single<void>>());
      await singleRule(build(), Either.right(null));
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('.failure', () async {
      final build = () => Single<int>.error(Exception()).asVoid();
      expect(build(), isA<Single<void>>());
      await singleRule(build(), exceptionLeft);
      broadcastRule(build(), false);
      await cancelRule(build());
    });
  });
}
