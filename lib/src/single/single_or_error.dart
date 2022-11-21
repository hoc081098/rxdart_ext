import 'api_contract_violation_error.dart';
import 'single.dart';

/// Provides [singleOrError] extension for [Stream].
extension SingleOrErrorStreamExtension<T> on Stream<T> {
  /// Converts this source [Stream] into a [Single].
  /// If this source [Stream] is already a [Single], it will be returned as-is.
  ///
  /// If this source [Stream] does **NOT** emit exactly **ONE** data event
  /// or **ONE** error event before successfully completing,
  /// the returned [Single] will emit an [APIContractViolationError].
  ///
  /// **NOTE**: Because of that, consider using `take(1).doneOnError()` to this
  /// source [Stream] before using this operator to create a [Single] safety.
  ///
  /// This is an alias of [Single.unsafeFromStream].
  ///
  /// ### Example
  ///
  ///     Stream.value(1).singleOrError(); // Single of 1
  ///     Stream<int>.error(Exception()).singleOrError(); // Single of Exception()
  ///
  ///     Rx.concat<int>([
  ///       Stream.fromIterable([1, 2, 3, 4]),
  ///       Stream<int>.error(Exception()),
  ///       Stream.value(1),
  ///       Stream<int>.error(Exception()),
  ///     ]).take(1)
  ///       .doneOnError()
  ///       .singleOrError(); // Single of 1
  Single<T> singleOrError() => Single.unsafeFromStream(this);
}

/// Return this [Single].
extension SingleOrErrorSingleExtension<T> on Single<T> {
  /// Return this [Single].
  @Deprecated('Applying singleOnError() to a Single has no effect. '
      'Use this Single directly instead.')
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Single<T> singleOrError() => this;
}
