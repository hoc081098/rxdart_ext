import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart' show Rx;

import '../error/api_contract_violation_error.dart';

/// A Stream which emits a single data event before completing.
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
      var hasValue = false;

      subscription = source.listen(
        (data) {
          if (hasValue) {
            subscription!.cancel();
            subscription = null;

            controller.addError(APIContractViolationError(
                'Stream contains more than one element.'));
            controller.close();
            return;
          }

          hasValue = true;
          controller.add(data);
        },
        onError: controller.addError,
        onDone: () {
          if (!hasValue) {
            controller.addError(APIContractViolationError(
                "Stream doesn't contain any elements."));
          }
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

/// TODO
extension StreamToSingle<T> on Stream<T> {
  /// Throws [APIContractViolationError] if this Stream does not emit exactly one element before successfully completing.
  Single<T> singleOrError() {
    final self = this;
    return self is Single<T> ? self : Single._unsafe(self);
  }
}
