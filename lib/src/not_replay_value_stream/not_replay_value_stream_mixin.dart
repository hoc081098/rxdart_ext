import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart' show ValueStreamError;

import 'not_replay_value_stream.dart';
import 'stream_event.dart';

/// This [NotReplayValueStream] mixin implements all [NotReplayValueStream] members via [event].
@internal
mixin NotReplayValueStreamMixin<T> implements NotReplayValueStream<T> {
  /// Keep latest state.
  @visibleForOverriding
  @internal
  StreamEvent<T> get event;

  @override
  Object get error {
    final errorAndSt = event.errorAndStackTrace;
    if (errorAndSt != null) {
      return errorAndSt.error;
    }
    throw ValueStreamError.hasNoError();
  }

  @override
  Object? get errorOrNull => event.errorAndStackTrace?.error;

  @override
  bool get hasError => event.errorAndStackTrace != null;

  @override
  StackTrace? get stackTrace => event.errorAndStackTrace?.stackTrace;

  @override
  T get value => event.value;

  @override
  T get valueOrNull => event.value;

  @override
  bool get hasValue => true;
}
