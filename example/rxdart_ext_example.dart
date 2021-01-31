import 'package:rxdart_ext/rxdart_ext.dart';

void main() {
  Stream.fromIterable([1, 2, 3, 4]).debug().collect();
}
