import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Single.asNullable', () {
    test('works', () {
      final single = Single.value(1);
      final Single<int?> asNullable = single.asNullable();

      expect(asNullable, isA<Single<int?>>());
      expect(asNullable, same(single));
    });

    test('asNullable with publishState', () async {
      final single = Single.value(1);
      final stateStream = single.asNullable().publishState(null);

      expect(stateStream, isA<StateConnectableStream<int?>>());
      expect(stateStream.value, null);

      scheduleMicrotask(() => stateStream.connect());
      await expectLater(stateStream, emitsInOrder([1]));
    });

    test('asNullable with publishValueSeeded', () async {
      final single = Single.value(1);
      final valueStream = single.asNullable().publishValueSeeded(null);

      expect(valueStream, isA<ValueConnectableStream<int?>>());
      expect(valueStream.value, null);

      scheduleMicrotask(() => valueStream.connect());
      await expectLater(valueStream, emitsInOrder([null, 1]));
    });
  });
}
