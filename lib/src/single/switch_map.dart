import 'package:rxdart/rxdart.dart';

import 'exhaust_map.dart';
import 'single.dart';

/// Provides [switchMapSingle] extension for [Single].
extension SwitchMapSingleExtension<T> on Single<T> {
  /// Likes [switchMap], but returns a [Single].
  ///
  /// This function is an alias to [exhaustMapSingle] operator.
  Single<R> switchMapSingle<R>(Single<R> Function(T) transform) =>
      Single.safe(exhaustMapSingle(transform));
}
