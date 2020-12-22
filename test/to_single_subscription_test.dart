import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('Stream.toSingleSubscriptionStream', () {
    test('To single-subscription stream', () {
      final singleSubscriptionStream =
          StreamController<int>.broadcast().stream.toSingleSubscriptionStream();
      expect(singleSubscriptionStream.isBroadcast, isFalse);

      singleSubscriptionStream.listen(null);
      expect(() => singleSubscriptionStream.listen(null), throwsStateError);
    });

    test('Emitting values since listening', () {
      final streamController = StreamController<int>.broadcast(sync: true);

      final singleSubscriptionStream =
          streamController.stream.toSingleSubscriptionStream();
      streamController.add(-1);
      streamController.add(0);

      expect(
        singleSubscriptionStream,
        emitsInOrder(<dynamic>[1, 2, 3, emitsDone]),
      );

      streamController.add(1);
      streamController.add(2);
      streamController.add(3);
      streamController.close();
    });

    test('Assert isBroadcast', () {
      Stream<void>.empty().toSingleSubscriptionStream();

      expect(
        () => Stream.value(1).toSingleSubscriptionStream(),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
