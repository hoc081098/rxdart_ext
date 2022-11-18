import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart'
    show ErrorAndStackTrace, PublishSubject, Subject;

import 'not_replay_value_stream.dart';
import 'not_replay_value_stream_mixin.dart';
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
@sealed
class ValueSubject<T> extends Subject<T>
    with NotReplayValueStreamMixin<T>
    implements NotReplayValueStream<T> {
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
  NotReplayValueStream<T> get stream => _ValueSubjectStream(this);

  @internal
  @override
  StreamEvent<T> get event => _dataOrError;
}

class _ValueSubjectStream<T> extends Stream<T>
    with NotReplayValueStreamMixin<T>
    implements NotReplayValueStream<T> {
  final ValueSubject<T> _subject;

  _ValueSubjectStream(this._subject);

  @override
  bool get isBroadcast => true;

  // Override == and hashCode so that new streams returned by the same
  // subject are considered equal.
  // The subject returns a new stream each time it's queried,
  // but doesn't have to cache the result.

  @override
  int get hashCode => _subject.hashCode ^ 0x35323532;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ValueSubjectStream && identical(other._subject, _subject);
  }

  @override
  StreamEvent<T> get event => _subject.event;

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _subject.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
