import 'dart:async';

import 'package:rxdart_ext/utils.dart';
import 'package:test/test.dart';

class _MockClass with DisposableMixin {
  _MockClass(
    this.completer,
  ) {
    dispose$.listen((_) => completer.complete());
  }

  final Completer<void> completer;
}

void main() {
  test('DisposableMixin', () async {
    final completer = Completer<void>();
    final disposable = _MockClass(completer);

    disposable.dispose();
    disposable.dispose();
    await completer.future.timeout(Duration(milliseconds: 100));

    expect(completer.isCompleted, isTrue);
  });
}
