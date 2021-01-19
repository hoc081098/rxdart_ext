import 'utils.dart';

/// TODO
extension DistinctByExtension<T> on Stream<T> {
  /// TODO
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
