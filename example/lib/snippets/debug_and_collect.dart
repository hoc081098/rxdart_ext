import 'package:rxdart_ext/rxdart_ext.dart';

Future<void> runDebugAndCollectOperatorExample() async {
  Stream.fromIterable([1, 2, 3, 4]).debug(identifier: '[DEBUG]').collect();
  await delay(0);
}
