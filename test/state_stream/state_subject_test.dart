import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void _expect<T>(StateSubject<T> s, T value) => expect(s.value, value);

void main() {
  group('StateSubject', () {
    test('emits items to every subscriber', () async {
      final subject = StateSubject<int>(0);

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
      final subject = StateSubject<int>(0);

      scheduleMicrotask(() {
        subject.add(1);
        subject.add(2);
        subject.add(3);
        subject.close();
      });

      await expectLater(subject, emitsInOrder(<dynamic>[1, 2, 3, emitsDone]));
    });

    test('emits done event to listeners when the subject is closed', () async {
      final subject = StateSubject<int>(0);

      await expectLater(subject.isClosed, isFalse);

      scheduleMicrotask(() => subject.add(1));
      scheduleMicrotask(() => subject.close());

      await expectLater(subject.stream, emitsInOrder(<dynamic>[1, emitsDone]));
      await expectLater(subject.isClosed, isTrue);
    });

    test(
        'emits done event to listeners when the subject is closed (listen directly on Subject)',
        () async {
      final subject = StateSubject<int>(0);

      await expectLater(subject.isClosed, isFalse);

      scheduleMicrotask(() => subject.add(1));
      scheduleMicrotask(() => subject.close());

      await expectLater(subject, emitsInOrder(<dynamic>[1, emitsDone]));
      await expectLater(subject.isClosed, isTrue);
    });

    test('cannot emits error events to subscribers', () async {
      final subject = StateSubject<int>(0);

      expect(() => subject.addError(Exception()), throwsUnsupportedError);
    });

    test('emits the items from addStream', () async {
      final subject = StateSubject<int>(0);

      scheduleMicrotask(
          () => subject.addStream(Stream.fromIterable(const [1, 2, 3])));

      await expectLater(subject.stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('allows items to be added once addStream is complete', () async {
      final subject = StateSubject<int>(0);

      await subject.addStream(Stream.fromIterable(const [1, 2]));
      scheduleMicrotask(() => subject.add(3));

      await expectLater(subject.stream, emits(3));
    });

    test('does not allow events to be added when addStream is active',
        () async {
      final subject = StateSubject<int>(0);

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.add(1), throwsStateError);
    });

    test('does not allow subject to be closed when addStream is active',
        () async {
      final subject = StateSubject<int>(0);

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.close(), throwsStateError);
    });

    test(
        'does not allow addStream to add items when previous addStream is active',
        () async {
      final subject = StateSubject<int>(0);

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.addStream(Stream.fromIterable(const [1])),
          throwsStateError);
    });

    test('returns onListen callback set in constructor', () async {
      final testOnListen = () {};

      final subject = StateSubject<int>(0, onListen: testOnListen);

      await expectLater(subject.onListen, testOnListen);
    });

    test('sets onListen callback', () async {
      final testOnListen = () {};

      final subject = StateSubject<int>(0);

      await expectLater(subject.onListen, isNull);

      subject.onListen = testOnListen;

      await expectLater(subject.onListen, testOnListen);
    });

    test('returns onCancel callback set in constructor', () async {
      final onCancel = () => Future<void>.value(null);

      final subject = StateSubject<int>(0, onCancel: onCancel);

      await expectLater(subject.onCancel, onCancel);
    });

    test('sets onCancel callback', () async {
      final testOnCancel = () {};

      final subject = StateSubject<int>(0);

      await expectLater(subject.onCancel, isNull);

      subject.onCancel = testOnCancel;

      await expectLater(subject.onCancel, testOnCancel);
    });

    test('reports if a listener is present', () async {
      final subject = StateSubject<int>(0);

      await expectLater(subject.hasListener, isFalse);

      subject.stream.listen(null);

      await expectLater(subject.hasListener, isTrue);
    });

    test('onPause unsupported', () {
      final subject = StateSubject<int>(0);

      expect(subject.isPaused, isFalse);
      expect(() => subject.onPause, throwsUnsupportedError);
      expect(() => subject.onPause = () {}, throwsUnsupportedError);
    });

    test('onResume unsupported', () {
      final subject = StateSubject<int>(0);

      expect(() => subject.onResume, throwsUnsupportedError);
      expect(() => subject.onResume = () {}, throwsUnsupportedError);
    });

    test('returns controller sink', () async {
      final subject = StateSubject<int>(0);

      await expectLater(subject.sink, TypeMatcher<EventSink<int>>());
    });

    test('correctly closes done Future', () async {
      final subject = StateSubject<int>(0);

      scheduleMicrotask(() => subject.close());

      await expectLater(subject.done, completes);
    });

    test('can be listened to multiple times', () async {
      final subject = StateSubject<int>(0);
      final stream = subject.stream;

      scheduleMicrotask(() => subject.add(1));
      await expectLater(stream, emits(1));

      scheduleMicrotask(() => subject.add(2));
      await expectLater(stream, emits(2));
    });

    test('always returns the same stream', () async {
      final subject = StateSubject<int>(0);

      await expectLater(subject.stream, equals(subject.stream));
    });

    test('adding to sink has same behavior as adding to Subject itself',
        () async {
      final subject = StateSubject<int>(0);

      scheduleMicrotask(() {
        subject.sink.add(1);
        subject.sink.add(2);
        subject.sink.add(3);
        subject.sink.close();
      });

      await expectLater(
          subject.stream, emitsInOrder(<dynamic>[1, 2, 3, emitsDone]));
    });

    test('is always treated as a broadcast Stream', () async {
      final subject = StateSubject<int>(0);
      final stream = subject.asyncMap((event) => Future.value(event));

      expect(subject.isBroadcast, isTrue);
      expect(stream.isBroadcast, isTrue);
    });

    test('allows to access latest value', () {
      final subject = StateSubject<int>(0);
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

    // ------------------------------------------------------------------------

    test('add and close', () {
      {
        final s = StateSubject(0);
        _expect(s, 0);
        expect(s, emitsInOrder(<Object>[1, 2, emitsDone]));

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
        final s = StateSubject(0);
        _expect(s, 0);
        expect(s, emitsInOrder(<Object>[1, 3, 1, 2, emitsDone]));

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
      final s = StateSubject(0);
      expect(() => s.addError(0), throwsUnsupportedError);
    });

    test('addStream', () async {
      {
        final s = StateSubject(0);
        expect(s, emitsDone);

        await s.addStream(Stream.value(0));
        await s.close();
      }

      {
        final s = StateSubject(0);
        expect(s, emitsInOrder(<Object>[1, 2, 3, 4, emitsDone]));

        await s.addStream(Stream.fromIterable([0, 1, 1, 2, 3, 4]));
        await s.close();
      }

      {
        final s = StateSubject(0);
        expect(s, emitsInOrder(<Object>[2, 1, 2, 3, 4, emitsDone]));

        s.add(2);
        await s.addStream(Stream.fromIterable([2, 1, 1, 2, 3, 4]));
        await s.close();
      }

      {
        final s = StateSubject(0);

        await runZonedGuarded(
          () => s.addStream(Stream.error(Exception())),
          (e, s) => expect(e, isUnsupportedError),
        );
      }
    });

    test('get error', () {
      expect(StateSubject(0).errorOrNull, isNull);
      expect(StateSubject(0).stackTrace, isNull);
    });

    test('get stream', () {
      final s = StateSubject(0);

      expect(s.stream, isA<StateStream<int>>());
      expect(s.stream, isNot(same(s)));
      expect(s.stream.value, 0);
      expect(s.stream, emitsInOrder(<Object>[1, 2]));

      s.add(0);
      s.add(0);
      s.add(1);
      s.add(1);
      s.add(2);
      s.add(2);
    });

    test('stream returns a read-only stream', () async {
      final subject = StateSubject<int>(0)..add(1);

      // streams returned by StateSubject are read-only stream,
      // ie. they don't support adding events.
      expect(subject.stream, isNot(isA<StateSubject<int>>()));
      expect(subject.stream, isNot(isA<Sink<int>>()));
      expect(subject.stream, isNot(same(subject)));

      expect(
        subject.stream,
        isA<StateStream<int>>().having(
          (v) => v.value,
          'StateSubject.stream.value',
          1,
        ),
      );

      // StateSubject.stream is a broadcast stream
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
        final s = StateSubject(0);
        expect(
          s.flatMap((value) => Stream.value(value)),
          emitsInOrder(<Object>[1, 2, 3]),
        );

        s.add(1);
        s.add(2);
        s.add(3);
      }

      {
        final s = StateSubject(0, sync: true);
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
}
