// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import '../utils.dart';
import 'utils.dart';

void main() {
  group('singleOrError', () {
    test('returns itself', () async {
      await singleRule(
        // ignore: unnecessary_cast
        (Single.value(1) as Stream<int>).singleOrError(),
        Either.right(1),
      );

      await singleRule(
        // ignore: deprecated_member_use_from_same_package
        Single.value(1).singleOrError(),
        Either.right(1),
      );

      final s = Single.value(1);
      expect(
        // ignore: unnecessary_cast
        identical(s, (s as Stream<int>).singleOrError()),
        true,
      );
      // ignore: unnecessary_cast
      await broadcastRule((s as Stream<int>).singleOrError(), false);
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
      await broadcastRule(buildStream().singleOrError(), false);
    });

    test('from Stream.value', () async {
      await singleRule(
        Stream.value(1).singleOrError(),
        Either.right(1),
      );
      await broadcastRule(Stream.value(1).singleOrError(), false);
    });

    test('from Stream.error', () async {
      await singleRule(
        Stream<void>.error(Exception()).singleOrError(),
        exceptionLeft,
      );
      await broadcastRule(
          Stream<void>.error(Exception()).singleOrError(), false);
    });

    test('from Stream.empty', () async {
      await singleRule(
        Stream<int>.empty().singleOrError(),
        buildAPIContractViolationErrorWithMessage(
            "Stream doesn't contains any data or error event."),
      );
      await broadcastRule(Stream<int>.empty().singleOrError(), true);
    });

    test('from a Broadcast Stream', () async {
      final cb = StreamController<int>.broadcast(sync: true);
      cb.onListen = () {
        scheduleMicrotask(() {
          cb.add(1);
          cb.close();
        });
      };
      // ignore: no_leading_underscores_for_local_identifiers
      final _s = cb.stream.singleOrError();
      await singleRule(_s, Either.right(1));
      await broadcastRule(_s, true);
    });

    test('from multiple data events Stream (data -> data)', () async {
      await singleRule(
        Stream.fromIterable([1, 2, 3])
            .toSingleSubscriptionStream() // dart 2.18.0: The Stream.fromIterable stream can now be listened to more than once.
            .singleOrError(),
        buildAPIContractViolationErrorWithMessage(
            'Stream contains more than one data event.'),
      );
      await broadcastRule(
          Stream.fromIterable([1, 2, 3])
              .toSingleSubscriptionStream() // dart 2.18.0: The Stream.fromIterable stream can now be listened to more than once.
              .singleOrError(),
          false);
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
        buildAPIContractViolationErrorWithMessage(
            'Stream contains both data and error event.'),
      );
      await broadcastRule(buildSingle(), false);
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
        buildAPIContractViolationErrorWithMessage(
            'Stream contains both data and error event.'),
      );
      await broadcastRule(buildSingle(), false);
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
        buildAPIContractViolationErrorWithMessage(
            'Stream contains more than one error event.'),
      );
      await broadcastRule(buildSingle(), false);
    });
  });
}
