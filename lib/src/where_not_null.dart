import 'dart:async';

import 'default_sink.dart';

class _WhereNotNullStreamSink<T extends Object>
    with ForwardingSinkMixin<T?, T>
    implements ForwardingSink<T?, T> {
  @override
  void add(EventSink<T> sink, T? data) {
    if (data != null) {
      sink.add(data);
    }
  }
}

/// Extends the Stream class with the ability to convert the source Stream
/// to a Stream which emits all the non-`null` elements
/// of this Stream, in their original emission order.
extension WhereNotNullStreamExtension<T extends Object> on Stream<T?> {
  /// Returns a Stream which emits all the non-`null` elements
  /// of this Stream, in their original emission order.
  ///
  /// For a `Stream<T?>`, this method is equivalent to `.whereType<T>()`.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable(<int?>[1, 2, 3, null, 4, null])
  ///       .whereNotNull()
  ///       .listen(print); // prints 1, 2, 3, 4
  ///
  ///     // equivalent to:
  ///
  ///     Stream.fromIterable(<int?>[1, 2, 3, null, 4, null])
  ///       .whereType<int>()
  ///       .listen(print); // prints 1, 2, 3, 4
  Stream<T> whereNotNull() =>
      forwardStreamWithSink(_WhereNotNullStreamSink<T>());
}
