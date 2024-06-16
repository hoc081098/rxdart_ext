import 'package:rxdart_ext/rxdart_ext.dart';

class MyResource {
  var _disposed = false;

  MyResource() {
    print('[using] MyResource()');
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    print('[using] MyResource.dispose()');
  }

  Future<int> work() async {
    _checkDisposed('~1');
    await delay(200);
    _checkDisposed('~2');
    return 42;
  }

  void _checkDisposed([Object? tag]) {
    if (_disposed) {
      print('[using] MyResource#$tag was already disposed');
      throw Exception('MyResource is disposed');
    }
  }
}

Future<void> runRxSinglesUsingExample() async {
  final subscription = RxSingles.using<int, MyResource>(
    resourceFactory: () => MyResource(),
    singleFactory: (r) => r.work().asSingle(),
    disposer: (r) => r.dispose(),
  ).debug(identifier: '[using]').collect();

  await delay(100);
  await subscription.cancel();
  await delay(200);
}
