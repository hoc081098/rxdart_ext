import 'package:quiver/iterables.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('flatMapBatches', () {
    test('empty Stream emits done', () {
      expect(
        Stream<int>.empty().flatMapBatches((value) => Stream.value(value), 1),
        emitsInOrder(<Object>[emitsDone]),
      );
    });

    test('emits event batches', () {
      final size = 5;
      final elements = [1, 2, size, 4, 5, 6, 7, 8, 9, 10];

      expect(
        Stream.fromIterable(elements)
            .flatMapBatches((value) => Stream.value(value), size),
        emitsInOrder(<Object>[...partition(elements, size), emitsDone]),
      );
    });

    test('emits uneven batches', () {
      final size = 3;
      final elements = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

      expect(
        Stream.fromIterable(elements)
            .flatMapBatches((value) => Stream.value(value), size),
        emitsInOrder(<Object>[...partition(elements, size), emitsDone]),
      );
    });

    test('forward error', () {
      expect(
        Stream<int>.error(Exception())
            .flatMapBatches((value) => Stream.value(value), 2),
        emitsInOrder(<Object>[emitsError(isException), emitsDone]),
      );
    });

    test('hangs if earlier batch does not complete', () {
      Stream.fromIterable([
        Rx.never<int>().startWith(1),
        Rx.never<int>().startWith(2),
        Stream.value(3),
        Stream.value(4),
      ]).flatMapBatches(identity, 2).listen(
            expectAsync1(
              (v) {
                expect(v, [1, 2]);
              },
              count: 1,
            ),
            onDone: expectAsync0(
              () {},
              count: 0,
            ),
          );
    }, timeout: const Timeout(Duration(milliseconds: 500)));

    test('batch size larger than count', () {
      expect(
        Stream.value(Stream.value(1)).flatMapBatches(identity, 10),
        emitsInOrder(<Object>[
          [1],
          emitsDone,
        ]),
      );
    });

    test('every Stream emits multiple values', () {
      Stream<void> delay(int v) =>
          Rx.timer(null, Duration(milliseconds: v * 100));

      final stream = Stream.fromIterable([
        Stream.fromIterable([1, 2]).delayWhen(delay),
        Stream.fromIterable([3, 4]).delayWhen(delay),
        Stream.value(5),
        Stream.value(6),
      ]).flatMapBatches(identity, 2);

      expect(
        stream,
        emitsInOrder(<Object>[
          [1, 3],
          [2, 4],
          [5, 6],
          emitsDone,
        ]),
      );
    });
  });
}
