import 'package:rxdart/rxdart.dart';

import '../utils/others.dart';

/// WARNING: More commonly known as distinct in other Rx implementations.
///
/// Creates a Stream where data events are skipped if they have already
/// been emitted before, based on [hashCode] and [equals] comparison of the objects
/// returned by the [keySelector] function.
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
extension DistinctUniqueByStreamExtension<T> on Stream<T> {
  /// WARNING: More commonly known as distinct in other Rx implementations.
  ///
  /// Creates a Stream where data events are skipped if they have already
  /// been emitted before, based on [hashCode] and [equals] comparison of the objects
  /// returned by the [keySelector] function.
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
    bool Function(R e1, R e2)? equals,
    int Function(R e)? hashCode,
  }) {
    final eq = equals ?? defaultEquals;
    final hash = hashCode ?? defaultHashCode;

    return distinctUnique(
      equals: (e1, e2) => eq(
        keySelector(e1),
        keySelector(e2),
      ),
      hashCode: (e) => hash(keySelector(e)),
    );
  }
}
