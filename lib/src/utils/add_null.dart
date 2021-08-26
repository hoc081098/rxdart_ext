/// Provide [addNull] extension on [Sink<void>].
extension AddNullSinkExtension on Sink<void> {
  /// Add `null` to this [Sink].
  void addNull() => add(null);
}
