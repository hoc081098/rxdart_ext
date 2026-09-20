import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Stream.startWithFuture',
    () async {
      final stream = _createStreamForTest().startWithFuture(_startFuture());

      expect(stream, emitsInOrder(<int>[0, 1, 2, 3]));
    },
  );
}

Future<int> _startFuture() async {
  await Future<void>.delayed(Duration(seconds: 1, milliseconds: 500));
  return 0;
}

Stream<int> _createStreamForTest() async* {
  yield 1;

  await Future<void>.delayed(Duration(seconds: 1));

  yield 2;
  yield 3;
}
