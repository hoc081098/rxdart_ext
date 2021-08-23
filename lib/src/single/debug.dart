import 'package:stack_trace/stack_trace.dart';

import '../operators/debug.dart';
import '../utils/internal.dart';
import 'single.dart';

/// RxDart debug operator - Port from [RxSwift Debug Operator](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observables/Debug.swift)
///
/// Prints received events for all listeners on standard output.
///
/// See [DebugStreamExtension].
extension DebugSingleExtension<T> on Single<T> {
  /// RxDart debug operator - Port from [RxSwift Debug Operator](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observables/Debug.swift)
  ///
  /// Prints received events for all listeners on standard output.
  ///
  /// The [identifier] is printed together with event description to standard output.
  /// If [identifier] is null, it will be current stacktrace, including location, line and member.
  ///
  /// If [log] is null, this [Stream] is returned without any transformations.
  /// This is useful for disabling logging in release mode of an application.
  ///
  /// If [trimOutput] is true, event text will be trimmed to max 40 characters.
  Single<T> debug({
    String? identifier,
    void Function(String)? log = print,
    bool trimOutput = false,
  }) =>
      Single.safe(
        DebugStreamExtension(this).debug(
          identifier: identifier ?? Trace.current(1).frames.first.formatted,
          log: log,
          trimOutput: trimOutput,
        ),
      );
}
