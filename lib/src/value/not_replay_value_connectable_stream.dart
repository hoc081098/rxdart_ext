import 'dart:async';

import 'package:rxdart/rxdart.dart'
    show ConnectableStream, ConnectableStreamSubscription;

import 'not_replay_value_stream.dart';
import 'not_replay_value_stream_mixin.dart';
import 'stream_event.dart';
import 'value_subject.dart';

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast [Stream], and provides synchronous access to the latest emitted value.
///
/// See [NotReplayValueStream].
class NotReplayValueConnectableStream<T> extends ConnectableStream<T>
    with NotReplayValueStreamMixin<T>
    implements NotReplayValueStream<T> {
  final ValueSubject<T> _subject;
  final Stream<T> _source;
  var _used = false;

  NotReplayValueConnectableStream._(this._source, this._subject)
      : super(_subject);

  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a [ValueSubject].
  factory NotReplayValueConnectableStream(Stream<T> source, T seedValue,
          {bool sync = true}) =>
      NotReplayValueConnectableStream._(
        source,
        ValueSubject(seedValue, sync: sync),
      );

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
  StreamEvent<T> get event => _subject.event;
}

/// Extension that converts a [Stream] into [NotReplayValueConnectableStream] and [NotReplayValueStream].
extension ValueConnectableNotReplayStreamExtensions<T> on Stream<T> {
  /// Convert the current Stream into a [ConnectableStream] that can be listened
  /// to multiple times. It will not begin emitting items from the original
  /// Stream until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream and provides synchronous access to the latest emitted value.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Stream.fromIterable([1, 2, 3]);
  /// final connectable = source.publishValueNotReplay(0, sync: true);
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  /// print(connectable.value); // prints 0
  ///
  /// // Start listening to the source Stream. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// await subscription.asFuture<void>();
  /// print(connectable.value); // prints 3
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ValueSubject
  /// subscription.cancel();
  /// ```
  NotReplayValueConnectableStream<T> publishValueNotReplay(T seedValue,
          {bool sync = true}) =>
      NotReplayValueConnectableStream(this, seedValue, sync: sync);

  /// Convert the current Stream into a new Stream that can be listened
  /// to multiple times. It will automatically begin emitting items when first
  /// listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream and provides synchronous access to the latest emitted value.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream
  /// final stream =  Stream.fromIterable([1, 2, 3]).shareValueNotReplay(0);
  /// print(stream.value); // prints 0
  ///
  /// // Start listening to the source Stream. Will start printing 1, 2, 3
  /// final subscription = stream.listen(print);
  ///
  /// await subscription.asFuture<void>();
  /// print(stream.value); // prints 3
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ValueSubject
  /// subscription.cancel();
  /// ```
  NotReplayValueStream<T> shareValueNotReplay(T seedValue) =>
      publishValueNotReplay(seedValue).refCount();
}
