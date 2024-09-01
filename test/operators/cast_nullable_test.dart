import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('asNullable', () {
    test('works', () {
      final stream = Stream.fromIterable([1, 2, 3, 4]);
      final asNullable = stream.asNullable();

      expect(asNullable, isA<Stream<int?>>());
      expect(asNullable, same(stream));
    });

    test('asNullable with publishState', () async {
      final stream = Stream.fromIterable([1, 1, 2, 2, 3, 3, 4, 4]);
      final stateStream = stream.asNullable().publishState(null);

      expect(stateStream, isA<StateConnectableStream<int?>>());
      expect(stateStream.value, null);

      scheduleMicrotask(() => stateStream.connect());
      await expectLater(stateStream, emitsInOrder([1, 2, 3, 4]));
    });

    test('asNullable with publishValueSeeded', () async {
      final stream = Stream.fromIterable([1, 1, 2, 2, 3, 3, 4, 4]);
      final valueStream = stream.asNullable().publishValueSeeded(null);

      expect(valueStream, isA<ValueConnectableStream<int?>>());
      expect(valueStream.value, null);

      scheduleMicrotask(() => valueStream.connect());
      await expectLater(
          valueStream, emitsInOrder([null, 1, 1, 2, 2, 3, 3, 4, 4]));
    });
  });
}
