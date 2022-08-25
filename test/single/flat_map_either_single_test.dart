// ignore_for_file: prefer_function_declarations_over_variables

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Single.flatMapEitherSingle', () {
    group('.success', () {
      test('Right to Single of Right', () async {
        final build = () => Single.value(Either<int, int>.right(1))
            .flatMapEitherSingle(
                (e) => Single.value(Either<int, int>.right(e + 1)));
        await singleRule(build(), 2.right<Object>().right());
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('Right to Single of Left', () async {
        final build = () => Single.value(Either<int, int>.right(1))
            .flatMapEitherSingle(
                (e) => Single.value(Either<int, int>.left(e + 1)));
        await singleRule(build(), 2.left<Object>().right());
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('Right to single of error', () async {
        final build = () => Single.value(Either<int, int>.right(1))
            .flatMapEitherSingle(
                (e) => Single<Either<int, int>>.error(Exception()));
        await singleRule(build(), exceptionLeft);
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('Left to Single of Right', () async {
        final build = () => Single.value(Either<int, int>.left(1))
            .flatMapEitherSingle(
                (e) => Single.value(Either<int, int>.right(e + 1)));
        await singleRule(build(), 1.left<Object>().right());
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('Left to Single of Left', () async {
        final build = () => Single.value(Either<int, int>.left(1))
            .flatMapEitherSingle(
                (e) => Single.value(Either<int, int>.left(e + 1)));
        await singleRule(build(), 1.left<Object>().right());
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('Left to single of error', () async {
        final build = () => Single.value(Either<int, int>.left(1))
            .flatMapEitherSingle(
                (e) => Single<Either<int, int>>.error(Exception()));
        await singleRule(build(), 1.left<Object>().right());
        broadcastRule(build(), false);
        await cancelRule(build());
      });
    });

    group('.failure', () {
      test('to Single of Right', () async {
        final build = () => Single<Either<int, int>>.error(Exception())
            .flatMapEitherSingle(
                (e) => Single.value(Either<int, int>.right(e + 1)));
        await singleRule(build(), exceptionLeft);
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('to Single of Left', () async {
        final build = () => Single<Either<int, int>>.error(Exception())
            .flatMapEitherSingle(
                (e) => Single.value(Either<int, int>.left(e + 1)));
        await singleRule(build(), exceptionLeft);
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('to Single of error', () async {
        final build = () => Single<Either<int, int>>.error(Exception())
            .flatMapEitherSingle(
                (e) => Single<Either<int, int>>.error(Exception()));
        await singleRule(build(), exceptionLeft);
        broadcastRule(build(), false);
        await cancelRule(build());
      });
    });
  });
}
