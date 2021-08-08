import 'dart:async';

/// Provide [addNull] extension on [StreamController<void>].
extension AddNullStreamControllerExtension on StreamController<void> {
  /// Add `null` to this controller.
  void addNull() => add(null);
}
