import 'package:rxdart/rxdart.dart' show ErrorAndStackTrace, ValueWrapper;

/// Class that holds latest value or lasted error emitted from Stream.
class StreamEvent<T> {
  ValueWrapper<T>? value;
  ErrorAndStackTrace? errorAndStacktrace;

  StreamEvent.data(T seedValue) : value = ValueWrapper(seedValue);

  void onError(ErrorAndStackTrace errorAndStacktrace) {
    this.errorAndStacktrace = errorAndStacktrace;
    value = null;
  }

  void onData(T value) {
    this.value = ValueWrapper(value);
    errorAndStacktrace = null;
  }
}
