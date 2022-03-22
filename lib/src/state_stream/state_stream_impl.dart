import 'dart:async';

import '../not_replay_value_stream/value_stream_controller.dart';
import 'state_stream.dart';
import 'state_stream_mixin.dart';

/// Convert this [Stream] to a [StateStream].
extension ToStateStreamExtension<T> on Stream<T> {
  /// Convert this [Stream] to a [StateStream].
  ///
  /// Returned stream acts like [Stream.distinct] except it provides seed value
  /// used to check for equality, and synchronous access to the last emitted item.
  ///
  /// Data events are skipped if they are equal to the previous data event.
  /// Equality is determined by the provided [equals] method. If that is omitted,
  /// the '==' operator on the last provided data element is used.
  ///
  /// This stream is a single-subscription stream.
  StateStream<T> toStateStream(
    T value, {
    Equality<T>? equals,
  }) =>
      _StateStream(this, value, equals ?? StateStream.defaultEquality);
}

/// Default implementation of [StateStream].
/// This stream acts like [Stream.distinct] except it provides seed value
/// used to check for equality, and synchronous access to the last emitted item.
///
/// Data events are skipped if they are equal to the previous data event.
/// Equality is determined by the provided [equals] method. If that is omitted,
/// the '==' operator on the last provided data element is used.
///
/// This stream is a single-subscription stream.
class _StateStream<T> extends Stream<T>
    with StateStreamMixin<T>
    implements StateStream<T> {
  @override
  final Equality<T> equals;

  final ValueStreamController<T> controller;

  @override
  bool get isBroadcast => false;

  /// Construct a [_StateStream] with source stream, seed value.
  _StateStream(
    Stream<T> source,
    T seedValue,
    this.equals,
  ) : controller = ValueStreamController<T>(seedValue, sync: true) {
    StreamSubscription<T>? subscription;

    controller.onListen = () {
      subscription = source.listen(
        (data) {
          if (!equals(value, data)) {
            controller.add(data);
          }
        },
        onError: null,
        onDone: controller.close,
      );

      if (!source.isBroadcast) {
        controller.onPause = subscription!.pause;
        controller.onResume = subscription!.resume;
      }
    };
    controller.onCancel = () {
      final future = subscription?.cancel();
      subscription = null;
      return future;
    };
  }

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      controller.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  T get value => controller.stream.value;
}
