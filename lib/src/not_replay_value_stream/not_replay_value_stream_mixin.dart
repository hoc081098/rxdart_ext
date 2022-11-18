import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart' show ValueStreamError;

import 'not_replay_value_stream.dart';
import 'stream_event.dart';

/// This [NotReplayValueStream] mixin implements all [NotReplayValueStream] members via [event].
@internal
mixin NotReplayValueStreamMixin<T> implements NotReplayValueStream<T> {
  /// Keep latest state.
  /// **DO NOT USE THIS METHOD**
  @visibleForOverriding
  @internal
  StreamEvent<T> get event;

  @nonVirtual
  @override
  Object get error {
    final errorAndSt = event.errorAndStackTrace;
    if (errorAndSt != null) {
      return errorAndSt.error;
    }
    throw ValueStreamError.hasNoError();
  }

  @nonVirtual
  @override
  Object? get errorOrNull => event.errorAndStackTrace?.error;

  @nonVirtual
  @override
  bool get hasError => event.errorAndStackTrace != null;

  @nonVirtual
  @override
  StackTrace? get stackTrace => event.errorAndStackTrace?.stackTrace;

  @nonVirtual
  @override
  T get value => event.value;

  @nonVirtual
  @override
  T get valueOrNull => event.value;

  @nonVirtual
  @override
  bool get hasValue => true;
}
