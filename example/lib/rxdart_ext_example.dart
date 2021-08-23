import 'package:rxdart_ext/operators.dart';

void main() {
  Stream.fromIterable([1, 2, 3, 4]).debug().collect();
}
