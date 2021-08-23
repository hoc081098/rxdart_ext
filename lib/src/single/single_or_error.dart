import 'api_contract_violation_error.dart';
import 'single.dart';

/// Provides [singleOrError] extension for [Stream].
extension SingleOrErrorStreamExtension<T> on Stream<T> {
  /// Converts this [Stream] into a [Single].
  ///
  /// The returned [Single] emits a [APIContractViolationError]
  /// if this [Stream] does not emit exactly one data event or one error event before successfully completing.
  ///
  /// Otherwise, it emits single event, either data or error, and then close with a done-event.
  Single<T> singleOrError() => Single.fromStream(this);
}

/// Return this [Single].
extension SingleOrErrorSingleExtension<T> on Single<T> {
  /// Return this [Single].
  @Deprecated('Returns itself. Should be removed')
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Single<T> singleOrError() => this;
}
