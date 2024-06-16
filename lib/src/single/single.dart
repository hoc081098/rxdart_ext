import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/default_sink.dart';
import '../utils/equality.dart';
import 'api_contract_violation_error.dart';
import 'internal.dart';

/// A Stream which emits single event, either data or error, and then close with a done-event.
///
/// ```text
/// Success case: ------------(*)|------
///                          data done
///
/// Failure case: ------------(x)|------
///                         error done
/// ```
@sealed
class Single<T> extends StreamView<T> {
  /// Underline source Stream.
  final Stream<T> _stream;

  ///  @internal
  ///  **DO NOT USE** this getter.
  @internal
  Stream<T> get stream => _stream;

  ///  @internal
  ///  **DO NOT USE** this constructor.
  @internal
  Single.safe(Stream<T> source)
      : _stream = source,
        assert(source is! Single<T>),
        super(source);

  /// Converts source [Stream] into a [Single].
  /// If the source [Stream] is already a [Single], it will be returned as-is.
  ///
  /// If the source [Stream] does **NOT** emit exactly **ONE** data event
  /// or **ONE** error event before successfully completing,
  /// the returned [Single] will emit an [APIContractViolationError].
  ///
  /// **NOTE**: Because of that, consider using `take(1).doneOnError()` to the
  /// source [Stream] before using this constructor to create a [Single] safety.
  ///
  /// ### Example
  ///
  /// ```dart
  /// Single.unsafeFromStream(Stream.value(1)); // Single of 1
  ///
  /// Single.unsafeFromStream(Stream<int>.error(Exception())); // Single of Exception()
  ///
  /// Single.unsafeFromStream(Stream.fromIterable([1, 2])); // Single of APIContractViolationError
  ///
  /// Single.unsafeFromStream(
  ///   Rx.concat<int>([
  ///     Stream.value(1),
  ///     Stream.error(Exception())
  ///   ])
  /// ); // Single of APIContractViolationError
  ///
  /// Single.unsafeFromStream(
  ///   Rx.concat<int>([
  ///     Stream.error(Exception()),
  ///     Stream.error(Exception())
  ///   ])
  /// ) // Single of APIContractViolationError
  ///
  /// Single.unsafeFromStream(
  ///     Rx.concat<int>([
  ///       Stream.fromIterable([1, 2, 3, 4]),
  ///       Stream<int>.error(Exception()),
  ///       Stream.value(1),
  ///       Stream<int>.error(Exception()),
  ///     ])
  ///      .take(1)
  ///      .doneOnError()
  /// ); // Single of 1
  /// ```
  factory Single.unsafeFromStream(Stream<T> source) => source is Single<T>
      ? source
      : Single.safe(Stream<T>.eventTransformed(
          source, (sink) => _SingleOrErrorStreamSink<T>(sink)));

  /// This is an alias of [Single.unsafeFromStream].
  /// See [Single.unsafeFromStream].
  @Deprecated(
      'Use Single.unsafeFromStream instead. This will be removed in v0.3.0')
  factory Single.fromStream(Stream<T> source) =>
      Single.unsafeFromStream(source);

  /// Creates a [Single] which emits a single data event of [value] before completing.
  ///
  /// See [Stream.value].
  factory Single.value(T value) => Single.safe(Stream.value(value));

  /// Creates a [Single] which emits a single error event before completing.
  ///
  /// See [Stream.error].
  factory Single.error(Object error, [StackTrace? stackTrace]) =>
      Single.safe(Stream.error(error, stackTrace));

  /// Creates a new single-subscription [Single] from the future.
  ///
  /// When the future completes, the [Single] will fire one event, either
  /// data or error, and then close with a done-event.
  ///
  /// ## Marble
  ///
  /// ```text
  /// future: ----------a|
  /// result: ----------a|
  ///
  /// future: ----------x|
  /// result: ----------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// See also [Single.fromCallable] and [Single.defer]. These methods are useful
  /// for creating [Single]s that don't instantiate [Future]s until they are listened to.
  factory Single.fromFuture(Future<T> future) =>
      Single.safe(Stream.fromFuture(future));

  /// Creates a [Single] that, when listening to it, calls a function you specify
  /// and then emits the value returned from that function.
  ///
  /// If result from invoking [callable] function:
  /// - Is a [Future]: when the future completes, this [Single] will fire one event, either
  ///   data or error, and then close with a done-event.
  /// - Is a [T]: this [Single] emits a single data event and then completes with a done event.
  ///
  /// By default, this [Single] is a single-subscription Stream. However, it's possible
  /// to make it reusable.
  ///
  /// [ReactiveX doc](http://reactivex.io/documentation/operators/from.html).
  ///
  /// See [Rx.fromCallable] and [FromCallableStream].
  factory Single.fromCallable(FutureOr<T> Function() callable,
          {bool reusable = false}) =>
      Single.safe(Rx.fromCallable<T>(callable, reusable: reusable));

  /// Creates a [Single] which emits the given value after a specified amount of time.
  ///
  /// See [Rx.timer] and [TimerStream].
  factory Single.timer(T value, Duration duration) =>
      Single.safe(Rx.timer(value, duration));

  /// The defer factory waits until an observer subscribes to it, and then it
  /// creates a [Single] with the given factory function.
  ///
  /// By default, this [Single] is a single-subscription Stream. However, it's possible
  /// to make it reusable.
  ///
  /// See [Rx.defer] and [DeferStream].
  factory Single.defer(Single<T> Function() singleFactory,
          {bool reusable = false}) =>
      Single.safe(Rx.defer(singleFactory, reusable: reusable));

  /// Creates a [Single] that will recreate and re-listen to the source
  /// [Single] the specified number of times until the Single terminates
  /// successfully.
  ///
  /// If the retry count is not specified (is null), it retries indefinitely.
  ///
  /// If the retry count is met, but the [Single] has not terminated successfully,
  /// the first error and [StackTrace] that caused the failure will be emitted.
  ///
  /// See [Rx.retry] and [RetryStream].
  factory Single.retry(Single<T> Function() singleFactory, [int? count]) =>
      Rx.retry(singleFactory, count).takeFirstDataOrFirstErrorAndClose();

  @override
  Single<T> distinct([Equality<T>? equals]) => this;

  @override
  Single<S> map<S>(S Function(T event) convert) =>
      Single.safe(_stream.map(convert));

  @override
  Single<R> cast<R>() => Single<R>.safe(_stream.cast<R>());

  @override
  Single<E> asyncMap<E>(FutureOr<E> Function(T event) convert) =>
      Single.safe(_stream.asyncMap(convert));
}

class _SingleOrErrorStreamSink<T> extends BaseEventSink<T, T> {
  var value = _null;
  ErrorAndStackTrace? error;

  _SingleOrErrorStreamSink(EventSink<T> sink) : super(sink);

  @override
  void add(T data) {
    if (value._isNotNull) {
      sink.addError(APIContractViolationError(
          'Stream contains more than one data event.'));
      sink.close();
      return;
    }
    if (error != null) {
      sink.addError(APIContractViolationError(
          'Stream contains both data and error event.'));
      sink.close();
      return;
    }

    value = data;
  }

  @override
  void addError(Object e, [StackTrace? s]) {
    if (error != null) {
      sink.addError(APIContractViolationError(
          'Stream contains more than one error event.'));
      sink.close();
      return;
    }
    if (value._isNotNull) {
      sink.addError(APIContractViolationError(
          'Stream contains both data and error event.'));
      sink.close();
      return;
    }

    error = ErrorAndStackTrace(e, s);
  }

  @override
  void close() {
    if (value._isNull && error == null) {
      sink.addError(APIContractViolationError(
          "Stream doesn't contains any data or error event."));
      sink.close();
      return;
    }

    if (error != null) {
      sink.addError(error!.error, error!.stackTrace);
      sink.close();
      return;
    }

    sink.add(value as T);
    sink.close();
  }
}

const Object? _null = _NULL();

class _NULL {
  const _NULL();
}

extension on Object? {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool get _isNull => identical(this, _null);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool get _isNotNull => !_isNull;
}
