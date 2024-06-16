import 'dart:async';

import 'single.dart';

/// Provides [asSingle] extension for [Future].
extension AsSingleFutureExtension<T> on Future<T> {
  /// Converts this [Future] into a [Single]. It is a shorthand for [Single.fromFuture].
  ///
  /// See also [Single.fromCallable] and [Single.defer]. These methods are useful
  /// or creating [Single]s that don't instantiate [Future]s until they are listened to.
  Single<T> asSingle() => Single.fromFuture(this);
}

/// Provides [asSingle] extension for a Function that returns a [FutureOr].
extension AsSingleFunctionExtension<T> on FutureOr<T> Function() {
  /// Converts this [Function] into a [Single].
  ///
  /// See [Single.fromCallable].
  Single<T> asSingle({bool reusable = false}) =>
      Single.fromCallable(this, reusable: reusable);
}
