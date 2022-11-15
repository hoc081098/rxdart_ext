import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('(FutureOr<R> Function()).asSingle()', () {
    test('.success', () async {
      await singleRule((() => 1).asSingle(), Either.right(1));
      await singleRule((() => 1).asSingle(reusable: true), Either.right(1));
      await singleRule((() => Future.value(1)).asSingle(), Either.right(1));
      await singleRule(
          (() => Future.value(1)).asSingle(reusable: true), Either.right(1));
    });

    test('.failure', () async {
      await singleRule((() => throw Exception()).asSingle(), exceptionLeft);
      await singleRule(
          (() => throw Exception()).asSingle(reusable: true), exceptionLeft);
      await singleRule(
          (() => Future<void>.error(Exception())).asSingle(), exceptionLeft);
      await singleRule(
          (() => Future<void>.error(Exception())).asSingle(reusable: true),
          exceptionLeft);
    });
  });

  group('Future.asSingle', () {
    test('.success', () async {
      await singleRule(Future.value(1).asSingle(), Either.right(1));
      await broadcastRule(Future.value(1).asSingle(), false);
    });

    test('.failure', () async {
      await singleRule(
          Future<void>.error(Exception()).asSingle(), exceptionLeft);
      await broadcastRule(Future<void>.error(Exception()).asSingle(), false);
    });
  });
}
