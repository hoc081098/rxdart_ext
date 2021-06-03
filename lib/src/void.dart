import 'dart:async';

import 'default_sink.dart';

class _AsVoidStreamSink<T>
    with ForwardingSinkMixin<T, void>
    implements ForwardingSink<T, void> {
  @override
  void add(EventSink<void> sink, T data) => sink.add(null);
}

/// Extends the Stream class with the ability to convert the source Stream to a `Stream<void>`.
extension AsVoidStreamExtension<T> on Stream<T> {
  /// Returns a `Stream<void>`.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable(['1', 'two', '3', 'four'])
  ///       .asVoid()
  ///       .listen(print); // prints null, null, null, null
  ///
  ///     // equivalent to:
  ///
  ///     Stream.fromIterable(['1', 'two', '3', 'four'])
  ///       .mapTo<void>(null)
  ///       .listen(print); // prints null, null, null, null
  Stream<void> asVoid() => forwardStreamWithSink<void>(_AsVoidStreamSink());
}
