import 'single.dart';

/// Provides [singleOrError] extension for [Stream].
extension ToSingleStreamExtension<T> on Stream<T> {
  /// Converts this [Stream] into a [Single].
  ///
  /// The returned [Single] emits a [APIContractViolationError]
  /// if this [Stream] does not emit exactly one data event or one error event before successfully completing.
  ///
  /// Otherwise, it emits single event, either data or error, and then close with a done-event.
  Single<T> singleOrError() => Single.fromStream(this);
}
