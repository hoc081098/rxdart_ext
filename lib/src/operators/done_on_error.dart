import 'dart:async';

import '../utils/default_sink.dart';

class _DoneOnErrorSink<T> extends BaseEventSink<T, T> {
  final bool Function(Object e, StackTrace s) predicate;

  _DoneOnErrorSink(EventSink<T> sink, this.predicate) : super(sink);

  @override
  void add(T event) => sink.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // NOTE: `stackTrace` is always not `null`.
    sink.addError(error, stackTrace!);
    if (predicate(error, stackTrace)) {
      sink.close();
    }
  }
}

bool _alwaysTrue(Object e, StackTrace s) => true;

/// Extends the Stream class with the ability to convert the source Stream
/// to a Stream that emits done event on first error event.
/// The error is included in the output of the returned [Stream].
extension DoneOnErrorStreamExtension<T> on Stream<T> {
  /// Returns a [Stream] that emits done event on first error event.
  /// The error is included in the output of the returned [Stream].
  ///
  /// The optional [predicate] function to determine whether to close on a given error and [StackTrace].
  /// If [predicate] returns `true`, the returned [Stream] emits done event immediately
  /// and no other events will be forwarded.
  /// If `null`, a default predicate will be used, it will always return `true`.
  ///
  /// ### Marble
  ///
  /// ```text
  /// input  : --a---b---c---x---d--|
  /// output : --a---b---c---x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// ### Example
  ///
  ///     Rx.concat<int>([
  ///       Stream.fromIterable([1, 2, 3]),
  ///       Stream.error(Exception('1')),
  ///       Stream.value(4),
  ///       Stream.error(Exception('2')),
  ///       Stream.fromIterable([5, 6, 7]),
  ///     ])
  ///         .doneOnError()
  ///         .listen(print, onError: print); // prints 1, 2, 3, Exception: 1
  ///
  ///     Rx.concat<int>([
  ///       Stream.fromIterable([1, 2, 3]),
  ///       Stream.error(Exception('1')),
  ///       Stream.value(4),
  ///       Stream.error(Exception('2')),
  ///       Stream.fromIterable([5, 6, 7]),
  ///     ])
  ///         .doneOnError((e, s) => e is Exception && e.toString() == 'Exception: 2')
  ///         .listen(print,
  ///             onError: print); // prints 1, 2, 3, Exception: 1, 4, Exception: 2
  Stream<T> doneOnError([bool Function(Object e, StackTrace s)? predicate]) =>
      Stream<T>.eventTransformed(
          this, (sink) => _DoneOnErrorSink<T>(sink, predicate ?? _alwaysTrue));
}
