import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'not_replay_value_stream.dart';

enum _Event { data, error }

class _DataOrError<T> {
  _Event event;
  T value;
  ErrorAndStackTrace? errorAndStacktrace;

  _DataOrError.data(this.value)
      : event = _Event.data,
        errorAndStacktrace = null;

  void onError(ErrorAndStackTrace errorAndStacktrace) {
    this.errorAndStacktrace = errorAndStacktrace;
    event = _Event.error;
  }

  void onData(T value) {
    this.value = value;
    event = _Event.data;
  }

  bool get hasValue => event == _Event.data;

  bool get hasError => event == _Event.error;
}

/// A special [StreamController] that captures the latest item that has been
/// added to the controller.
///
/// [ValueSubject] is the same as [PublishSubject], with the ability to capture
/// the latest item has been added to the controller.
///
/// [ValueSubject] is, by default, a broadcast (aka hot) controller, in order
/// to fulfill the Rx Subject contract. This means the Subject's `stream` can
/// be listened to multiple times.
///
/// ### Example
///
///     final subject = ValueSubject<int>(1);
///
///     print(subject.value);          // prints 1
///
///     // observers will receive 3 and done events.
///     subject.stream.listen(print); // prints 2
///     subject.stream.listen(print); // prints 2
///     subject.stream.listen(print); // prints 2
///
///     subject.add(2);
///     subject.close();
class ValueSubject<T> extends Subject<T> implements NotReplayValueStream<T> {
  final _DataOrError<T> _dataOrError;

  ValueSubject._(
    StreamController<T> controller,
    this._dataOrError,
  ) : super(controller, controller.stream);

  /// Constructs a [ValueSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// [seedValue] becomes the current [value] of Subject.
  ///
  /// See also [StreamController.broadcast].
  factory ValueSubject(
    T seedValue, {
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    return ValueSubject._(
      controller,
      _DataOrError.data(seedValue),
    );
  }

  @override
  void onAdd(T event) => _dataOrError.onData(event);

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) =>
      _dataOrError.onError(ErrorAndStackTrace(error, stackTrace));

  @override
  bool get hasValue => _dataOrError.hasValue;

  @override
  T get value => _dataOrError.value;

  @override
  ErrorAndStackTrace? get errorAndStackTrace => _dataOrError.errorAndStacktrace;

  @override
  bool get hasError => _dataOrError.hasError;

  @override
  Subject<R> createForwardingSubject<R>({
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) =>
      PublishSubject(
        onListen: onListen,
        onCancel: onCancel,
        sync: sync,
      );
}
