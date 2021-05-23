import 'package:rxdart/rxdart.dart';

import 'exhaust_map.dart';
import 'single.dart';

/// Provides [flatMapSingle] extension for [Single].
extension FlatMapSingleExtension<T> on Single<T> {
  /// Likes [flatMap], but returns a [Single].
  ///
  /// This function is an alias to [exhaustMapSingle] operator.
  Single<R> flatMapSingle<R>(Single<R> Function(T) transform) =>
      exhaustMapSingle(transform);
}
