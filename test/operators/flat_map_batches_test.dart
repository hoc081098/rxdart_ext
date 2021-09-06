import 'package:quiver/iterables.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('flatMapBatches', () {
    test('empty emits done', () {
      expect(
        Stream<int>.empty().flatMapBatches((value) => Stream.value(value), 1),
        emitsInOrder(<Object>[emitsDone]),
      );
    });

    test('emits items', () {
      final size = 3;
      final elements = [1, 2, size, 4, 5, 6, 7, 8, 9, 10];

      expect(
        Stream.fromIterable(elements)
            .flatMapBatches((value) => Stream.value(value), size),
        emitsInOrder(<Object>[...partition(elements, size), emitsDone]),
      );
    });
  });
}
