import 'package:rxdart/rxdart.dart' show ErrorAndStackTrace, ValueWrapper;

/// Class that holds latest value and lasted error emitted from Stream.
class StreamEvent<T> {
  ValueWrapper<T> _valueWrapper;
  ErrorAndStackTrace? _errorAndStacktrace;

  /// Construct a [StreamEvent] with data event.
  StreamEvent.data(T seedValue) : _valueWrapper = ValueWrapper(seedValue);

  /// Keep error state.
  void onError(ErrorAndStackTrace errorAndStacktrace) =>
      _errorAndStacktrace = errorAndStacktrace;

  /// Keep data state.
  void onData(T value) => _valueWrapper = ValueWrapper(value);

  /// Last emitted value wrapped in [ValueWrapper].
  ValueWrapper<T> get valueWrapper => _valueWrapper;

  /// Last emitted error and the corresponding stack trace,
  /// or null if no error added.
  ErrorAndStackTrace? get errorAndStackTrace => _errorAndStacktrace;
}
