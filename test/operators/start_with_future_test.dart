import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Stream.startWithFuture',
    () async {
      final stream =
          Stream.fromIterable([1, 2, 3]).startWithFuture(Future(() async => 0));

      expect(stream, emitsInOrder(<int>[0, 1, 2, 3]));
    },
  );
}
