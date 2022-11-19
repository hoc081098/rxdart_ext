// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'utils.dart';

class TestResource {
  var _isClosed = false;

  void close() {
    if (_isClosed) {
      throw StateError('Already closed');
    }
    _isClosed = true;
  }

  bool get isClosed => _isClosed;
}

const cases = ['success', 'failure'];

List<List<String>> generateAllCasesWithLength(int n) {
  if (n == 0) {
    return [];
  }

  if (n == 1) {
    return cases.map((e) => [e]).toList();
  }

  return generateAllCasesWithLength(n - 1)
      .expand((prev) => cases.map((e) => [...prev, e]))
      .toList();
}

void main() {
  group('RxSingles.zip2', () {
    test('success + success', () async {
      final build = () => RxSingles.zip2(
            Single.value(1),
            Single.timer(2, Duration(milliseconds: 100)),
            (int a, int b) => a + b,
          );
      await singleRule(
        build(),
        Either.right(3),
      );
      await broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('success + failure', () async {
      final build = () => RxSingles.zip2(
            Single.value(1),
            Single<int>.error(Exception()),
            (int a, int b) => a + b,
          );
      await singleRule(
        build(),
        exceptionLeft,
      );
      await broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('failure + success', () async {
      final build = () => RxSingles.zip2(
            Single<int>.error(Exception()),
            Single.timer(2, Duration(milliseconds: 100)),
            (int a, int b) => a + b,
          );
      await singleRule(build(), exceptionLeft);
      await broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('failure + failure', () async {
      final build = () => RxSingles.zip2(
            Single<int>.error(Exception()),
            Single<int>.error(Exception()).delay(Duration(milliseconds: 10)),
            (int a, int b) => a + b,
          );
      await singleRule(build(), exceptionLeft);
      await broadcastRule(build(), false);
      await cancelRule(build());
    });
  });

  group('RxSingles.forkJoin', () {
    final getSingle1 = (String c1) =>
        c1 == 'success' ? Single.value(1) : Single<int>.error(Exception());

    final getSingle2 = (String c2) =>
        (c2 == 'success' ? Single.value(2) : Single<int>.error(Exception()))
            .delay(const Duration(milliseconds: 5));

    final getSingle3 = (String c3) =>
        (c3 == 'success' ? Single.value(3) : Single<int>.error(Exception()))
            .delay(const Duration(milliseconds: 10));

    final getSingle4 = (String c4) =>
        (c4 == 'success' ? Single.value(4) : Single<int>.error(Exception()))
            .delay(const Duration(milliseconds: 15));

    final getSingle5 = (String c5) =>
        (c5 == 'success' ? Single.value(5) : Single<int>.error(Exception()))
            .delay(const Duration(milliseconds: 20));

    final getSingle6 = (String c6) =>
        (c6 == 'success' ? Single.value(6) : Single<int>.error(Exception()))
            .delay(const Duration(milliseconds: 25));

    final getSingle7 = (String c7) =>
        (c7 == 'success' ? Single.value(7) : Single<int>.error(Exception()))
            .delay(const Duration(milliseconds: 30));

    int sum([int? a, int? b, int? c, int? d, int? e, int? f, int? g]) =>
        (a ?? 0) +
        (b ?? 0) +
        (c ?? 0) +
        (d ?? 0) +
        (e ?? 0) +
        (f ?? 0) +
        (g ?? 0);

    Either<Object, Object> expectedValue(List<String> cases) =>
        cases.every((c) => c == 'success')
            ? (cases.length * (cases.length + 1) ~/ 2).right<Object>()
            : exceptionLeft;

    group('forkJoin2', () {
      test('success + success', () async {
        final build = () => RxSingles.forkJoin2(
              Single.value(1),
              Single.timer(2, Duration(milliseconds: 100)),
              (int a, int b) => a + b,
            );
        await singleRule(
          build(),
          Either.right(3),
        );
        await broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('success + failure', () async {
        final build = () => RxSingles.forkJoin2(
              Single.value(1),
              Single<int>.error(Exception()),
              (int a, int b) => a + b,
            );
        await singleRule(
          build(),
          exceptionLeft,
        );
        await broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('failure + success', () async {
        final build = () => RxSingles.forkJoin2(
              Single<int>.error(Exception()),
              Single.timer(2, Duration(milliseconds: 100)),
              (int a, int b) => a + b,
            );
        await singleRule(build(), exceptionLeft);
        await broadcastRule(build(), false);
        await cancelRule(build());
      });

      test('failure + failure', () async {
        final build = () => RxSingles.forkJoin2(
              Single<int>.error(Exception()),
              Single<int>.error(Exception()).delay(Duration(milliseconds: 10)),
              (int a, int b) => a + b,
            );
        await singleRule(build(), exceptionLeft);
        await broadcastRule(build(), false);
        await cancelRule(build());
      });
    });

    group('forkJoin3', () {
      for (final e in generateAllCasesWithLength(3)) {
        final c1 = e[0];
        final c2 = e[1];
        final c3 = e[2];

        test('$c1 + $c2 + $c3', () async {
          final build = () => RxSingles.forkJoin3(
              getSingle1(c1), getSingle2(c2), getSingle3(c3), sum);

          await singleRule(build(), expectedValue(e));
          await broadcastRule(build(), false);
          await cancelRule(build());
        });
      }
    });

    group('forkJoin4', () {
      for (final e in generateAllCasesWithLength(4)) {
        final c1 = e[0];
        final c2 = e[1];
        final c3 = e[2];
        final c4 = e[3];

        test('$c1 + $c2 + $c3 + $c4', () async {
          final build = () => RxSingles.forkJoin4(
                getSingle1(c1),
                getSingle2(c2),
                getSingle3(c3),
                getSingle4(c4),
                sum,
              );

          await singleRule(build(), expectedValue(e));
          await broadcastRule(build(), false);
          await cancelRule(build());
        });
      }
    });

    group('forkJoin5', () {
      for (final e in generateAllCasesWithLength(5)) {
        final c1 = e[0];
        final c2 = e[1];
        final c3 = e[2];
        final c4 = e[3];
        final c5 = e[4];

        test('$c1 + $c2 + $c3 + $c4 + $c5', () async {
          final build = () => RxSingles.forkJoin5(
                getSingle1(c1),
                getSingle2(c2),
                getSingle3(c3),
                getSingle4(c4),
                getSingle5(c5),
                sum,
              );

          await singleRule(build(), expectedValue(e));
          await broadcastRule(build(), false);
          await cancelRule(build());
        });
      }
    });

    group('forkJoin6', () {
      for (final e in generateAllCasesWithLength(6)) {
        final c1 = e[0];
        final c2 = e[1];
        final c3 = e[2];
        final c4 = e[3];
        final c5 = e[4];
        final c6 = e[5];

        test('$c1 + $c2 + $c3 + $c4 + $c5 + $c6', () async {
          final build = () => RxSingles.forkJoin6(
                getSingle1(c1),
                getSingle2(c2),
                getSingle3(c3),
                getSingle4(c4),
                getSingle5(c5),
                getSingle6(c6),
                sum,
              );

          await singleRule(build(), expectedValue(e));
          await broadcastRule(build(), false);
          await cancelRule(build());
        });
      }
    });

    group('forkJoin7', () {
      for (final e in generateAllCasesWithLength(7)) {
        final c1 = e[0];
        final c2 = e[1];
        final c3 = e[2];
        final c4 = e[3];
        final c5 = e[4];
        final c6 = e[5];
        final c7 = e[6];

        test('$c1 + $c2 + $c3 + $c4 + $c5 + $c6 + $c7', () async {
          final build = () => RxSingles.forkJoin7(
                getSingle1(c1),
                getSingle2(c2),
                getSingle3(c3),
                getSingle4(c4),
                getSingle5(c5),
                getSingle6(c6),
                getSingle7(c7),
                sum,
              );

          await singleRule(build(), expectedValue(e));
          await broadcastRule(build(), false);
          await cancelRule(build());
        });
      }
    });
  });

  group('RxSingles.using', () {
    test('resourceFactory throws', () async {
      final build = () => RxSingles.using<int, TestResource>(
            () => throw Exception(),
            (r) => fail('should not be called'),
            (r) => fail('should not be called'),
          );

      await singleRule(build(), exceptionLeft);
      await broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('success', () async {
      TestResource? resource;

      void clear() {
        resource = null;
      }

      final build = () {
        if (resource != null) {
          throw StateError('Resource already created');
        }
        return RxSingles.using<TestResource, TestResource>(
          () => resource = TestResource(),
          (r) => Single.value(r),
          (r) => r.close(),
        );
      };

      await singleRule(build(), isA<TestResource>().right());
      expect(resource!.isClosed, true);

      clear();
      await broadcastRule(build(), false);

      clear();
      await cancelRule(build());
      expect(resource == null || resource!.isClosed, true);

      clear();
      await cancelRule(build(), Duration.zero);
      expect(resource == null || resource!.isClosed, true);
    });

    test('failure', () async {
      TestResource? resource;

      void clear() {
        resource = null;
      }

      final build = () {
        if (resource != null) {
          throw StateError('Resource already created');
        }
        return RxSingles.using<TestResource, TestResource>(
          () => resource = TestResource(),
          (r) => Single.error(Exception()),
          (r) => r.close(),
        );
      };

      await singleRule(build(), exceptionLeft);
      expect(resource!.isClosed, true);

      clear();
      await broadcastRule(build(), false);

      clear();
      await cancelRule(build());
      expect(resource == null || resource!.isClosed, true);

      clear();
      await cancelRule(build(), Duration.zero);
      expect(resource == null || resource!.isClosed, true);
    });

    test('disposer throws', () async {
      final build = () => RxSingles.using<TestResource, TestResource>(
            () => TestResource(),
            (r) => Single.value(r),
            (r) => throw Exception('Disposer'),
          );

      final onError = (Object error, StackTrace stack) {
        expect(error, isA<Exception>());
        expect(error.toString(), 'Exception: Disposer');
      };
      await runZonedGuarded(
        () => singleRule(build(), isA<TestResource>().right()),
        onError,
      );
      await runZonedGuarded(
        () => broadcastRule(build(), false),
        onError,
      );
      await runZonedGuarded(
        () => cancelRule(build()),
        onError,
      );
    });
  });
}
