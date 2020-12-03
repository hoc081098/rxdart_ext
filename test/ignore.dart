import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  test('ignoreElements', () {
    expect(
      Stream.fromIterable([1, 2, 3]).ignoreElements<void>(),
      emitsDone,
    );

    expect(
      Rx.concat([
        Stream.fromIterable([1, 2, 3]),
        Stream<int>.error(Exception()),
      ]).ignoreElements<void>(),
      emitsInOrder(<dynamic>[
        emitsError(isException),
        emitsDone,
      ]),
    );
  });

  test('ignoreErrors', () {
    expect(
      Stream.fromIterable([1, 2, 3]).ignoreErrors(),
      emitsInOrder(<dynamic>[
        1,
        2,
        3,
        emitsDone,
      ]),
    );

    expect(
      Rx.concat([
        Stream.fromIterable([1, 2, 3]),
        Stream<int>.error(Exception()),
        Stream.fromIterable([4, 5, 6]),
      ]).ignoreErrors(),
      emitsInOrder(<dynamic>[
        1,
        2,
        3,
        4,
        5,
        6,
        emitsDone,
      ]),
    );
  });
}
