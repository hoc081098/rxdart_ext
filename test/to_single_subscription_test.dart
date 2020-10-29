import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  test('To single-subscription stream', () {
    final singleSubscriptionStream =
        StreamController<int>.broadcast().stream.toSingleSubscriptionStream();
    expect(singleSubscriptionStream.isBroadcast, isFalse);

    singleSubscriptionStream.listen(null);
    expect(() => singleSubscriptionStream.listen(null), throwsStateError);
  });
}
