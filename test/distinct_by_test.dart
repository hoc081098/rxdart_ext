import 'package:collection/collection.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('distinctBy', () {
    test('distinctBy', () {
      expect(
        Stream.fromIterable([
          'Alpha', // 5
          'Gamma', // 5
          'Beta', // 4
          'Omega', // 5
          'Gamma', // 5
          'Lambda' // 6
        ]).distinctBy((e) => e.length),
        emitsInOrder(<dynamic>[
          'Alpha',
          'Beta',
          'Omega',
          'Lambda',
          emitsDone,
        ]),
      );
    });

    test('custom equals', () {
      expect(
        Stream.fromIterable([
          'ABC',
          'ABC',
          '123',
          '123',
          'DEF',
          '456',
        ]).distinctBy(
          (e) => e.split(''),
          equals: const ListEquality<String>().equals,
        ),
        emitsInOrder(<dynamic>[
          'ABC',
          '123',
          'DEF',
          '456',
          emitsDone,
        ]),
      );
    });
  });
}
