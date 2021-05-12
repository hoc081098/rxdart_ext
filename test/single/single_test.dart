import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

Future<void> singleRule<T>(Stream<T> single, Either<Object, T> e) {
  return expectLater(
    single,
    emitsInOrder(<dynamic>[
      e.fold((e) => emitsError(e), (v) => emits(v)),
      emitsDone,
    ]),
  );
}

final _left = Either<Object, Never>.left(isA<Exception>());
final _APIContractViolationError = (String s) => Either<Object, Never>.left(
    isA<APIContractViolationError>().having((o) => o.message, 'message', s));

void main() {
  group('Single', () {
    test('singleRule', () async {
      // Single.value
      await singleRule(
        Single.value(1),
        Either.right(1),
      );

      // Single.error
      await singleRule(
        Single<int>.error(Exception()),
        _left,
      );

      // Single.map.success
      await singleRule(
        Single.value(1).map((event) => event.toString()),
        Either.right('1'),
      );
      // Single.map.failure
      await singleRule(
        Single.value(1).map((event) => throw Exception()),
        _left,
      );

      // Single.asyncMap.sync.success
      await singleRule(
        Single.value(1).asyncMap((event) => event.toString()),
        Either.right('1'),
      );
      // Single.asyncMap.sync.failure
      await singleRule(
        Single.value(1).asyncMap((event) => throw Exception()),
        _left,
      );

      // Single.asyncMap.async.success
      await singleRule(
        Single.value(1).asyncMap((event) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return event.toString();
        }),
        Either.right('1'),
      );
      // Single.asyncMap.async.failure
      await singleRule(
        Single.value(1).asyncMap((event) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          throw Exception();
        }),
        _left,
      );
    });

    test('singleOrError', () async {
      await singleRule(
        Single.value(1).singleOrError(),
        Either.right(1),
      );

      // data -> data
      await singleRule(
        Stream.fromIterable([1, 2, 3]).singleOrError(),
        _APIContractViolationError('Stream contains more than one data event.'),
      );

      // data -> error
      await singleRule(
        Rx.concat<int?>([
          Rx.timer(1, const Duration(milliseconds: 100)),
          Stream<int>.error(Exception())
              .delay(const Duration(milliseconds: 100)),
          Rx.timer(null, const Duration(milliseconds: 100)),
        ]).singleOrError(),
        _APIContractViolationError(
            'Stream contains both data and error event.'),
      );

      // error -> data
      await singleRule(
        Rx.concat<int?>([
          Stream<int>.error(Exception())
              .delay(const Duration(milliseconds: 100)),
          Rx.timer(1, const Duration(milliseconds: 100)),
          Rx.timer(null, const Duration(milliseconds: 100)),
        ]).singleOrError(),
        _APIContractViolationError(
            'Stream contains both data and error event.'),
      );

      // error -> error
      await singleRule(
        Rx.concat<int?>([
          Stream<int>.error(Exception())
              .delay(const Duration(milliseconds: 100)),
          Stream<int>.error(Exception())
              .delay(const Duration(milliseconds: 100)),
        ]).singleOrError(),
        _APIContractViolationError(
            'Stream contains more than one error event.'),
      );
    });

    test('flatMapSingle', () async {
      // success -> success
      await singleRule(
        Single.value(1).flatMapSingle((i) => Single.value(i + 1)),
        Either.right(2),
      );
      // success -> success
      await singleRule(
        Single.value(1).flatMapSingle(
            (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
        Either.right(2),
      );

      // failure -> success
      await singleRule(
        Single<int>.error(Exception())
            .flatMapSingle((i) => Single.value(i + 1)),
        _left,
      );
      // failure -> failure
      await singleRule(
        Single<int>.error(Exception())
            .flatMapSingle((i) => Single<int>.error(Exception())),
        _left,
      );
      // success -> failure
      await singleRule(
        Single.value(22).flatMapSingle((i) => Single<int>.error(Exception())),
        _left,
      );
    });

    test('switchMapSingle', () async {
      // success -> success
      await singleRule(
        Single.value(1).switchMapSingle((i) => Single.value(i + 1)),
        Either.right(2),
      );
      // success -> success
      await singleRule(
        Single.value(1).switchMapSingle(
            (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
        Either.right(2),
      );

      // failure -> success
      await singleRule(
        Single<int>.error(Exception())
            .switchMapSingle((i) => Single.value(i + 1)),
        _left,
      );
      // failure -> failure
      await singleRule(
        Single<int>.error(Exception())
            .switchMapSingle((i) => Single<int>.error(Exception())),
        _left,
      );
      // success -> failure
      await singleRule(
        Single.value(22).switchMapSingle((i) => Single<int>.error(Exception())),
        _left,
      );
    });

    test('exhaustMapSingle', () async {
      // success -> success
      await singleRule(
        Single.value(1).exhaustMapSingle((i) => Single.value(i + 1)),
        Either.right(2),
      );
      // success -> success
      await singleRule(
        Single.value(1).exhaustMapSingle(
            (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
        Either.right(2),
      );

      // failure -> success
      await singleRule(
        Single<int>.error(Exception())
            .exhaustMapSingle((i) => Single.value(i + 1)),
        _left,
      );
      // failure -> failure
      await singleRule(
        Single<int>.error(Exception())
            .exhaustMapSingle((i) => Single<int>.error(Exception())),
        _left,
      );
      // success -> failure
      await singleRule(
        Single.value(22)
            .exhaustMapSingle((i) => Single<int>.error(Exception())),
        _left,
      );
    });

    test('asyncExpandSingle', () async {
      // success -> success
      await singleRule(
        Single.value(1).asyncExpandSingle((i) => Single.value(i + 1)),
        Either.right(2),
      );
      // success -> success
      await singleRule(
        Single.value(1).asyncExpandSingle(
            (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
        Either.right(2),
      );

      // failure -> success
      await singleRule(
        Single<int>.error(Exception())
            .asyncExpandSingle((i) => Single.value(i + 1)),
        _left,
      );
      // failure -> failure
      await singleRule(
        Single<int>.error(Exception())
            .asyncExpandSingle((i) => Single<int>.error(Exception())),
        _left,
      );
      // success -> failure
      await singleRule(
        Single.value(22)
            .asyncExpandSingle((i) => Single<int>.error(Exception())),
        _left,
      );
    });
  });
}
