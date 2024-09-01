import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  test('StateStream.asBroadcastStream', () async {
    final elements = [0, 1, 1, 2, 3, 4, 4];
    final expected = <Object>[1, 2, 3, 4, emitsDone];

    // ignore: no_leading_underscores_for_local_identifiers
    Future<void> _test(StateStream<int> stream, StateStream<int> source) async {
      expect(identical(stream.equals, source.equals), true);
      expect(stream.errorOrNull, null);
      expect(stream.stackTrace, null);
      expect(stream.value, 0);
      expect(stream.valueOrNull, 0);
      expect(stream.hasValue, true);
      expect(stream.hasError, false);
      expect(stream.isBroadcast, true);

      expect(stream, emitsInOrder(expected));
      expect(stream, emitsInOrder(expected));
      await expectLater(stream, emitsInOrder(expected));

      await pumpEventQueue();
      expect(stream, emitsDone);
    }

    {
      final source = Stream.fromIterable(elements).toStateStream(0);
      final stream = source.asBroadcastStateStream();
      await _test(stream, source);
    }

    {
      final source =
          Stream.fromIterable(elements).asBroadcastStream().toStateStream(0);
      final stream = source.asBroadcastStateStream();
      await _test(stream, source);
    }

    {
      final source = Stream.fromIterable(elements)
          .toStateStream(0)
          .asBroadcastStateStream();
      final stream = source.asBroadcastStateStream();
      await _test(stream, source);
    }

    {
      final source = Stream.fromIterable(elements).shareState(0);
      final stream = source.asBroadcastStateStream();
      await _test(stream, source);
    }
  });
}
