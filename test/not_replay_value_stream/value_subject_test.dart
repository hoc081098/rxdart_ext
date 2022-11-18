// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import '../utils.dart';

// ignore_for_file: close_sinks

void main() {
  // Copy from https://github.com/ReactiveX/rxdart/blob/master/test/subject/publish_subject_test.dart
  group('ValueSubject', () {
    test('emits items to every subscriber', () async {
      final subject = ValueSubject<int>(0);

      scheduleMicrotask(() {
        subject.add(1);
        subject.add(2);
        subject.add(3);
        subject.close();
      });

      await expectLater(
          subject.stream, emitsInOrder(<dynamic>[1, 2, 3, emitsDone]));
    });

    test(
        'emits items to every subscriber that subscribe directly to the Subject',
        () async {
      final subject = ValueSubject<int>(0);

      scheduleMicrotask(() {
        subject.add(1);
        subject.add(2);
        subject.add(3);
        subject.close();
      });

      await expectLater(subject, emitsInOrder(<dynamic>[1, 2, 3, emitsDone]));
    });

    test('emits done event to listeners when the subject is closed', () async {
      final subject = ValueSubject<int>(0);

      await expectLater(subject.isClosed, isFalse);

      scheduleMicrotask(() => subject.add(1));
      scheduleMicrotask(() => subject.close());

      await expectLater(subject.stream, emitsInOrder(<dynamic>[1, emitsDone]));
      await expectLater(subject.isClosed, isTrue);
    });

    test(
        'emits done event to listeners when the subject is closed (listen directly on Subject)',
        () async {
      final subject = ValueSubject<int>(0);

      await expectLater(subject.isClosed, isFalse);

      scheduleMicrotask(() => subject.add(1));
      scheduleMicrotask(() => subject.close());

      await expectLater(subject, emitsInOrder(<dynamic>[1, emitsDone]));
      await expectLater(subject.isClosed, isTrue);
    });

    test('emits error events to subscribers', () async {
      final subject = ValueSubject<int>(0);

      scheduleMicrotask(() => subject.addError(Exception()));

      await expectLater(subject.stream, emitsError(isException));
    });

    test('emits error events to subscribers (listen directly on Subject)',
        () async {
      final subject = ValueSubject<int>(0);

      scheduleMicrotask(() => subject.addError(Exception()));

      await expectLater(subject, emitsError(isException));
    });

    test('emits the items from addStream', () async {
      final subject = ValueSubject<int>(0);

      scheduleMicrotask(
          () => subject.addStream(Stream.fromIterable(const [1, 2, 3])));

      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('allows items to be added once addStream is complete', () async {
      final subject = ValueSubject<int>(0);

      await subject.addStream(Stream.fromIterable(const [1, 2]));
      scheduleMicrotask(() => subject.add(3));

      await expectLater(subject.stream, emits(3));
    });

    test('allows items to be added once addStream is completes with an error',
        () async {
      final subject = ValueSubject<int>(0);

      unawaited(subject
          .addStream(Stream<int>.error(Exception()), cancelOnError: true)
          .whenComplete(() => subject.add(1)));

      await expectLater(subject.stream,
          emitsInOrder(<StreamMatcher>[emitsError(isException), emits(1)]));
    });

    test('does not allow events to be added when addStream is active',
        () async {
      final subject = ValueSubject<int>(0);

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.add(1), throwsStateError);
    });

    test('does not allow errors to be added when addStream is active',
        () async {
      final subject = ValueSubject<int>(0);

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.addError(Error()), throwsStateError);
    });

    test('does not allow subject to be closed when addStream is active',
        () async {
      final subject = ValueSubject<int>(0);

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.close(), throwsStateError);
    });

    test(
        'does not allow addStream to add items when previous addStream is active',
        () async {
      final subject = ValueSubject<int>(0);

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.addStream(Stream.fromIterable(const [1])),
          throwsStateError);
    });

    test('returns onListen callback set in constructor', () async {
      final testOnListen = () {};

      final subject = ValueSubject<int>(0, onListen: testOnListen);

      await expectLater(subject.onListen, testOnListen);
    });

    test('sets onListen callback', () async {
      final testOnListen = () {};

      final subject = ValueSubject<int>(0);

      await expectLater(subject.onListen, isNull);

      subject.onListen = testOnListen;

      await expectLater(subject.onListen, testOnListen);
    });

    test('returns onCancel callback set in constructor', () async {
      final onCancel = () => Future<void>.value(null);

      final subject = ValueSubject<int>(0, onCancel: onCancel);

      await expectLater(subject.onCancel, onCancel);
    });

    test('sets onCancel callback', () async {
      final testOnCancel = () {};

      final subject = ValueSubject<int>(0);

      await expectLater(subject.onCancel, isNull);

      subject.onCancel = testOnCancel;

      await expectLater(subject.onCancel, testOnCancel);
    });

    test('reports if a listener is present', () async {
      final subject = ValueSubject<int>(0);

      await expectLater(subject.hasListener, isFalse);

      subject.stream.listen(null);

      await expectLater(subject.hasListener, isTrue);
    });

    test('onPause unsupported', () {
      final subject = ValueSubject<int>(0);

      expect(subject.isPaused, isFalse);
      expect(() => subject.onPause, throwsUnsupportedError);
      expect(() => subject.onPause = () {}, throwsUnsupportedError);
    });

    test('onResume unsupported', () {
      final subject = ValueSubject<int>(0);

      expect(() => subject.onResume, throwsUnsupportedError);
      expect(() => subject.onResume = () {}, throwsUnsupportedError);
    });

    test('returns controller sink', () async {
      final subject = ValueSubject<int>(0);

      await expectLater(subject.sink, TypeMatcher<EventSink<int>>());
    });

    test('correctly closes done Future', () async {
      final subject = ValueSubject<int>(0);

      scheduleMicrotask(() => subject.close());

      await expectLater(subject.done, completes);
    });

    test('can be listened to multiple times', () async {
      final subject = ValueSubject<int>(0);
      final stream = subject.stream;

      scheduleMicrotask(() => subject.add(1));
      await expectLater(stream, emits(1));

      scheduleMicrotask(() => subject.add(2));
      await expectLater(stream, emits(2));
    });

    test('always returns the same stream', () async {
      final subject = ValueSubject<int>(0);

      await expectLater(subject.stream, equals(subject.stream));
    });

    test('adding to sink has same behavior as adding to Subject itself',
        () async {
      final subject = ValueSubject<int>(0);

      scheduleMicrotask(() {
        subject.sink.add(1);
        expect(subject.value, 1);

        subject.sink.add(2);
        expect(subject.value, 2);

        subject.sink.add(3);
        expect(subject.value, 3);

        subject.sink.close();
      });

      await expectLater(
          subject.stream, emitsInOrder(<dynamic>[1, 2, 3, emitsDone]));
    });

    test('is always treated as a broadcast Stream', () async {
      final subject = ValueSubject<int>(0);
      final stream = subject.asyncMap((event) => Future.value(event));

      expect(subject.isBroadcast, isTrue);
      expect(stream.isBroadcast, isTrue);
    });

    test('allows to access latest value', () {
      final subject = ValueSubject<int>(0);
      void test(int expectedValue) {
        expect(subject.value, expectedValue);
        expect(subject.hasValue, isTrue);
        expect(subject.errorOrNull, isNull);
        expect(subject.hasError, isFalse);
      }

      test(0);

      for (var i = 0; i < 10; i++) {
        subject.add(i);
        test(i);
      }
    });

    test('allows to access latest error', () {
      final subject = ValueSubject<int>(0);

      void test(int expectedError) {
        expect(subject.value, 0);
        expect(subject.hasValue, isTrue);
        expect(subject.error, expectedError);
        expect(subject.hasError, isTrue);
      }

      for (var i = 0; i < 10; i++) {
        subject.addError(i);
        test(i);
      }
    });

    // ------------------------------------------------------------------------

    group('methods', () {
      void _expect<T>(ValueSubject<T> s, T value) => expect(s.value, value);

      test('add and close', () {
        {
          final s = ValueSubject(0);
          _expect(s, 0);
          expect(s, emitsInOrder(<Object>[0, 1, 1, 2, 2, 2, emitsDone]));

          s.add(0);
          _expect(s, 0);
          s.add(1);
          _expect(s, 1);
          s.add(1);
          _expect(s, 1);
          s.add(2);
          _expect(s, 2);
          s.add(2);
          _expect(s, 2);
          s.add(2);
          _expect(s, 2);

          s.close();
        }

        {
          final s = ValueSubject(0);
          _expect(s, 0);
          expect(s, emitsInOrder(<Object>[1, 3, 3, 1, 2, emitsDone]));

          s.add(1);
          _expect(s, 1);
          s.add(3);
          _expect(s, 3);
          s.add(3);
          _expect(s, 3);
          s.add(1);
          _expect(s, 1);
          s.add(2);
          _expect(s, 2);

          s.close();
        }
      });

      test('addError', () {
        final s = ValueSubject(0);

        scheduleMicrotask(() {
          s.add(1);
          s.addError(Exception());
          s.add(2);
        });

        expect(
          s,
          emitsInOrder(<Object>[
            1,
            emitsError(isException),
            2,
          ]),
        );
      });

      test('addStream', () async {
        {
          final s = ValueSubject(0);
          expect(s, emits(0));

          await s.addStream(Stream.value(0));
          await s.close();
        }

        {
          final s = ValueSubject(0);
          expect(s, emitsInOrder(<Object>[0, 1, 1, 2, 3, 4, emitsDone]));

          await s.addStream(Stream.fromIterable([0, 1, 1, 2, 3, 4]));
          await s.close();
        }

        {
          final s = ValueSubject(0);
          expect(s, emitsInOrder(<Object>[2, 2, 1, 1, 2, 3, 4, emitsDone]));

          s.add(2);
          await s.addStream(Stream.fromIterable([2, 1, 1, 2, 3, 4]));
          await s.close();
        }

        {
          final s = ValueSubject(0);
          expect(s, emitsError(isException));

          await s.addStream(Stream.error(Exception()));
          await s.close();
        }
      });

      test('get error', () {
        expect(ValueSubject(0).errorOrNull, isNull);
        expect(ValueSubject(0).stackTrace, isNull);
      });

      test('get stream', () {
        final s = ValueSubject(0);

        expect(s.stream, isA<NotReplayValueStream<int>>());
        expect(s.stream, isNot(same(s)));
        expect(s.stream.value, 0);
        expect(s.stream, emitsInOrder(<Object>[0, 0, 1, 1, 2, 2]));

        s.add(0);
        s.add(0);
        s.add(1);
        s.add(1);
        s.add(2);
        s.add(2);
      });

      test('stream returns a read-only stream', () async {
        final subject = ValueSubject<int>(0)..add(1);

        // streams returned by ValueSubject are read-only stream,
        // ie. they don't support adding events.
        expect(subject.stream, isNot(isA<ValueSubject<int>>()));
        expect(subject.stream, isNot(isA<Sink<int>>()));
        expect(subject.stream, isNot(same(subject)));

        expect(
          subject.stream,
          isA<NotReplayValueStream<int>>().having(
            (v) => v.value,
            'ValueSubject.stream.value',
            1,
          ),
        );

        // ValueSubject.stream is a broadcast stream
        {
          final stream = subject.stream;
          expect(stream.isBroadcast, isTrue);

          scheduleMicrotask(() => subject.add(2));
          await expectLater(stream, emitsInOrder(<Object>[2]));

          scheduleMicrotask(() => subject.add(3));
          await expectLater(stream, emitsInOrder(<Object>[3]));
        }

        // streams returned by the same subject are considered equal,
        // but not identical
        expect(identical(subject.stream, subject.stream), isFalse);
        expect(subject.stream == subject.stream, isTrue);
      });

      test('Rx', () {
        {
          final s = ValueSubject(0);
          expect(
            s.flatMap((value) => Stream.value(value)),
            emitsInOrder(<Object>[1, 2, 3]),
          );

          s.add(1);
          s.add(2);
          s.add(3);
        }

        {
          final s = ValueSubject(0, sync: true);
          expect(
            s.flatMap((value) => Stream.value(value)),
            emitsInOrder(<Object>[1, 2, 3]),
          );

          s.add(1);
          s.add(2);
          s.add(3);
        }
      });
    });
  });
}
