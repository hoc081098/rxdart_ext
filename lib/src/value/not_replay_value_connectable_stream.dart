import 'dart:async';

import 'package:rxdart/rxdart.dart'
    show ConnectableStream, ConnectableStreamSubscription, ErrorAndStackTrace;

import 'not_replay_value_stream.dart';
import 'value_subject.dart';

///
class NotReplayValueConnectableStream<T> extends ConnectableStream<T>
    implements NotReplayValueStream<T> {
  final ValueSubject<T> _subject;
  final Stream<T> _source;
  var _used = false;

  NotReplayValueConnectableStream._(this._source, this._subject)
      : super(_subject);

  ///
  factory NotReplayValueConnectableStream(Stream<T> source, T seedValue,
          {bool sync = true}) =>
      NotReplayValueConnectableStream._(
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
  NotReplayValueStream<T> autoConnect(
      {void Function(StreamSubscription<T> subscription)? connection}) {
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
  NotReplayValueStream<T> refCount() {
    _checkUsed();
    late ConnectableStreamSubscription<T> subscription;

    _subject.onListen = () => subscription = _connect();
    _subject.onCancel = () => subscription.cancel();

    return _subject;
  }

  @override
  ErrorAndStackTrace? get errorAndStackTrace => _subject.errorAndStackTrace;

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
  NotReplayValueConnectableStream<T> publishValueNotReplay(T seedValue,
          {bool sync = true}) =>
      NotReplayValueConnectableStream(this, seedValue, sync: sync);

  ///
  NotReplayValueStream<T> shareValueNotReplay(T seedValue) =>
      publishValueNotReplay(seedValue).refCount();
}
