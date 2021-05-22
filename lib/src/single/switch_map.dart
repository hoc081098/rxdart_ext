import 'package:rxdart/rxdart.dart';

import 'single.dart';

/// Provides [switchMapSingle] extension for [Single].
extension SwitchMapSingleExtension<T> on Single<T> {
  /// Likes [switchMap], but returns a [Single].
  Single<R> switchMapSingle<R>(Single<R> Function(T) transform) =>
      Single.safe(switchMap(transform));
}
