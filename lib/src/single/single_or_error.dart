import 'api_contract_violation_error.dart';
import 'single.dart';

/// Provides [singleOrError] extension for [Stream].
extension SingleOrErrorStreamExtension<T> on Stream<T> {
  /// Converts this [Stream] into a [Single].
  ///
  /// The returned [Single] emits a [APIContractViolationError]
  /// if this [Stream] does not emit exactly **ONE** data event or **ONE** error event before successfully completing.
  /// Consider using `take(1).doneOnError()` before using this operator to create a [Single] safety.
  ///
  /// Otherwise, it emits single event, either data or error, and then close with a done-event.
  ///
  /// ### Example
  ///
  ///     Stream.value(1).singleOrError()
  ///     Stream<int>.error(Exception()).singleOrError()
  ///
  ///     Rx.concat<int>([
  ///       Stream.fromIterable([1, 2, 3, 4]),
  ///       Stream<int>.error(Exception()),
  ///       Stream.value(1),
  ///       Stream<int>.error(Exception()),
  ///     ]).take(1)
  ///       .doneOnError()
  ///       .singleOrError();
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
