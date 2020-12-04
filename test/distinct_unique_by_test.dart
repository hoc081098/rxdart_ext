import 'package:collection/collection.dart' show ListEquality;
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('distinctUniqueBy', () {
    test('distinctUniqueBy', () {
      expect(
        Stream.fromIterable(['Alpha', 'Beta', 'Gamma'])
            .distinctUniqueBy((e) => e.length),
        emitsInOrder(<dynamic>[
          'Alpha',
          'Beta',
          emitsDone,
        ]),
      );
    });

    test('custom equals and hashCode', () {
      expect(
        Stream.fromIterable([
          'ABC',
          '123',
          'ABC',
          '123',
          'DEF',
          '456',
        ]).distinctUniqueBy(
          (e) => e.split(''),
          equals: const ListEquality<String>().equals,
          hashCode: const ListEquality<String>().hash,
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
