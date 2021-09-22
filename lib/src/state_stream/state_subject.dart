import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart' show PublishSubject, Subject;

import '../not_replay_value_stream/value_subject.dart';
import 'state_stream.dart';
import 'state_stream_mixin.dart';

/// A special [StreamController] that captures the latest item that has been
/// added to the controller.
///
/// [StateSubject] is the same as [PublishSubject] and [ValueSubject], with the ability to capture
/// the latest item has been added to the controller.
///
/// [StateSubject] is a [StateStream], that provides synchronous access to the last emitted item,
/// and two consecutive values are not equal.
/// The equality between previous data event and current data event is determined by [equals].
///
/// [StateSubject] allows only data event and close event, error event cannot be added to it.
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
    implements StateStream<T> {
  final ValueSubject<T> _subject;

  @override
  final bool Function(T p1, T p2) equals;

  StateSubject._(
    this.equals,
    this._subject,
  ) : super(_subject, _subject.stream);

  /// Constructs a [StateSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// [seedValue] becomes the current [value] of Subject.
  /// [equals] is used to determine equality between previous data event and current data event.
  ///
  /// See also [StreamController.broadcast],  [ValueSubject].
  factory StateSubject(
    T seedValue, {
    bool Function(T p1, T p2)? equals,
    void Function()? onListen,
    FutureOr<void> Function()? onCancel,
    bool sync = false,
  }) {
    final subject = ValueSubject<T>(
      seedValue,
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );
    return StateSubject._(equals ?? StateStream.defaultEquals, subject);
  }

  @nonVirtual
  @override
  void add(T event) {
    if (!equals(value, event)) {
      _subject.add(event);
    }
  }

  @override
  Future<void> close() => _subject.close();

  @override
  Never addError(Object error, [StackTrace? stackTrace]) => throw UnsupportedError(
      'Cannot add error to StateSubject, error: $error, stackTrace: $stackTrace');

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) {
    final completer = Completer<void>.sync();
    source.listen(
      add,
      onError: addError,
      onDone: completer.complete,
      cancelOnError: cancelOnError,
    );
    return completer.future;
  }

  @override
  T get value => _subject.value;
}
