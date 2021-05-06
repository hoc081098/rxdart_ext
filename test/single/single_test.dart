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

void main() {
  test('singleOrError', () {
    Stream<void>.fromIterable([1, 2, 3]).singleOrError().listen(print);

    // Repo().getSomething().listen(print);
    // Stream.value(1)
    //     .exhaustMap(
    //         (value) => Repo().getSomething().map((event) => '$event $value'))
    //     .listen(print);
  });
}
