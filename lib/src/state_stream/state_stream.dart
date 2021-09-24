// ignore_for_file: prefer_void_to_null

import 'dart:async';

import '../not_replay_value_stream/not_replay_value_stream.dart';

/// A [Stream] that provides synchronous access to the last emitted item,
/// and two consecutive values are not equal.
/// The equality between previous data event and current data event is determined by [equals].
/// This [Stream] always has no error.
abstract class StateStream<T> extends NotReplayValueStream<T> {
  /// Determined equality between previous data event and current data event.
  bool Function(T, T) get equals;

  /// Default [equals] function.
  /// Use '==' operator on the last provided data element.
  static bool defaultEquals(Object? lhs, Object? rhs) => lhs == rhs;

  @override
  T get value;

  @override
  T get valueOrNull;

  @override
  bool get hasValue;

  @override
  Never get error;

  @override
  Null get errorOrNull;

  @override
  bool get hasError;

  @override
  Null get stackTrace;

  @override
  StateStream<T> asBroadcastStream({
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel,
  });
}
