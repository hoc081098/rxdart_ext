import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

class Repo {
  Single<String> getSomething() => Single.fromCallable(
        () => Future.delayed(
          const Duration(seconds: 2),
          () => 'something',
        ),
      );
}

Future<void> singleRule<T>(Single<T> single, Either<Object, T> e) {
  return expectLater(
    single,
    emitsInOrder(<dynamic>[
      e.fold((e) => emitsError(e), (v) => emits(v)),
      emitsDone,
    ]),
  );
}

void main() {
  test('singleOrError', () async {
    await singleRule(Single.value(1), Either.right(1));
    await singleRule(
      Single<int>.error(Exception()),
      Either<Object, int>.left(isA<Exception>()),
    );

    return;

    Single.value(1).debug().listen((event) {});
    Single<int>.error(1).debug().listen((event) {});

    Stream<int>.error(1)
        .concatWith([Stream.value(1)])
        .singleOrError()
        .listen((value) {});
    //
    // final s = PublishSubject<int>();
    //
    // s.singleOrError().debug(identifier: '1 >>>>').collect();
    // s.add(1);
    // s.singleOrError().debug(identifier: '2 >>>>').collect();
    // s.add(2);
    // s.close();
    //
    // Stream<void>.fromIterable([1, 2, 3])
    //     .singleOrError()
    //     .onErrorResumeNext(Stream.empty())
    //     .listen(print);
    //
    // Repo().getSomething().listen(print);
    // Stream.value(1)
    //     .exhaustMap(
    //         (value) => Repo().getSomething().map((event) => '$event $value'))
    //     .listen(print);

    await Future<void>.delayed(const Duration(seconds: 5));
  });
}
