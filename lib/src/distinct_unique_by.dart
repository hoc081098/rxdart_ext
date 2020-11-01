import 'package:rxdart/rxdart.dart';

///
extension DistinctUniqueByStreamExtension<T> on Stream<T> {
  /// WARNING: More commonly known as distinct in other Rx implementations.
  ///
  /// Creates a Stream where data events are skipped if they have already
  /// been emitted before, based on [hashCode] and [equals] comparison of the objects
  /// returned by the key selector function.
  ///
  /// Equality is determined by the provided equals and hashCode methods.
  /// If these are omitted, the '==' operator and hashCode on the last provided
  /// data element are used.
  ///
  /// The returned stream is a broadcast stream if this stream is. If a
  /// broadcast stream is listened to more than once, each subscription will
  /// individually perform the equals and hashCode tests.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#distinct)
  Stream<T> distinctUniqueBy<R>(
    R Function(T) keySelector, {
    bool Function(R e1, R e2) equals,
    int Function(R e) hashCode,
  }) =>
      distinctUnique(
        equals: (e1, e2) {
          final k1 = keySelector(e1);
          final k2 = keySelector(e2);
          return equals?.call(k1, k2) ?? (k1 == k2);
        },
        hashCode: (e) {
          final k = keySelector(e);
          return hashCode?.call(k) ?? k.hashCode;
        },
      );
}

void main() {
  Stream.fromIterable(['Alpha', 'Beta', 'Gamma'])
      .distinctUniqueBy((e) => e.length)
      .listen(print);
}
