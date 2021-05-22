import 'single.dart';

/// Provides [asyncExpandSingle] extension for [Single].
extension AsyncExpandSingleExtension<T> on Single<T> {
  /// Likes [asyncExpand], but returns a [Single].
  Single<R> asyncExpandSingle<R>(Single<R> Function(T) transform) =>
      Single.safe(asyncExpand(transform));
}
