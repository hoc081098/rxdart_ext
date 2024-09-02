import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'state_stream.dart';
import 'state_stream_mixin.dart';
import 'state_subject.dart';

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast [Stream], and provides synchronous access to the latest emitted value.
///
/// This is a combination of [ConnectableStream], [ValueStream], [ValueSubject] and [Stream.distinct].
@sealed
sealed class StateConnectableStream<T> extends ConnectableStream<T>
    implements StateStream<T> {
  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a
  /// [ValueSubject] and distinct until changed.
  ///
  /// Data events are skipped if they are equal to the previous data event.
  /// Equality is determined by the provided [equals] method. If that is omitted,
  /// the '==' operator on the last provided data element is used.
  factory StateConnectableStream(
    Stream<T> source,
    T seedValue, {
    Equality<T>? equals,
    bool sync = true,
  }) =>
      _StateConnectableStream<T>._(
        source,
        StateSubject(seedValue, sync: sync, equals: equals),
        equals,
      );

  @override
  StateStream<T> autoConnect(
      {void Function(StreamSubscription<T> subscription)? connection});

  @override
  StreamSubscription<T> connect();

  @override
  StateStream<T> refCount();
}

final class _StateConnectableStream<T>
    extends AbstractConnectableStream<T, StateSubject<T>, StateStream<T>>
    with StateStreamMixin<T>
    implements StateConnectableStream<T> {
  final StateSubject<T> _subject;

  @override
  final Equality<T> equals;

  _StateConnectableStream._(
    Stream<T> source,
    this._subject,
    Equality<T>? equals,
  )   : equals = equals ?? StateStream.defaultEquality,
        super(source, _subject);

  @override
  T get value => _subject.value;
}

/// Provide two extension methods for [Stream]:
/// - [publishState]
/// - [shareState]
extension StateConnectableExtensions<T> on Stream<T> {
  /// Convert the this Stream into a [StateConnectableStream]
  /// that can be listened to multiple times, providing an initial seeded value.
  /// It will not begin emitting items from the original Stream
  /// until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream, that also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Stream.fromIterable([1, 2, 2, 3, 3, 3]);
  /// final connectable = source.publishState(0);
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Stream. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will not receive anything
  /// connectable.listen(print);
  ///
  /// // Can access the latest emitted value synchronously. Prints 3
  /// print(connectable.value);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ValueSubject
  /// subscription.cancel();
  /// ```
  StateConnectableStream<T> publishState(
    T seedValue, {
    Equality<T>? equals,
    bool sync = true,
  }) =>
      StateConnectableStream<T>(this, seedValue, equals: equals, sync: sync);

  /// Convert the this Stream into a new [StateStream] that can
  /// be listened to multiple times, providing an initial value.
  /// It will automatically begin emitting items when first listened to,
  /// and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final stream = Stream
  ///   .fromIterable([1, 2, 2, 3, 3, 3])
  ///   .shareState(0);
  ///
  /// // Start listening to the source Stream. Will start printing 1, 2, 3
  /// final subscription = stream.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(stream.value);
  ///
  /// // Subscribe again later. Does not print anything.
  /// final subscription2 = stream.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ValueSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  StateStream<T> shareState(
    T seedValue, {
    Equality<T>? equals,
    bool sync = true,
  }) =>
      publishState(seedValue, equals: equals, sync: sync).refCount();
}
