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

Future<void> cancelRule<T>(
  Single<T> single, [
  Duration timeout = const Duration(seconds: 1),
]) async {
  unawaited(single
      .listen(
        (v) => expect(false, true),
        onError: (Object e, StackTrace s) => expect(false, true),
        onDone: () => expect(false, true),
      )
      .cancel());
  await Future<void>.delayed(timeout);
}

final _exceptionLeft = Either<Object, Never>.left(isA<Exception>());
final _APIContractViolationError = (String s) => Either<Object, Never>.left(
    isA<APIContractViolationError>().having((o) => o.message, 'message', s));

void main() {
  group('Single', () {
    group('construct', () {
      test('Single.value', () async {
        final build = () => Single.value(1);
        await singleRule(build(), Either.right(1));
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('Single.error', () async {
        final build = () => Single<int>.error(Exception());
        await singleRule(build(), _exceptionLeft);
        broadcastRule(build(), false);
        await cancelRule(build());
      });

      group('Single.fromCallable', () {
        group('.sync', () {
          test('.success', () async {
            final build1 = () => Single.fromCallable(() => 1);
            await singleRule(build1(), Either.right(1));
            broadcastRule(build1(), false);
            await cancelRule(build1());

            final build2 = () => Single.fromCallable(() => 1, reusable: true);
            await singleRule(build2(), Either.right(1));
            broadcastRule(build2(), true);
            await cancelRule(build2());
          });

          test('failure', () async {
            final build1 = () => Single.fromCallable(() => throw Exception());
            await singleRule(build1(), _exceptionLeft);
            broadcastRule(build1(), false);
            await cancelRule(build1());

            final build2 = () =>
                Single.fromCallable(() => throw Exception(), reusable: true);
            await singleRule(build2(), _exceptionLeft);
            broadcastRule(build2(), true);
            await cancelRule(build2());
          });
        });

        group('.async', () {
          test('.success', () async {
            final build1 = () => Single.fromCallable(() async => 1);
            await singleRule(build1(), Either.right(1));
            broadcastRule(build1(), false);
            await cancelRule(build1());

            final build2 =
                () => Single.fromCallable(() async => 1, reusable: true);
            await singleRule(build2(), Either.right(1));
            broadcastRule(build2(), true);
            await cancelRule(build2());
          });

          test('.failure', () async {
            final build1 =
                () => Single.fromCallable(() async => throw Exception());
            await singleRule(build1(), _exceptionLeft);
            broadcastRule(build1(), false);
            await cancelRule(build1());

            await singleRule(
              Single.fromCallable(() async => throw Exception(),
                  reusable: true),
              _exceptionLeft,
            );
            broadcastRule(
                Single.fromCallable(() async => throw Exception(),
                    reusable: true),
                true);
            await cancelRule(Single.fromCallable(() async => throw Exception(),
                reusable: true));
          });
        });
      });

      group('Single.defer', () {
        test('.success', () async {
          await singleRule(
            Single.defer(() => Single.value(1)),
            Either.right(1),
          );
          broadcastRule(Single.defer(() => Single.value(1)), false);
          await cancelRule(Single.defer(() => Single.value(1)));

          await singleRule(
            Single.defer(() => Single.value(1), reusable: true),
            Either.right(1),
          );
          broadcastRule(
              Single.defer(() => Single.value(1), reusable: true), true);
          await cancelRule(Single.defer(() => Single.value(1), reusable: true));
        });

        test('.failure', () async {
          await singleRule(
            Single<String>.defer(() => Single.error(Exception())),
            _exceptionLeft,
          );
          broadcastRule(
              Single<String>.defer(() => Single.error(Exception())), false);
          await cancelRule(
              Single<String>.defer(() => Single.error(Exception())));

          await singleRule(
            Single<String>.defer(() => Single.error(Exception()),
                reusable: true),
            _exceptionLeft,
          );
          broadcastRule(
              Single<String>.defer(() => Single.error(Exception()),
                  reusable: true),
              true);
          await cancelRule(Single<String>.defer(() => Single.error(Exception()),
              reusable: true));
        });
      });

      group('Single.fromFuture', () {
        test('.success', () async {
          await singleRule(
            Single.fromFuture(Future.value(1)),
            Either.right(1),
          );
          broadcastRule(Single.fromFuture(Future.value(1)), false);
          await cancelRule(Single.fromFuture(Future.value(1)));

          await singleRule(
            Single.fromFuture(
                Future.delayed(Duration(milliseconds: 100), () => 1)),
            Either.right(1),
          );
          broadcastRule(
              Single.fromFuture(
                  Future.delayed(Duration(milliseconds: 100), () => 1)),
              false);
          await cancelRule(Single.fromFuture(
              Future.delayed(Duration(milliseconds: 100), () => 1)));
        });

        test('.failure', () async {
          await singleRule(Single<int>.fromFuture(Future.error(Exception())),
              _exceptionLeft);
          broadcastRule(
              Single<int>.fromFuture(Future.error(Exception())), false);
          await cancelRule(Single<int>.fromFuture(Future.error(Exception())));

          await singleRule(
            Single.fromFuture(Future.delayed(
                Duration(milliseconds: 100), () => throw Exception())),
            _exceptionLeft,
          );
          broadcastRule(
              Single.fromFuture(Future.delayed(
                  Duration(milliseconds: 100), () => throw Exception())),
              false);
          await cancelRule(Single.fromFuture(Future.delayed(
              Duration(milliseconds: 100), () => throw Exception())));
        });
      });

      group('Single.zip2', () {
        test('success + success', () async {
          final build = () => Single.zip2(
                Single.value(1),
                Single.timer(2, Duration(milliseconds: 100)),
                (int a, int b) => a + b,
              );
          await singleRule(
            build(),
            Either.right(3),
          );
          broadcastRule(build(), false);
          await cancelRule(build());
        });

        test('success + failure', () async {
          final build = () => Single.zip2(
                Single.value(1),
                Single<int>.error(Exception()),
                (int a, int b) => a + b,
              );
          await singleRule(
            build(),
            _exceptionLeft,
          );
          broadcastRule(build(), false);
          await cancelRule(build());
        });

        test('failure + success', () async {
          final build = () => Single.zip2(
                Single<int>.error(Exception()),
                Single.timer(2, Duration(milliseconds: 100)),
                (int a, int b) => a + b,
              );
          await singleRule(build(), _exceptionLeft);
          broadcastRule(build(), false);
          await cancelRule(build());
        });

        test('failure + failure', () async {
          final build = () => Single.zip2(
                Single<int>.error(Exception()),
                Single<int>.error(Exception())
                    .delay(Duration(milliseconds: 10)),
                (int a, int b) => a + b,
              );
          await singleRule(build(), _exceptionLeft);
          broadcastRule(build(), false);
          await cancelRule(build());
        });
      });
    });

    group('override', () {
      group('.distinct', () {
        test('.success', () async {
          await singleRule(
            Single.value(1).distinct(),
            Either.right(1),
          );
          broadcastRule(Single.value(1).distinct(), false);
          await cancelRule(Single.value(1).distinct());
        });

        test('.failure', () async {
          await singleRule(
            Single<void>.error(Exception()).distinct(),
            _exceptionLeft,
          );
          broadcastRule(Single<void>.error(Exception()).distinct(), false);
          await cancelRule(Single<void>.error(Exception()).distinct());
        });
      });

      group('.map', () {
        test('.success', () async {
          await singleRule(
            Single.value(1).map((event) => event.toString()),
            Either.right('1'),
          );
          broadcastRule(
              Single.value(1).map((event) => event.toString()), false);
          await cancelRule(Single.value(1).map((event) => event.toString()));
        });

        test('.failure', () async {
          await singleRule(
            Single.value(1).map((event) => throw Exception()),
            _exceptionLeft,
          );
          broadcastRule(
              Single.value(1).map((event) => throw Exception()), false);
          await cancelRule(Single.value(1).map((event) => throw Exception()));
        });
      });

      group('.asyncMap', () {
        group('.sync', () {
          test('.success', () async {
            await singleRule(
              Single.value(1).asyncMap((event) => event.toString()),
              Either.right('1'),
            );
            broadcastRule(
                Single.value(1).asyncMap((event) => event.toString()), false);
            await cancelRule(
                Single.value(1).asyncMap((event) => event.toString()));
          });

          test('.failure', () async {
            await singleRule(
              Single.value(1).asyncMap((event) => throw Exception()),
              _exceptionLeft,
            );
          });
        });

        group('.async', () {
          test('.success', () async {
            await singleRule(
              Single.value(1).asyncMap((event) async {
                await Future<void>.delayed(const Duration(milliseconds: 100));
                return event.toString();
              }),
              Either.right('1'),
            );
          });

          test('.failure', () async {
            await singleRule(
              Single.value(1).asyncMap((event) async {
                await Future<void>.delayed(const Duration(milliseconds: 100));
                throw Exception();
              }),
              _exceptionLeft,
            );
          });
        });
      });
    });

    group('singleOrError', () {
      test('returns itself', () async {
        await singleRule(
          Single.value(1).singleOrError(),
          Either.right(1),
        );

        final s = Single.value(1);
        expect(identical(s, s.singleOrError()), true);
        broadcastRule(s.singleOrError(), false);
      });

      test('from Stream of Controller', () async {
        Stream<int> buildStream() {
          final c = StreamController<int>();
          c.add(1);
          unawaited(c.close());

          return c.stream;
        }

        await singleRule(
          buildStream().singleOrError(),
          Either.right(1),
        );
        broadcastRule(buildStream().singleOrError(), false);
      });

      test('from Stream.value', () async {
        await singleRule(
          Stream.value(1).singleOrError(),
          Either.right(1),
        );
        broadcastRule(Stream.value(1).singleOrError(), false);
      });

      test('from Stream.error', () async {
        await singleRule(
          Stream<void>.error(Exception()).singleOrError(),
          _exceptionLeft,
        );
        broadcastRule(Stream<void>.error(Exception()).singleOrError(), false);
      });

      test('from Stream.empty', () async {
        await singleRule(
          Stream<int>.empty().singleOrError(),
          _APIContractViolationError(
              "Stream doesn't contains any data or error event."),
        );
        broadcastRule(Stream<int>.empty().singleOrError(), true);
      });

      test('from a Broadcast Stream', () async {
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
      });

      test('from multiple data events Stream (data -> data)', () async {
        await singleRule(
          Stream.fromIterable([1, 2, 3]).singleOrError(),
          _APIContractViolationError(
              'Stream contains more than one data event.'),
        );
        broadcastRule(Stream.fromIterable([1, 2, 3]).singleOrError(), false);
      });

      test('from both data and error events Stream (data -> error)', () async {
        final buildSingle = () => Rx.concat<int?>([
              Rx.timer(1, const Duration(milliseconds: 100)),
              Stream<int>.error(Exception())
                  .delay(const Duration(milliseconds: 100)),
              Rx.timer(null, const Duration(milliseconds: 100)),
            ]).singleOrError();

        await singleRule(
          buildSingle(),
          _APIContractViolationError(
              'Stream contains both data and error event.'),
        );
        broadcastRule(buildSingle(), false);
      });

      test('from both data and error events Stream (error -> data)', () async {
        final buildSingle = () => Rx.concat<int?>([
              Stream<int>.error(Exception())
                  .delay(const Duration(milliseconds: 100)),
              Rx.timer(1, const Duration(milliseconds: 100)),
              Rx.timer(null, const Duration(milliseconds: 100)),
            ]).singleOrError();

        await singleRule(
          buildSingle(),
          _APIContractViolationError(
              'Stream contains both data and error event.'),
        );
        broadcastRule(buildSingle(), false);
      });

      test('from multiple error events Stream (error -> error)', () async {
        final buildSingle = () => Rx.concat<int?>([
              Stream<int>.error(Exception())
                  .delay(const Duration(milliseconds: 100)),
              Stream<int>.error(Exception())
                  .delay(const Duration(milliseconds: 100)),
            ]).singleOrError();

        await singleRule(
          buildSingle(),
          _APIContractViolationError(
              'Stream contains more than one error event.'),
        );
        broadcastRule(buildSingle(), false);
      });
    });

    group('flatMapSingle', () {
      test('success -> success', () async {
        await singleRule(
          Single.value(1).flatMapSingle((i) => Single.value(i + 1)),
          Either.right(2),
        );
        await singleRule(
          Single.value(1).flatMapSingle(
              (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
          Either.right(2),
        );
      });

      test('success -> failure', () async {
        await singleRule(
          Single.value(22).flatMapSingle((i) => Single<int>.error(Exception())),
          _exceptionLeft,
        );
      });

      test('failure -> success', () async {
        await singleRule(
          Single<int>.error(Exception())
              .flatMapSingle((i) => Single.value(i + 1)),
          _exceptionLeft,
        );
      });

      test('failure -> failure', () async {
        await singleRule(
          Single<int>.error(Exception())
              .flatMapSingle((i) => Single<int>.error(Exception())),
          _exceptionLeft,
        );
      });
    });

    group('switchMapSingle', () {
      test('success -> success', () async {
        await singleRule(
          Single.value(1).switchMapSingle((i) => Single.value(i + 1)),
          Either.right(2),
        );
        await singleRule(
          Single.value(1).switchMapSingle(
              (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
          Either.right(2),
        );
      });

      test('success -> failure', () async {
        await singleRule(
          Single.value(22)
              .switchMapSingle((i) => Single<int>.error(Exception())),
          _exceptionLeft,
        );
      });

      test('failure -> success', () async {
        await singleRule(
          Single<int>.error(Exception())
              .switchMapSingle((i) => Single.value(i + 1)),
          _exceptionLeft,
        );
      });

      test('failure -> failure', () async {
        await singleRule(
          Single<int>.error(Exception())
              .switchMapSingle((i) => Single<int>.error(Exception())),
          _exceptionLeft,
        );
      });
    });

    group('exhaustMapSingle', () {
      test('success -> success', () async {
        await singleRule(
          Single.value(1).exhaustMapSingle((i) => Single.value(i + 1)),
          Either.right(2),
        );
        await singleRule(
          Single.value(1).exhaustMapSingle(
              (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
          Either.right(2),
        );
      });

      test('success -> failure', () async {
        await singleRule(
          Single.value(22)
              .exhaustMapSingle((i) => Single<int>.error(Exception())),
          _exceptionLeft,
        );
      });

      test('failure -> success', () async {
        await singleRule(
          Single<int>.error(Exception())
              .exhaustMapSingle((i) => Single.value(i + 1)),
          _exceptionLeft,
        );
      });

      test('failure -> failure', () async {
        await singleRule(
          Single<int>.error(Exception())
              .exhaustMapSingle((i) => Single<int>.error(Exception())),
          _exceptionLeft,
        );
      });
    });

    group('asyncExpandSingle', () {
      test('success -> success', () async {
        await singleRule(
          Single.value(1).asyncExpandSingle((i) => Single.value(i + 1)),
          Either.right(2),
        );
        await singleRule(
          Single.value(1).asyncExpandSingle(
              (i) => Single.timer(i + 1, const Duration(milliseconds: 100))),
          Either.right(2),
        );
      });

      test('success -> failure', () async {
        await singleRule(
          Single.value(22)
              .asyncExpandSingle((i) => Single<int>.error(Exception())),
          _exceptionLeft,
        );
      });

      test('failure -> success', () async {
        await singleRule(
          Single<int>.error(Exception())
              .asyncExpandSingle((i) => Single.value(i + 1)),
          _exceptionLeft,
        );
      });

      test('failure -> failure', () async {
        await singleRule(
          Single<int>.error(Exception())
              .asyncExpandSingle((i) => Single<int>.error(Exception())),
          _exceptionLeft,
        );
      });
    });

    test('Future.asSingle', () async {
      await singleRule(Future.value(1).asSingle(), Either.right(1));
      broadcastRule(Future.value(1).asSingle(), false);

      await singleRule(
          Future<void>.error(Exception()).asSingle(), _exceptionLeft);
      broadcastRule(Future<void>.error(Exception()).asSingle(), false);
    });

    test('(FutureOr<R> Function()).asSingle()', () async {
      await singleRule((() => 1).asSingle(), Either.right(1));
      await singleRule((() => 1).asSingle(reusable: true), Either.right(1));
      await singleRule((() => Future.value(1)).asSingle(), Either.right(1));
      await singleRule(
          (() => Future.value(1)).asSingle(reusable: true), Either.right(1));

      await singleRule((() => throw Exception()).asSingle(), _exceptionLeft);
      await singleRule(
          (() => throw Exception()).asSingle(reusable: true), _exceptionLeft);
      await singleRule(
          (() => Future<void>.error(Exception())).asSingle(), _exceptionLeft);
      await singleRule(
          (() => Future<void>.error(Exception())).asSingle(reusable: true),
          _exceptionLeft);
    });

    group('delay', () {
      test('success', () async {
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

      test('success', () async {
        await singleRule(
          Single<int>.error(Exception())
              .delay(const Duration(milliseconds: 100)),
          _exceptionLeft,
        );
        broadcastRule(
          Single<int>.error(Exception())
              .delay(const Duration(milliseconds: 100)),
          false,
        );
        await cancelRule(Single<int>.error(Exception()));
      });
    });
  });
}
