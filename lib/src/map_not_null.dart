import 'dart:async';

import 'default_sink.dart';

class _MapNotNullSink<T, R extends Object>
    with ForwardingSinkMixin<T, R>
    implements ForwardingSink<T, R> {
  final R? Function(T) transform;

  _MapNotNullSink(this.transform);

  @override
  void add(EventSink<R> sink, T data) {
    final value = transform(data);
    if (value != null) {
      sink.add(value);
    }
  }
}

/// Extends the Stream class with the ability to convert the source Stream
/// to a Stream containing only the non-`null` results
/// of applying the given [transform] function to each element of this Stream.
extension MapNotNullStreamExtension<T> on Stream<T> {
  /// Returns a Stream containing only the non-`null` results
  /// of applying the given [transform] function to each element of this Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable(['1', 'two', '3', 'four'])
  ///       .mapNotNull(int.tryParse)
  ///       .listen(print); // prints 1, 3
  ///
  ///     // equivalent to:
  ///
  ///     Stream.fromIterable(['1', 'two', '3', 'four'])
  ///       .map(int.tryParse)
  ///       .whereType<int>()
  ///       .listen(print); // prints 1, 3
  Stream<R> mapNotNull<R extends Object>(R? Function(T) transform) =>
      forwardStream(this, _MapNotNullSink(transform));
}
