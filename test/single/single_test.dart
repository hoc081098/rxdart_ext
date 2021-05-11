import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

Future<void> singleRule<T>(Stream<T> single, Either<Object, T> e) {
  return expectLater(
    single,
    emitsInOrder(<dynamic>[
      e.fold((e) => emitsError(e), (v) => emits(v)),
      emitsDone,
    ]),
  );
}

final _left = Either<Object, Never>.left(isA<Exception>());

void main() {
  group('Single', () {
    test('singleRule', () async {
      // Single.value
      await singleRule(
        Single.value(1),
        Either.right(1),
      );

      // Single.error
      await singleRule(
        Single<int>.error(Exception()),
        _left,
      );

      // Single.map.success
      await singleRule(
        Single.value(1).map((event) => event.toString()),
        Either.right('1'),
      );
      // Single.map.failure
      await singleRule(
        Single.value(1).map((event) => throw Exception()),
        _left,
      );

      // Single.asyncMap.sync.success
      await singleRule(
        Single.value(1).asyncMap((event) => event.toString()),
        Either.right('1'),
      );
      // Single.asyncMap.sync.failure
      await singleRule(
        Single.value(1).asyncMap((event) => throw Exception()),
        _left,
      );

      // Single.asyncMap.async.success
      await singleRule(
        Single.value(1).asyncMap((event) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return event.toString();
        }),
        Either.right('1'),
      );
      // Single.asyncMap.async.failure
      await singleRule(
        Single.value(1).asyncMap((event) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          throw Exception();
        }),
        _left,
      );
    });
  });
}
