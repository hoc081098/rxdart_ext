import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../error/api_contract_violation_error.dart';

/// A Stream which emits a single data event or single error event before completing.
///
/// ```text
/// Success case: ------(*)-------------------------|---
///                    data                        done
///
/// Failure case: ------(x)-------------------------|---
///                    error                       done
/// ```
@sealed
class Single<T> extends StreamView<T> {
  /// Underline source Stream.
  final Stream<T> _stream;

  Single._safe(Stream<T> source)
      : _stream = source,
        assert(source is! Single<T>),
        super(source);

  factory Single._unsafe(Stream<T> source) =>
      source is Single<T> ? source : Single._safe(_buildStream(source));

  /// Creates a [Single] which emits a single data event of [value] before completing.
  ///
  /// See [Stream.value].
  factory Single.value(T value) => Single._safe(Stream.value(value));

  /// Creates a [Single] which emits a single error event before completing.
  ///
  /// See [Stream.error].
  factory Single.error(Object error, [StackTrace? stackTrace]) =>
      Single._safe(Stream.error(error, stackTrace));

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
      Single._safe(Rx.fromCallable<T>(callable, reusable: reusable));

  /// Creates a [Single] which emits the given value after a specified amount of time.
  ///
  /// See [Rx.timer] and [TimerStream].
  factory Single.timer(T value, Duration duration) =>
      Single._safe(Rx.timer(value, duration));

  /// The defer factory waits until an observer subscribes to it, and then it
  /// creates a [Single] with the given factory function.
  ///
  /// By default, this [Single] is a single-subscription Stream. However, it's possible
  /// to make it reusable.
  ///
  /// See [Rx.defer] and [DeferStream].
  factory Single.defer(Single<T> Function() streamFactory,
          {bool reusable = false}) =>
      Single._safe(Rx.defer(streamFactory, reusable: reusable));

  @override
  Single<T> distinct([bool Function(T previous, T next)? equals]) => this;

  @override
  Single<S> map<S>(S Function(T event) convert) =>
      Single._safe(_stream.map(convert));

  @override
  Single<E> asyncMap<E>(FutureOr<E> Function(T event) convert) =>
      Single._safe(_stream.asyncMap(convert));

  static Stream<T> _buildStream<T>(Stream<T> source) {
    final controller = source.isBroadcast
        ? StreamController<T>.broadcast(sync: true)
        : StreamController<T>(sync: true);
    StreamSubscription<T>? subscription;

    controller.onListen = () {
      var value = _null;
      ErrorAndStackTrace? error;

      subscription = source.listen(
        (data) {
          if (value._isNotNull) {
            controller.addError(APIContractViolationError(
                'Stream contains more than one data event.'));
            controller.close();
            return;
          }
          if (error != null) {
            controller.addError(APIContractViolationError(
                'Stream contains both data and error event.'));
            controller.close();
            return;
          }

          value = data;
        },
        onError: (Object e, StackTrace s) {
          if (error != null) {
            controller.addError(APIContractViolationError(
                'Stream contains more than one error event.'));
            controller.close();
            return;
          }
          if (value._isNotNull) {
            controller.addError(APIContractViolationError(
                'Stream contains both data and error event.'));
            controller.close();
            return;
          }

          error = ErrorAndStackTrace(e, s);
        },
        onDone: () {
          if (value._isNotNull && error != null) {
            controller.addError(APIContractViolationError(
                'Stream contains both data and error event.'));
            controller.close();
            return;
          }
          if (value._isNull && error == null) {
            controller.addError(APIContractViolationError(
                "Stream doesn't contains any data or error event."));
            controller.close();
          }

          if (error != null) {
            controller.addError(error!.error, error!.stackTrace);
            controller.close();
            return;
          }

          controller.add(value as T);
          controller.close();
        },
      );

      if (!source.isBroadcast) {
        controller
          ..onPause = subscription!.pause
          ..onResume = subscription!.resume;
      }
    };
    controller.onCancel = () {
      final toCancel = subscription;
      subscription = null;
      return toCancel?.cancel();
    };

    return controller.stream;
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

/// Provides [flatMapSingle] extension for [Single].
extension FlatMapSingleExtension<T> on Single<T> {
  /// Likes [flatMap], but returns a [Single].
  Single<R> flatMapSingle<R>(Single<R> Function(T) transform) =>
      Single._safe(flatMap(transform));
}

/// Provides [asyncExpandSingle] extension for [Single].
extension AsyncExpandSingleExtension<T> on Single<T> {
  /// Likes [asyncExpand], but returns a [Single].
  Single<R> asyncExpandSingle<R>(Single<R> Function(T) transform) =>
      Single._safe(asyncExpand(transform));
}

/// Provides [switchMapSingle] extension for [Single].
extension SwitchMapSingleExtension<T> on Single<T> {
  /// Likes [switchMap], but returns a [Single].
  Single<R> switchMapSingle<R>(Single<R> Function(T) transform) =>
      Single._safe(switchMap(transform));
}

/// Provides [exhaustMapSingle] extension for [Single].
extension ExhaustMapSingleExtension<T> on Single<T> {
  /// Likes [exhaustMap], but returns a [Single].
  Single<R> exhaustMapSingle<R>(Single<R> Function(T) transform) =>
      Single._safe(exhaustMap(transform));
}

/// Provides [singleOrError] extension for [Stream].
extension ToSingleStreamExtension<T> on Stream<T> {
  /// Converts this [Stream] into a [Single].
  ///
  /// The returned [Single] emits a [APIContractViolationError]
  /// if this [Stream] does not emit exactly one data event or one error event before successfully completing.
  Single<T> singleOrError() => Single._unsafe(this);
}
