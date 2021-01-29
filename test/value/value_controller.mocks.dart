import 'dart:async' as _i2;

import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: comment_references

// ignore_for_file: unnecessary_parenthesis

class _FakeStreamSink<S> extends _i1.Fake implements _i2.StreamSink<S> {}

/// A class which mocks [StreamController].
///
/// See the documentation for Mockito's code generation for more information.
class MockStreamController<T> extends _i1.Mock
    implements _i2.StreamController<T> {
  MockStreamController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Stream<T> get stream =>
      (super.noSuchMethod(Invocation.getter(#stream), Stream<T>.empty())
          as _i2.Stream<T>);
  @override
  _i2.StreamSink<T> get sink =>
      (super.noSuchMethod(Invocation.getter(#sink), _FakeStreamSink<T>())
          as _i2.StreamSink<T>);
  @override
  bool get isClosed =>
      (super.noSuchMethod(Invocation.getter(#isClosed), false) as bool);
  @override
  bool get isPaused =>
      (super.noSuchMethod(Invocation.getter(#isPaused), false) as bool);
  @override
  bool get hasListener =>
      (super.noSuchMethod(Invocation.getter(#hasListener), false) as bool);
  @override
  _i2.Future<dynamic> get done =>
      (super.noSuchMethod(Invocation.getter(#done), Future.value(null))
          as _i2.Future<dynamic>);
  @override
  void add(T? event) => super.noSuchMethod(Invocation.method(#add, [event]));
  @override
  void addError(Object? error, [StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#addError, [error, stackTrace]));
  @override
  _i2.Future<dynamic> close() =>
      (super.noSuchMethod(Invocation.method(#close, []), Future.value(null))
          as _i2.Future<dynamic>);
  @override
  _i2.Future<dynamic> addStream(_i2.Stream<T>? source, {bool? cancelOnError}) =>
      (super.noSuchMethod(
          Invocation.method(
              #addStream, [source], {#cancelOnError: cancelOnError}),
          Future.value(null)) as _i2.Future<dynamic>);
}
