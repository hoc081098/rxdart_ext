import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart'
    show PublishSubject, Subject, BehaviorSubject;

import '../not_replay_value_stream/not_replay_value_stream.dart';
import '../not_replay_value_stream/value_subject.dart';
import 'state_stream.dart';
import 'state_stream_mixin.dart';

/// A special [Subject] / [StreamController] that captures the latest item that has been
/// added to the controller.
///
/// It is very useful for State Management in Flutter, can be used with `StreamBuilder` perfectly.
/// The [StateSubject] avoid rebuilding the widget when the newest event is equals to the latest state of [StateSubject],
/// and it does not rebuild the widget twice on listen,
/// because it does not replay the latest state, compare to [BehaviorSubject].
///
/// [StateSubject] is the same as [PublishSubject] and [ValueSubject], with the ability to capture
/// the latest item has been added to the controller.
///
/// [StateSubject] is a [StateStream], that provides synchronous access to the last emitted item,
/// and two consecutive values are not equal.
/// The equality between previous data event and current data event is determined by [equals].
/// [StateSubject] do **not replay** the latest value, see [NotReplayValueStream].
///
/// [StateSubject] always has **no error**.
/// [StateSubject] allows only data events and close events, error event cannot be added to it.
///
/// [StateSubject] is, by default, a broadcast (aka hot) controller, in order
/// to fulfill the Rx Subject contract. This means the Subject's `stream` can
/// be listened to multiple times.
///
/// ### Example
///
///     final subject = StateSubject<int>(1);
///
///     print(subject.value);          // prints 1
///
///     // observers will receive 2, 3 and done events.
///     subject.stream.listen(print); // prints 2, 3
///     subject.stream.listen(print); // prints 2, 3
///     subject.stream.listen(print); // prints 2, 3
///
///     subject.add(1);
///     subject.add(1);
///     subject.add(2);
///     subject.add(2);
///     subject.add(3);
///     subject.close();
@sealed
class StateSubject<T> extends Subject<T>
    with StateStreamMixin<T>
    implements StateStream<T>, MutableStateStream<T> {
  T _value;
  bool _isAddingStreamItems = false;
  final StreamController<T> _controller;

  @override
  final Equality<T> equals;

  StateSubject._(
    this._value,
    this.equals,
    this._controller,
  ) : super(_controller, _controller.stream);

  /// Constructs a [StateSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// [seedValue] becomes the current [value] of Subject.
  /// [equals] is used to determine equality between previous data event and current data event.
  ///
  /// See also [StreamController.broadcast],  [ValueSubject].
  factory StateSubject(
    T seedValue, {
    Equality<T>? equals,
    void Function()? onListen,
    FutureOr<void> Function()? onCancel,
    bool sync = false,
  }) {
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );
    return StateSubject._(
      seedValue,
      equals ?? StateStream.defaultEquality,
      controller,
    );
  }

  @nonVirtual
  @override
  void add(T event) {
    if (_isAddingStreamItems) {
      throw StateError(
          'You cannot add items while items are being added from addStream');
    }

    _addInternal(event);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void _addInternal(T event) {
    if (!equals(_value, event)) {
      _value = event;
      _controller.add(event);
    }
  }

  @override
  Future<void> close() {
    if (_isAddingStreamItems) {
      throw StateError(
          'You cannot close the subject while items are being added from addStream');
    }
    return _controller.close();
  }

  /// Cannot send an error to this subject.
  /// **Always throws** an [UnsupportedError].
  @override
  Never addError(Object error, [StackTrace? stackTrace]) => throw UnsupportedError(
      'Cannot add error to StateSubject, error: $error, stackTrace: $stackTrace');

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) {
    if (_isAddingStreamItems) {
      throw StateError(
          'You cannot add items while items are being added from addStream');
    }
    _isAddingStreamItems = true;

    final completer = Completer<void>();
    void complete() {
      if (!completer.isCompleted) {
        _isAddingStreamItems = false;
        completer.complete();
      }
    }

    source.listen(
      _addInternal,
      onError: addError,
      onDone: complete,
      cancelOnError: cancelOnError,
    );

    return completer.future;
  }

  @override
  StateStream<T> get stream => _StateSubjectStream<T>(this);

  @override
  T get value => _value;

  @override
  set value(T newValue) => add(newValue);
}

class _StateSubjectStream<T> extends Stream<T>
    with StateStreamMixin<T>
    implements StateStream<T> {
  final StateSubject<T> _subject;

  _StateSubjectStream(this._subject);

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
    return other is _StateSubjectStream && identical(other._subject, _subject);
  }

  @override
  Equality<T> get equals => _subject.equals;

  @override
  T get value => _subject.value;

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
