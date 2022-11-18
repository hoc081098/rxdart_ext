import 'dart:async';

import 'package:meta/meta.dart';

/// A class that exposes only the [StreamSink] interface of an object.
@internal
class StreamSinkWrapper<T> implements StreamSink<T> {
  final StreamSink<T> _target;

  /// Creates a [StreamSinkWrapper] that wraps [target].
  StreamSinkWrapper(this._target);

  @override
  void add(T data) => _target.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _target.addError(error, stackTrace);

  @override
  Future<dynamic> close() => _target.close();

  @override
  Future<dynamic> addStream(Stream<T> source) => _target.addStream(source);

  @override
  Future<dynamic> get done => _target.done;
}
