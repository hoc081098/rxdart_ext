import 'dart:async';

import 'package:rxdart/rxdart.dart'
    show ErrorAndStackTrace, PublishSubject, Subject, ValueWrapper;

import 'not_replay_value_stream.dart';

class _DataOrError<T> {
  ValueWrapper<T>? value;
  ErrorAndStackTrace? errorAndStacktrace;

  _DataOrError.data(T seedValue) : value = ValueWrapper(seedValue);

  void onError(ErrorAndStackTrace errorAndStacktrace) {
    this.errorAndStacktrace = errorAndStacktrace;
    value = null;
  }

  void onData(T value) {
    this.value = ValueWrapper(value);
    errorAndStacktrace = null;
  }
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
  ValueWrapper<T>? get valueWrapper => _dataOrError.value;

  @override
  ErrorAndStackTrace? get errorAndStackTrace => _dataOrError.errorAndStacktrace;

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

  @override
  NotReplayValueStream<T> get stream => this;
}

/// TODO
class ValueStreamController<T> implements StreamController<T> {
  final StreamController<T> _controller;
  final _DataOrError<T> _dataOrError;

  ValueStreamController._(this._controller, this._dataOrError);

  /// TODO
  factory ValueStreamController(
    T seedValue, {
    void Function()? onListen,
    void Function()? onPause,
    void Function()? onResume,
    FutureOr<void> Function()? onCancel,
    bool sync = false,
  }) {
    final controller = StreamController<T>(
      onListen: onListen,
      onPause: onPause,
      onResume: onResume,
      onCancel: onCancel,
      sync: sync,
    );
    return ValueStreamController._(
      controller,
      _DataOrError.data(seedValue),
    );
  }

  @override
  FutureOr<void> Function()? get onCancel => _controller.onCancel;

  @override
  set onCancel(FutureOr<void> Function()? onCancelHandler) =>
      _controller.onCancel = onCancelHandler;

  @override
  void Function()? get onListen => _controller.onListen;

  @override
  set onListen(void Function()? onListenHandler) =>
      _controller.onListen = onListenHandler;

  @override
  void Function()? get onPause => _controller.onPause;

  @override
  set onPause(void Function()? onPauseHandler) =>
      _controller.onPause = onPauseHandler;

  @override
  void Function()? get onResume => _controller.onResume;

  @override
  set onResume(void Function()? onResumeHandler) =>
      _controller.onResume = onResumeHandler;

  @override
  void add(T event) {
    _dataOrError.onData(event);
    _controller.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _dataOrError.onError(ErrorAndStackTrace(error, stackTrace));
    _controller.addError(error, stackTrace);
  }

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) =>
      _controller.addStream(source, cancelOnError: cancelOnError);

  @override
  Future<void> close() => _controller.close();

  @override
  Future<void> get done => _controller.done;

  @override
  bool get hasListener => _controller.hasListener;

  @override
  bool get isClosed => _controller.isClosed;

  @override
  bool get isPaused => _controller.isPaused;

  @override
  StreamSink<T> get sink => _controller.sink;

  @override
  NotReplayValueStream<T> get stream => _ValueStreamControllerStream(this);
}

class _ValueStreamControllerStream<T> extends StreamView<T>
    implements NotReplayValueStream<T> {
  final ValueStreamController<T> controller;

  _ValueStreamControllerStream(this.controller) : super(controller.stream);

  @override
  ErrorAndStackTrace? get errorAndStackTrace =>
      controller._dataOrError.errorAndStacktrace;

  @override
  ValueWrapper<T>? get valueWrapper => controller._dataOrError.value;
}
