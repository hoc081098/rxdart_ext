import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  test(
    'debug',
    () {
      Stream.value(1).debug().listen(null);
    },
  );
}
