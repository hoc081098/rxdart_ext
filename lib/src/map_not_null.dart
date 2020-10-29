import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _MapNotNullSink<T, R> implements ForwardingSink<T, R> {
  final R? Function(T) _mapper;

  _MapNotNullSink(this._mapper);

  @override
  void add(EventSink<R> sink, T data) {
    final mapped = _mapper(data);
    if (mapped != null) {
      sink.add(mapped);
    }
  }

  @override
  void addError(EventSink<R> sink, dynamic error, [StackTrace? st]) =>
      sink.addError(error as Object, st);

  @override
  void close(EventSink<R> sink) => sink.close();

  @override
  FutureOr onCancel(EventSink<R> sink) {}

  @override
  void onListen(EventSink<R> sink) {}

  @override
  void onPause(EventSink<R> sink) {}

  @override
  void onResume(EventSink<R> sink) {}
}

/// Map stream and reject null extension
/// ### Example
///
///     Stream.fromIterable([1, 'two', 3, 'four'])
///       .mapNotNull((i) => i is int ? i : null)
///       .listen(print); // prints 1, 3
///
/// #### as opposed to:
///
///     Stream.fromIterable([1, 'two', 3, 'four'])
///       .map((i) => i is int ? i : null)
///       .where((i) => i != null)
///       .listen(print); // prints 1, 3
extension MapNotNullStreamExtension<T> on Stream<T> {
  /// Map stream and reject null
  Stream<R> mapNotNull<R>(R? Function(T) mapper) =>
      forwardStream(this, _MapNotNullSink<T, R>(mapper));
}
