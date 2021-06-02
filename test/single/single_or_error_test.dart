import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'single_test_utils.dart';

void main() {
  group('singleOrError', () {
    test('returns itself', () async {
      await singleRule(
        SingleOrErrorStreamExtension(Single.value(1)).singleOrError(),
        Either.right(1),
      );

      final s = Single.value(1);
      expect(identical(s, SingleOrErrorStreamExtension(s).singleOrError()), true);
      broadcastRule(SingleOrErrorStreamExtension(s).singleOrError(), false);
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
        exceptionLeft,
      );
      broadcastRule(Stream<void>.error(Exception()).singleOrError(), false);
    });

    test('from Stream.empty', () async {
      await singleRule(
        Stream<int>.empty().singleOrError(),
        APIContractViolationErrorWithMessage(
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
        APIContractViolationErrorWithMessage(
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
        APIContractViolationErrorWithMessage(
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
        APIContractViolationErrorWithMessage(
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
        APIContractViolationErrorWithMessage(
            'Stream contains more than one error event.'),
      );
      broadcastRule(buildSingle(), false);
    });
  });
}
