import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Map not null',
    () {
      Stream.fromIterable([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
          .mapNotNull((i) => i.isEven ? i + 1 : null)
          .debug()
          .listen(null);
    },
  );
}
