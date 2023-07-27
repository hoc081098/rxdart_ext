// ignore_for_file: prefer_void_to_null

import 'dart:async';

import 'package:rxdart/streams.dart' show ValueStreamError;
import 'package:rxdart/utils.dart' show DataNotification;

import '../not_replay_value_stream/not_replay_value_stream.dart';
import '../utils/equality.dart';

export '../utils/equality.dart';

/// A [Stream] that provides synchronous access to the last emitted item,
/// and two consecutive values are not equal.
///
/// The equality between previous data event and current data event is determined by [equals].
///
/// This [Stream] do **not replay** the latest value, see [NotReplayValueStream].
/// This [Stream] always has **no error**.
abstract class StateStream<T> extends NotReplayValueStream<T> {
  /// Determined equality between previous data event and current data event.
  Equality<T> get equals;

  /// Default [equals] function.
  /// Use '==' operator on the last provided data element.
  static bool defaultEquality(Object? lhs, Object? rhs) => lhs == rhs;

  @override
  T get value;

  @override
  T get valueOrNull;

  /// Always returns **`true`**.
  @override
  bool get hasValue;

  /// Always throws [ValueStreamError].
  @override
  Never get error;

  /// Always returns **`null`**.
  @override
  Null get errorOrNull;

  /// Always returns **`false`**.
  @override
  bool get hasError;

  /// Always returns **`null`**.
  @override
  Null get stackTrace;

  @override
  DataNotification<T> get lastEventOrNull;
}

/// A mutable [StateStream] that provides a setter for [value].
abstract class MutableStateStream<T> implements StateStream<T> {
  /// Set the [value] of this [MutableStateStream].
  /// Also emits the [newValue] to all listeners
  /// if it is not equal to the current value.
  set value(T newValue);
}

/// Provides `update` extension methods on [MutableStateStream].
extension UpdateMutableStateStreamExtensions<T> on MutableStateStream<T> {
  /// Updates the [value] using the specified function of its value.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void update(T Function(T value) transform) => value = transform(value);

  /// Updates the [value] using the specified function of its value,
  /// and returns the new value.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T updateAndGet(T Function(T value) transform) => value = transform(value);

  /// Updates the [value] using the specified function of its value,
  /// and returns its prior value.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T getAndUpdate(T Function(T value) transform) {
    final prevValue = value;
    value = transform(value);
    return prevValue;
  }
}
