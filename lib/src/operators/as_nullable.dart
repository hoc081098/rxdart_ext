/// Adapt this `Stream<T>` to be a `Stream<T?>`.
extension AsNullableStreamExtension<T extends Object> on Stream<T> {
  /// Adapt this `Stream<T>` to be a `Stream<T?>`.
  ///
  /// Useful for broadcast operators that use `null` as the seed or initial value,
  /// such as `publishState(null)` and `publishValueSeed(null)`.
  ///
  /// ### Example
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3, 4]);
  ///
  /// // ERROR: The argument type 'Null' can't be assigned to the parameter type 'int'.
  /// stream.publishState(null);
  ///
  /// final StateConnectableStream<int?> stateStream =
  ///     stream.cast<int?>().publishState(null); // OK but it is verbose and unoptimized.
  ///
  /// final StateConnectableStream<int?> stateStream =
  ///     stream.asNullable().publishState(null); // OK and optimized.
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<T?> asNullable() => this;
}
