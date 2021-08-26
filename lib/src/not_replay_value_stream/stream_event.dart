import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart' show ErrorAndStackTrace;

/// Class that holds latest value and lasted error emitted from Stream.
@internal
class StreamEvent<T> {
  T _value;
  ErrorAndStackTrace? _errorAndStacktrace;

  /// Construct a [StreamEvent] with data event.
  StreamEvent.data(T seedValue) : _value = seedValue;

  /// Keep error state.
  void onError(ErrorAndStackTrace errorAndStacktrace) =>
      _errorAndStacktrace = errorAndStacktrace;

  /// Keep data state.
  void onData(T value) => _value = value;

  /// Last emitted value
  /// or null if no data added.
  T get value => _value;

  /// Last emitted error and the corresponding stack trace,
  /// or null if no error added.
  ErrorAndStackTrace? get errorAndStackTrace => _errorAndStacktrace;
}
