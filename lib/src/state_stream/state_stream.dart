// ignore_for_file: prefer_void_to_null

import 'dart:async';

import '../not_replay_value_stream/not_replay_value_stream.dart';
import '../utils/equality.dart';
export '../utils/equality.dart';
import 'package:rxdart/streams.dart' show ValueStreamError;

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
}
