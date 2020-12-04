import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('mapNotNull', () {
    test('works', () {
      expect(
        Stream.fromIterable([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
            .mapNotNull((i) => i.isEven ? i + 1 : null),
        emitsInOrder(<dynamic>[
          3,
          5,
          7,
          9,
          11,
          emitsDone,
        ]),
      );
    });

    test('should forward error event', () {
      expect(
        Rx.concat<int>([
          Stream.fromIterable([1, 2]),
          Stream.error(Exception()),
          Stream.value(3),
        ]).mapNotNull((i) => i.isEven ? i + 1 : null),
        emitsInOrder(<dynamic>[
          3,
          emitsError(isException),
          emitsDone,
        ]),
      );
    });

    test('should catch error thrown from mapper function', () {
      expect(
        Stream.fromIterable([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).mapNotNull((i) {
          if (i == 4) throw Exception();
          return i.isEven ? i + 1 : null;
        }),
        emitsInOrder(<dynamic>[
          3,
          emitsError(isException),
          7,
          9,
          11,
          emitsDone,
        ]),
      );
    });
  });
}
