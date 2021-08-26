import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'add_null_test.mocks.dart';

abstract class VoidController implements StreamController<void> {}

@GenerateMocks([VoidController])
void main() {
  test('Sink<void>.addNull', () {
    final c = MockVoidController();
    when(c.add(null)).thenReturn(null);

    c.addNull();

    verify(c.add(null)).called(1);
  });
}
