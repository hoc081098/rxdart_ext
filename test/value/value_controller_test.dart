import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'value_controller.mocks.dart';

// ignore_for_file: close_sinks

@GenerateMocks([StreamController])
void main() {
  group('ValueController', () {
    late MockStreamController<int> mockController;
    late ValueStreamController<int> valueController;

    setUp(() {
      mockController = MockStreamController<int>();
      valueController = ValueStreamController.mock(mockController, 0);
    });

    group('delegate to StreamController', () {
      test('get onListen', () {
        when(mockController.onListen).thenReturn(null);
        valueController.onListen;
        verify(mockController.onListen).called(1);
      });

      test('set onListen', () {
        final onListenHandler = () {};
        when(mockController.onListen = onListenHandler).thenReturn(() => null);
        valueController.onListen = onListenHandler;
        verify(mockController.onListen = onListenHandler);
      });

      test('get onCancel', () {
        when(mockController.onCancel).thenReturn(null);
        valueController.onCancel;
        verify(mockController.onCancel).called(1);
      });

      test('set onCancel', () {
        final onCancelHandler = () {};
        when(mockController.onCancel = onCancelHandler).thenReturn(() => null);
        valueController.onCancel = onCancelHandler;
        verify(mockController.onCancel = onCancelHandler);
      });

      test('get onPause', () {
        when(mockController.onPause).thenReturn(null);
        valueController.onPause;
        verify(mockController.onPause).called(1);
      });

      test('set onPause', () {
        final onPauseHandler = () {};
        when(mockController.onPause = onPauseHandler).thenReturn(() => null);
        valueController.onPause = onPauseHandler;
        verify(mockController.onPause = onPauseHandler);
      });

      test('get onResume', () {
        when(mockController.onResume).thenReturn(null);
        valueController.onResume;
        verify(mockController.onResume).called(1);
      });

      test('set onResume', () {
        final onResumeHandler = () {};
        when(mockController.onResume = onResumeHandler).thenReturn(() => null);
        valueController.onResume = onResumeHandler;
        verify(mockController.onResume = onResumeHandler);
      });
    });
  });
}
