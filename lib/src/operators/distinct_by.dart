import '../utils/internal.dart';

/// Skips data events if their key are equal to the key of the previous data event.
extension DistinctByExtension<T> on Stream<T> {
  /// Skips data events if their key are equal to the key of the previous data event.
  Stream<T> distinctBy<R>(
    R Function(T) keySelector, {
    bool Function(R e1, R e2)? equals,
  }) {
    final eq = equals ?? defaultEquals;
    return distinct(
      (e1, e2) => eq(
        keySelector(e1),
        keySelector(e2),
      ),
    );
  }
}
