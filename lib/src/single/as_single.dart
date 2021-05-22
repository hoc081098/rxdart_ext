import 'dart:async';

import 'single.dart';

/// Provides [asSingle] extension for [Future].
extension AsSingleStreamExtension<T> on Future<T> {
  /// Converts this [Future] into a [Single].
  ///
  /// See [Single.fromFuture].
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
