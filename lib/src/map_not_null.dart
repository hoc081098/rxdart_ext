import 'dart:async';

import 'default_sink.dart';

class _MapNotNullSink<T, R extends Object> extends ForwardingSink<T, R>
    with ForwardingSinkMixin<T, R> {
  final R? Function(T) _mapper;

  _MapNotNullSink(this._mapper);

  @override
  void add(EventSink<R> sink, T data) {
    final mapped = _mapper(data);
    if (mapped != null) {
      sink.add(mapped);
    }
  }
}

/// Transforms each element of this stream into a new stream event and reject `null` elements.
/// ### Example
///
///     Stream.fromIterable([1, 'two', 3, 'four'])
///       .mapNotNull((i) => i is int ? i + 1 : null)
///       .listen(print); // prints 2, 4
///
/// #### as opposed to:
///
///     Stream.fromIterable([1, 'two', 3, 'four'])
///       .map((i) => i is int ? i + 1 : null)
///       .where((i) => i != null)
///       .listen(print); // prints 2, 4
extension MapNotNullStreamExtension<T> on Stream<T> {
  /// Transforms each element of this stream into a new stream event and reject `null` elements.
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 'two', 3, 'four'])
  ///       .mapNotNull((i) => i is int ? i + 1 : null)
  ///       .listen(print); // prints 2, 4
  ///
  /// #### as opposed to:
  ///
  ///     Stream.fromIterable([1, 'two', 3, 'four'])
  ///       .map((i) => i is int ? i + 1 : null)
  ///       .where((i) => i != null)
  ///       .listen(print); // prints 2, 4
  Stream<R> mapNotNull<R extends Object>(R? Function(T) mapper) =>
      forwardStream(this, _MapNotNullSink(mapper));
}
