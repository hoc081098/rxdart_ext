import 'package:rxdart/rxdart.dart';

import 'single.dart';

/// Provides [flatMapSingle] extension for [Single].
extension FlatMapSingleExtension<T> on Single<T> {
  /// Likes [flatMap], but returns a [Single].
  Single<R> flatMapSingle<R>(Single<R> Function(T) transform) =>
      Single.safe(flatMap(transform));
}
