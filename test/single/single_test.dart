import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void broadcastRule<T>(Single<T> single, bool isBroadcast) {
  final ignoreError = (Object e) {};

  if (isBroadcast) {
    expect(single.isBroadcast, true);
    single.listen(null, onError: ignoreError);
    single.listen(null, onError: ignoreError);
  } else {
    expect(single.isBroadcast, false);
    single.listen(null, onError: ignoreError);
    expect(() => single.listen(null, onError: ignoreError), throwsStateError);
  }
}

Future<void> singleRule<T>(Single<T> single, Either<Object, T> e) {
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
    test('construct', () async {
      // Single.value
      await singleRule(
        Single.value(1),
        Either.right(1),
      );
      broadcastRule(Single.value(1), false);

      // Single.error
      await singleRule(
        Single<int>.error(Exception()),
        _left,
      );
      broadcastRule(Single<int>.error(Exception()), false);

      // Single.fromCallable.sync.success
      await singleRule(
        Single.fromCallable(() => 1),
        Either.right(1),
      );
      broadcastRule(Single.fromCallable(() => 1), false);
      await singleRule(
        Single.fromCallable(() => 1, reusable: true),
        Either.right(1),
      );
      broadcastRule(Single.fromCallable(() => 1, reusable: true), true);
      // Single.fromCallable.sync.failure
      await singleRule(
        Single.fromCallable(() => throw Exception()),
        _left,
      );
      broadcastRule(Single.fromCallable(() => throw Exception()), false);
      await singleRule(
        Single.fromCallable(() => throw Exception(), reusable: true),
        _left,
      );
      broadcastRule(
          Single.fromCallable(() => throw Exception(), reusable: true), true);
      // Single.fromCallable.async.success
      await singleRule(
        Single.fromCallable(() async => 1),
        Either.right(1),
      );
      broadcastRule(Single.fromCallable(() async => 1), false);
      await singleRule(
        Single.fromCallable(() async => 1, reusable: true),
        Either.right(1),
      );
      broadcastRule(Single.fromCallable(() async => 1, reusable: true), true);
      // Single.fromCallable.async.failure
      await singleRule(
        Single.fromCallable(() async => throw Exception()),
        _left,
      );
      broadcastRule(Single.fromCallable(() async => throw Exception()), false);
      await singleRule(
        Single.fromCallable(() async => throw Exception(), reusable: true),
        _left,
      );
      broadcastRule(
          Single.fromCallable(() async => throw Exception(), reusable: true),
          true);

      // Single.defer.success
      await singleRule(
        Single.defer(() => Single.value(1)),
        Either.right(1),
      );
      // Single.defer.failure
      await singleRule(
        Single<String>.defer(() => Single.error(Exception())),
        _left,
      );
    });

    test('override', () async {
      // Single.distinct.success
      await singleRule(
        Single.value(1).distinct(),
        Either.right(1),
      );
      // Single.distinct.failure
      await singleRule(
        Single<void>.error(Exception()).distinct(),
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
      // Single.singleOrError
      await singleRule(
        Single.value(1).singleOrError(),
        Either.right(1),
      );
      broadcastRule(Single.value(1).singleOrError(), false);

      // Stream.singleOrError
      final c = StreamController<int>();
      c.add(1);
      unawaited(c.close());
      await singleRule(
        c.stream.singleOrError(),
        Either.right(1),
      );

      // single data
      await singleRule(
        Stream.value(1).singleOrError(),
        Either.right(1),
      );
      broadcastRule(Stream.value(1).singleOrError(), false);

      // single error
      await singleRule(
        Stream<void>.error(Exception()).singleOrError(),
        _left,
      );
      broadcastRule(Stream<void>.error(Exception()).singleOrError(), false);

      // empty
      await singleRule(
        Stream<int>.empty().singleOrError(),
        _APIContractViolationError(
            "Stream doesn't contains any data or error event."),
      );
      broadcastRule(Stream<int>.empty().singleOrError(), true);

      // broadcast stream
      final cb = StreamController<int>.broadcast(sync: true);
      cb.onListen = () {
        scheduleMicrotask(() {
          cb.add(1);
          cb.close();
        });
      };
      final _s = cb.stream.singleOrError();
      await singleRule(_s, Either.right(1));
      broadcastRule(_s, true);

      // data -> data
      await singleRule(
        Stream.fromIterable([1, 2, 3]).singleOrError(),
        _APIContractViolationError('Stream contains more than one data event.'),
      );
      broadcastRule(Stream.fromIterable([1, 2, 3]).singleOrError(), false);

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
