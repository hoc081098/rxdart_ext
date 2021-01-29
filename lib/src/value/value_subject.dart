import 'dart:async';

import 'package:rxdart/rxdart.dart'
    show ErrorAndStackTrace, PublishSubject, Subject, ValueWrapper;

import 'not_replay_value_stream.dart';
import 'stream_event.dart';

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
  final StreamEvent<T> _dataOrError;

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
      StreamEvent.data(seedValue),
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
