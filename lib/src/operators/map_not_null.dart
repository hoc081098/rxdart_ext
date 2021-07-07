import 'dart:async';

import '../default_sink.dart';

class _MapNotNullSink<T, R extends Object> extends BaseEventSink<T, R> {
  final R? Function(T) transform;

  _MapNotNullSink(EventSink<R> sink, this.transform) : super(sink);

  @override
  void add(T data) {
    final R? value;
    try {
      value = transform(data);
    } catch (e, s) {
      sink.addError(e, s);
      return;
    }
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
      Stream<R>.eventTransformed(
          this, (sink) => _MapNotNullSink<T, R>(sink, transform));
}
