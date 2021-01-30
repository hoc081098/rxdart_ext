import 'package:rxdart/rxdart.dart' show ErrorAndStackTrace, ValueWrapper;

/// Class that holds latest value or lasted error emitted from Stream.
class StreamEvent<T> {
  ValueWrapper<T>? _valueWrapper;
  ErrorAndStackTrace? _errorAndStacktrace;

  /// Construct a [StreamEvent] with data event.
  StreamEvent.data(T seedValue) : _valueWrapper = ValueWrapper(seedValue);

  /// Set this event to error state.
  void onError(ErrorAndStackTrace errorAndStacktrace) {
    _errorAndStacktrace = errorAndStacktrace;
    _valueWrapper = null;
  }

  /// Set this event to data state.
  void onData(T value) {
    _valueWrapper = ValueWrapper(value);
    _errorAndStacktrace = null;
  }

  /// Last emitted value wrapped in [ValueWrapper],
  /// or null if there has been no emission yet or error exists.
  ValueWrapper<T>? get valueWrapper => _valueWrapper;

  /// Last emitted error and the corresponding stack trace,
  /// or null if no error added or value exists.
  ErrorAndStackTrace? get errorAndStackTrace => _errorAndStacktrace;
}
