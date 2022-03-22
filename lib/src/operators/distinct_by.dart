import '../utils/internal.dart';
import '../utils/equality.dart';

/// Skips data events if their key are equal to the key of the previous data event.
extension DistinctByExtension<T> on Stream<T> {
  /// Skips data events if their key are equal to the key of the previous data event.
  Stream<T> distinctBy<R>(
    R Function(T) keySelector, {
    Equality<R>? equals,
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
