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

      test('add', () {
        when(mockController.add(1)).thenReturn(null);
        valueController.add(1);
        verify(mockController.add(1)).called(1);
      });

      test('addError', () {
        final st = StackTrace.current;
        when(mockController.addError(1, st)).thenReturn(null);
        valueController.addError(1, st);
        verify(mockController.addError(1, st)).called(1);
      });

      test('close', () {
        when(mockController.close())
            .thenAnswer((_) => Future<void>.value(null));
        expect(valueController.close(), completes);
        verify(mockController.close()).called(1);
      });

      test('addStream', () {
        final stream = Stream.value(1);
        when(mockController.addStream(stream,
                cancelOnError: anyNamed('cancelOnError')))
            .thenAnswer((_) => Future<void>.value(null));

        expect(
            valueController.addStream(stream, cancelOnError: true), completes);

        verify(mockController.addStream(stream,
                cancelOnError: anyNamed('cancelOnError')))
            .called(1);
      });

      test('done', () {
        when(mockController.done).thenAnswer((_) => Future<void>.value(null));
        expect(valueController.done, completes);
        verify(mockController.done).called(1);
      });

      test('hasListener', () {
        when(mockController.hasListener).thenReturn(true);
        expect(valueController.hasListener, true);
        verify(mockController.hasListener).called(1);
      });

      test('isClose', () {
        when(mockController.isClosed).thenReturn(false);
        expect(valueController.isClosed, false);
        verify(mockController.isClosed).called(1);
      });

      test('isPaused', () {
        when(mockController.isPaused).thenReturn(false);
        expect(valueController.isPaused, false);
        verify(mockController.isPaused).called(1);
      });

      test('sink', () {
        final sink = StreamController<int>().sink;
        when(mockController.sink).thenReturn(sink);
        expect(valueController.sink, sink);
        verify(mockController.sink).called(1);
      });
    });
  });

  group('toNotReplayValueStream', () {});
}
