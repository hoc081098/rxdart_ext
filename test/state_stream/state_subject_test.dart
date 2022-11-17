import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void _expect<T>(StateSubject<T> s, T value) => expect(s.value, value);

void main() {
  group('StateSubject', () {
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
