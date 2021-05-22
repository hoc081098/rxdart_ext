import 'package:rxdart/rxdart.dart';

import 'single.dart';

/// Provides [exhaustMapSingle] extension for [Single].
extension ExhaustMapSingleExtension<T> on Single<T> {
  /// Likes [exhaustMap], but returns a [Single].
  Single<R> exhaustMapSingle<R>(Single<R> Function(T) transform) =>
      Single.safe(exhaustMap(transform));
}
