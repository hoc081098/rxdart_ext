import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'single_test_utils.dart';

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
        await singleRule(build(), exceptionLeft);
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
            await singleRule(build1(), exceptionLeft);
            broadcastRule(build1(), false);
            await cancelRule(build1());

            final build2 = () =>
                Single.fromCallable(() => throw Exception(), reusable: true);
            await singleRule(build2(), exceptionLeft);
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
            await singleRule(build1(), exceptionLeft);
            broadcastRule(build1(), false);
            await cancelRule(build1());

            await singleRule(
              Single.fromCallable(() async => throw Exception(),
                  reusable: true),
              exceptionLeft,
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
            exceptionLeft,
          );
          broadcastRule(
              Single<String>.defer(() => Single.error(Exception())), false);
          await cancelRule(
              Single<String>.defer(() => Single.error(Exception())));

          await singleRule(
            Single<String>.defer(() => Single.error(Exception()),
                reusable: true),
            exceptionLeft,
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
          await singleRule(
              Single<int>.fromFuture(Future.error(Exception())), exceptionLeft);
          broadcastRule(
              Single<int>.fromFuture(Future.error(Exception())), false);
          await cancelRule(Single<int>.fromFuture(Future.error(Exception())));

          await singleRule(
            Single.fromFuture(Future.delayed(
                Duration(milliseconds: 100), () => throw Exception())),
            exceptionLeft,
          );
          broadcastRule(
              Single.fromFuture(Future.delayed(
                  Duration(milliseconds: 100), () => throw Exception())),
              false);
          await cancelRule(Single.fromFuture(Future.delayed(
              Duration(milliseconds: 100), () => throw Exception())));
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
            exceptionLeft,
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
            exceptionLeft,
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
              exceptionLeft,
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
              exceptionLeft,
            );
          });
        });
      });

      group('.cast', () {
        test('.success', () async {
          final build = () => Single<Object>.value(1).cast<int>();
          await singleRule(build(), Either.right(1));
          broadcastRule(build(), false);
          await cancelRule(build());
        });

        test('.failure', () async {
          final build1 = () => Single<Object>.value(1).cast<String>();
          await singleRule(
              build1(), Either<Object, String>.left(isA<TypeError>()));
          broadcastRule(build1(), false);
          await cancelRule(build1());

          final build2 = () => Single<int>.error(Exception());
          await singleRule(build2(), exceptionLeft);
          broadcastRule(build2(), false);
          await cancelRule(build2());
        });
      });
    });
  });
}
