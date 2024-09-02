import 'single.dart';

/// Adapt this `Single<T>` to be a `Single<T?>`.
extension AsNullableSingleExtension<T extends Object> on Single<T> {
  /// Adapt this `Single<T>` to be a `Single<T?>`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Single<T?> asNullable() => this;
}
