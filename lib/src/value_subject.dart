import 'dart:async';

import 'package:rxdart/rxdart.dart';

enum _Event { data, error }

class _DataOrError<T> {
  _Event event;
  T value;
  ErrorAndStackTrace errorAndStacktrace;

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
class ValueSubject<T> extends Subject<T> implements ValueStream<T> {
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
    void Function() onListen,
    void Function() onCancel,
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
  void onAddError(Object error, [StackTrace stackTrace]) =>
      _dataOrError.onError(ErrorAndStackTrace(error, stackTrace));

  @override
  bool get hasValue => _dataOrError.hasValue;

  @override
  T get value => _dataOrError.value;

  @override
  ErrorAndStackTrace get errorAndStackTrace => _dataOrError.errorAndStacktrace;

  @override
  bool get hasError => _dataOrError.hasError;

  @override
  Subject<R> createForwardingSubject<R>({
    void Function() onListen,
    void Function() onCancel,
    bool sync = false,
  }) =>
      PublishSubject(
        onListen: onListen,
        onCancel: onCancel,
        sync: sync,
      );
}

///
class ValueConnectableNotReplayStream<T> extends ConnectableStream<T>
    implements ValueStream<T> {
  final ValueSubject<T> _subject;
  final Stream<T> _source;
  var _used = false;

  ValueConnectableNotReplayStream._(this._source, this._subject)
      : super(_subject);

  ///
  factory ValueConnectableNotReplayStream(Stream<T> source, T seedValue,
          {bool sync = true}) =>
      ValueConnectableNotReplayStream._(
          source, ValueSubject(seedValue, sync: sync));

  void _checkUsed() {
    if (_used) {
      throw StateError('Cannot reuse this stream. This causes many problems.');
    }
    _used = true;
  }

  ConnectableStreamSubscription<T> _connect() =>
      ConnectableStreamSubscription<T>(
        _source.listen(
          _subject.add,
          onError: _subject.addError,
          onDone: _subject.close,
        ),
        _subject,
      );

  @override
  Stream<T> autoConnect(
      {void Function(StreamSubscription<T> subscription) connection}) {
    _checkUsed();

    _subject.onListen = () {
      final subscription = _connect();
      connection?.call(subscription);
    };
    _subject.onCancel = null;

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    _checkUsed();
    _subject.onListen = _subject.onCancel = null;
    return _connect();
  }

  @override
  Stream<T> refCount() {
    _checkUsed();
    ConnectableStreamSubscription<T> subscription;

    _subject.onListen = () => subscription = _connect();
    _subject.onCancel = () => subscription.cancel();

    return _subject;
  }

  @override
  ErrorAndStackTrace get errorAndStackTrace => _subject.errorAndStackTrace;

  @override
  bool get hasError => _subject.hasError;

  @override
  bool get hasValue => _subject.hasValue;

  @override
  T get value => _subject.value;
}

///
extension ValueConnectableNotReplayStreamExtensions<T> on Stream<T> {
  ///
  ValueConnectableNotReplayStream<T> publishValueNotReplay(T seedValue) =>
      ValueConnectableNotReplayStream(this, seedValue);

  ///
  Stream<T> shareValueNotReplay(T seedValue) =>
      publishValueNotReplay(seedValue).refCount();
}

void main() async {
  final s = Stream.fromIterable([1, 2, 3, 4]).publishValueNotReplay(0);
  print(s.value);

  s.listen((event) {
    print(event);
    print(s.value);
  });

  s.connect();
  await Future<void>.delayed(const Duration(seconds: 2));
}
