// ignore_for_file: prefer_function_declarations_over_variables

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

void main() {
  group('Single.mapTo', () {
    test('.success', () async {
      final build = () => Single.value(1).mapTo(2);
      await singleRule(build(), Either.right(2));
      await broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('.failure', () async {
      final build = () => Single<int>.error(Exception());
      await singleRule(build(), exceptionLeft);
      await broadcastRule(build(), false);
      await cancelRule(build());
    });
  });
}
