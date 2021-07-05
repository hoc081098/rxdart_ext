import 'dart:async';

import 'default_sink.dart';

class _AsVoidStreamSink<T> extends BaseEventSink<T, void> {
  _AsVoidStreamSink(EventSink<void> outputSink) : super(outputSink);

  @override
  void add(T data) => outputSink.add(null);
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
  Stream<void> asVoid() =>
      Stream<void>.eventTransformed(this, (sink) => _AsVoidStreamSink<T>(sink));
}
