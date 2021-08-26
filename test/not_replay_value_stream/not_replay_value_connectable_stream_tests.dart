import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

class MockStream<T> extends Stream<T> {
  final Stream<T> stream;
  var listenCount = 0;

  MockStream(this.stream);

  @override
  StreamSubscription<T> listen(void Function(T event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    ++listenCount;
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  group('NotReplayValueConnectableStream', () {
    test('should not emit before connecting', () {
      final stream = MockStream(Stream.fromIterable(const [1, 2, 3]));
      final connectableStream = NotReplayValueConnectableStream(stream, 0);

      expect(connectableStream.value, 0);

      expect(stream.listenCount, 0);
      connectableStream.connect();
      expect(stream.listenCount, 1);
    });

    test('should begin emitting items after connection', () async {
      final stream = NotReplayValueConnectableStream<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
        0,
      );

      expect(stream.value, 0);
      stream.connect();

      await expectLater(stream, emitsInOrder(<int>[1, 2, 3]));
      expect(stream.value, 3);
    });

    test('stops emitting after the connection is cancelled', () async {
      final stream =
          Stream<int>.fromIterable(<int>[1, 2, 3]).publishValueNotReplay(0);

      expect(stream.value, 0);
      stream.connect().cancel(); // ignore: unawaited_futures

      expect(stream, neverEmits(anything));
      expect(stream.value, 0);
    });

    test('multicasts a single-subscription stream', () async {
      final stream = NotReplayValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
        0,
      ).autoConnect();

      expect(stream.value, 0);

      expect(stream, emitsInOrder(<int>[1, 2, 3]));
      expect(stream, emitsInOrder(<int>[1, 2, 3]));
      expect(stream, emitsInOrder(<int>[1, 2, 3]));

      await pumpEventQueue();
      expect(stream.value, 3);
    });

    test('can multicast streams', () async {
      final stream =
          Stream.fromIterable(const [1, 2, 3]).publishValueNotReplay(0);

      expect(stream.value, 0);
      stream.connect();

      expect(stream, emitsInOrder(<int>[1, 2, 3]));
      expect(stream, emitsInOrder(<int>[1, 2, 3]));
      expect(stream, emitsInOrder(<int>[1, 2, 3]));

      await pumpEventQueue();
      expect(stream.value, 3);
    });

    test('refcount automatically connects', () async {
      final stream =
          Stream.fromIterable(const [1, 2, 3]).shareValueNotReplay(0);
      expect(stream.value, 0);

      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));

      await pumpEventQueue();
      expect(stream.value, 3);
    });

    test('provide a function to autoConnect that stops listening', () async {
      final stream = Stream.fromIterable(const [1, 2, 3])
          .publishValueNotReplay(0)
          .autoConnect(connection: (subscription) => subscription.cancel());

      expect(stream.value, 0);
      expect(await stream.isEmpty, true);
      expect(stream.value, 0);
    });

    test('refCount cancels source subscription when no listeners remain',
        () async {
      var isCanceled = false;

      final controller =
          StreamController<int>(onCancel: () => isCanceled = true);
      final stream = controller.stream.shareValueNotReplay(0);
      expect(stream.value, 0);

      final subscription = stream.listen(null);
      await subscription.cancel();

      expect(isCanceled, true);
    });

    test('can close shareValueNotReplay() stream', () async {
      final isCanceled = Completer<void>();

      final controller = StreamController<bool>();
      controller.stream
          .shareValueNotReplay(true)
          .doOnCancel(() => isCanceled.complete())
          .listen(null);

      controller.add(true);
      await Future<void>.delayed(Duration.zero);
      await controller.close();

      expect(isCanceled.future, completes);
    });
  });
}
