import 'dart:async';

import 'package:meta/meta.dart';

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
  @internal
  StateStream<T> asBroadcastStateStream({
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel,
  }) =>
      _AsBroadcastStateStream(this, onListen: onListen, onCancel: onCancel);
}

class _AsBroadcastStateStream<T> extends StreamView<T>
    with StateStreamMixin<T>
    implements StateStream<T> {
  final StateStream<T> source;

  _AsBroadcastStateStream(
    this.source, {
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel,
  }) : super(source.asBroadcastStream(onListen: onListen, onCancel: onCancel));

  @override
  bool Function(T p1, T p2) get equals => source.equals;

  @override
  T get value => source.value;
}
