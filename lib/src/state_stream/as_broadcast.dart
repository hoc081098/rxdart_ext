import 'dart:async';

import 'state_stream.dart';
import 'state_stream_mixin.dart';

/// Convert a [StateStream] to a broadcast [StateStream].
extension BroadcastStateStreamExtensions<T> on StateStream<T> {
  /// Convert the this [StateStream] into a new [StateStream] that can
  /// be listened to multiple times, providing an initial value.
  /// It will automatically begin emitting items when first listened to,
  /// and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  StateStream<T> asBroadcastStateStream() => _AsBroadcastStateStream(this);
}

class _AsBroadcastStateStream<T> extends StreamView<T>
    with StateStreamMixin<T>
    implements StateStream<T> {
  final StateStream<T> source;

  _AsBroadcastStateStream(this.source)
      : super(source.asBroadcastStream(onCancel: (s) => s.cancel()));

  @override
  Equality<T> get equals => source.equals;

  @override
  T get value => source.value;
}
