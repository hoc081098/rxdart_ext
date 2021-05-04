import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

// ignore_for_file: public_member_api_docs

class APIContractViolationError extends Error {
  final String message;

  APIContractViolationError(this.message);

  @override
  String toString() => 'APIContractViolationError: $message';
}

@sealed
class Single<T> extends Stream<T> {
  final Stream<T> _stream;
  final bool _isSafe;

  Single._safe(this._stream) : _isSafe = true;

  Single._unsafe(this._stream) : _isSafe = false;

  @override
  bool get isBroadcast => _stream.isBroadcast;

  factory Single.value(T value) => Single._safe(Stream.value(value));

  factory Single.fromCallable(FutureOr<T> Function() callable,
          {bool reusable = false}) =>
      Single._safe(Rx.fromCallable<T>(callable, reusable: reusable));

  factory Single.timer(T value, Duration duration) =>
      Single._safe(Rx.timer(value, duration));

  factory Single.defer(Single<T> Function() streamFactory,
          {bool reusable = false}) =>
      Single._safe(Rx.defer(streamFactory, reusable: reusable));

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = _stream.listen(
      null,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

    if (_isSafe) {
      return subscription..onData(onData);
    }

    var hasValue = false;
    subscription
      ..onData((event) {
        if (hasValue) {
          subscription.cancel();
          throw APIContractViolationError('Has more one element');
        } else {
          hasValue = true;
        }
        onData?.call(event);
      })
      ..onDone(() {
        if (!hasValue) {
          throw APIContractViolationError('Has no element');
        } else {
          onDone?.call();
        }
      });

    return subscription;
  }

  @override
  Single<T> distinct([bool Function(T previous, T next)? equals]) => this;

  @override
  Future<bool> get isEmpty => Future.value(false);

  @override
  Future<int> get length => Future.value(1);

  @override
  Single<S> map<S>(S Function(T event) convert) =>
      Single._safe(_stream.map(convert));
}

extension StreamToSingle<T> on Stream<T> {
  Single<T> singleOrError() {
    final self = this;
    return self is Single<T> ? self : Single._unsafe(self);
  }
}

class Repo {
  Single<String> getSomething() => Single.fromCallable(
        () => Future.delayed(
          const Duration(seconds: 2),
          () => 'something',
        ),
      );
}

void main() {
  Stream<void>.fromIterable([1, 2, 3]).singleOrError().listen(print);

  Repo().getSomething().listen(print);
  Stream.value(1)
      .exhaustMap(
          (value) => Repo().getSomething().map((event) => '$event $value'))
      .listen(print);
}
