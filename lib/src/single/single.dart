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
  final Stream<T> _stream;

  Single._safe(Stream<T> source)
      : _stream = source,
        super(source);

  factory Single._unsafe(Stream<T> source) =>
      Single._safe(_buildStream(source));

  /// Creates a [Single] which emits a single data event of [value] before completing.
  factory Single.value(T value) => Single._safe(Stream.value(value));

  /// Creates a [Single] which emits a single error event before completing.
  factory Single.error(Object error, [StackTrace? stackTrace]) =>
      Single._safe(Stream.error(error, stackTrace));

  /// TODO
  factory Single.fromCallable(FutureOr<T> Function() callable,
          {bool reusable = false}) =>
      Single._safe(Rx.fromCallable<T>(callable, reusable: reusable));

  /// TODO
  factory Single.timer(T value, Duration duration) =>
      Single._safe(Rx.timer(value, duration));

  /// TODO
  factory Single.defer(Single<T> Function() streamFactory,
          {bool reusable = false}) =>
      Single._safe(Rx.defer(streamFactory, reusable: reusable));

  @override
  Single<T> distinct([bool Function(T previous, T next)? equals]) => this;

  @override
  Future<bool> get isEmpty => Future.value(false);

  @override
  Future<int> get length => Future.value(1);

  @override
  Single<S> map<S>(S Function(T event) convert) =>
      Single._safe(_stream.map(convert));

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
            subscription!.cancel();
            subscription = null;

            controller.addError(APIContractViolationError(
                'Stream contains more than one element.'));
            controller.close();
            return;
          }

          value = data;
        },
        onError: (Object e, StackTrace s) {
          if (error != null) {
            subscription!.cancel();
            subscription = null;

            controller.addError(APIContractViolationError(
                'Stream contains more than one error.'));
            controller.close();
            return;
          }

          error = ErrorAndStackTrace(e, s);
        },
        onDone: () {
          if (value._isNotNull && error != null) {
            controller.addError(APIContractViolationError(
                'Stream contains both data and error.'));
            controller.close();
            return;
          }
          if (value._isNull && error == null) {
            controller.addError(APIContractViolationError(
                "Stream doesn't contains any data or error."));
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
  bool get _isNull => identical(this, _null);

  bool get _isNotNull => !_isNull;
}

extension FlatMapSingleExtensions<T> on Single<T> {
  Single<R> flatMapSingle<R>(Single<R> Function(T) transform) =>
      Single._safe(flatMap(transform));
}

/// TODO
extension StreamToSingle<T> on Stream<T> {
  /// Throws [APIContractViolationError] if this Stream does not emit exactly one element before successfully completing.
  Single<T> singleOrError() {
    final self = this;
    return self is Single<T> ? self : Single._safe(self);
  }
}
