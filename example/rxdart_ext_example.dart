import 'package:rxdart_ext/rxdart_ext.dart';

void main() {
  Stream.fromIterable([1, 2, 3, 4]).debug().collect();

  f();
}

f2() {
  f3() {
    Stream.fromIterable([1, 2, 3, 4])
        .concatWith([Stream.error(Exception('Hello Hello Hello HelloHelloHello Hello 2'))])
        .debug(trimOutput: true).collect();
  }

  f3();
}

f() {
  () {
    () {
      Future.sync(() {
        f2();
      });
    }();
  }();
}
