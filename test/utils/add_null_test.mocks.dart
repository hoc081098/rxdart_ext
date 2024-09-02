// Mocks generated by Mockito 5.4.2 from annotations
// in rxdart_ext/test/utils/add_null_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i2;

import 'package:mockito/mockito.dart' as _i1;

import 'add_null_test.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeStreamSink_0<S> extends _i1.SmartFake implements _i2.StreamSink<S> {
  _FakeStreamSink_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [VoidController].
///
/// See the documentation for Mockito's code generation for more information.
class MockVoidController extends _i1.Mock implements _i3.VoidController {
  MockVoidController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set onListen(void Function()? _onListen) => super.noSuchMethod(
        Invocation.setter(
          #onListen,
          _onListen,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set onPause(void Function()? _onPause) => super.noSuchMethod(
        Invocation.setter(
          #onPause,
          _onPause,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set onResume(void Function()? _onResume) => super.noSuchMethod(
        Invocation.setter(
          #onResume,
          _onResume,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set onCancel(_i2.FutureOr<void> Function()? _onCancel) => super.noSuchMethod(
        Invocation.setter(
          #onCancel,
          _onCancel,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.Stream<void> get stream => (super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: _i2.Stream<void>.empty(),
      ) as _i2.Stream<void>);

  @override
  _i2.StreamSink<void> get sink => (super.noSuchMethod(
        Invocation.getter(#sink),
        returnValue: _FakeStreamSink_0<void>(
          this,
          Invocation.getter(#sink),
        ),
      ) as _i2.StreamSink<void>);

  @override
  bool get isClosed => (super.noSuchMethod(
        Invocation.getter(#isClosed),
        returnValue: false,
      ) as bool);

  @override
  bool get isPaused => (super.noSuchMethod(
        Invocation.getter(#isPaused),
        returnValue: false,
      ) as bool);

  @override
  bool get hasListener => (super.noSuchMethod(
        Invocation.getter(#hasListener),
        returnValue: false,
      ) as bool);

  @override
  _i2.Future<dynamic> get done => (super.noSuchMethod(
        Invocation.getter(#done),
        returnValue: _i2.Future<dynamic>.value(),
      ) as _i2.Future<dynamic>);

  @override
  void add(dynamic event) => super.noSuchMethod(
        Invocation.method(
          #add,
          [event],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addError(
    Object? error, [
    StackTrace? stackTrace,
  ]) =>
      super.noSuchMethod(
        Invocation.method(
          #addError,
          [
            error,
            stackTrace,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.Future<dynamic> close() => (super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValue: _i2.Future<dynamic>.value(),
      ) as _i2.Future<dynamic>);

  @override
  _i2.Future<dynamic> addStream(
    _i2.Stream<void>? source, {
    bool? cancelOnError,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #addStream,
          [source],
          {#cancelOnError: cancelOnError},
        ),
        returnValue: _i2.Future<dynamic>.value(),
      ) as _i2.Future<dynamic>);
}
