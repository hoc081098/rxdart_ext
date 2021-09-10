import 'dart:async';

import 'package:rxdart/rxdart.dart' show DoStreamTransformer;
import 'package:stack_trace/stack_trace.dart';

import '../utils/internal.dart';

/// RxDart debug operator - Port from [RxSwift Debug Operator](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observables/Debug.swift)
///
/// Prints received events for all listeners on standard output.
extension DebugStreamExtension<T> on Stream<T> {
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
  Stream<T> debug({
    String? identifier,
    void Function(String)? log = print,
    bool trimOutput = false,
  }) {
    if (log == null) {
      // logging is disabled.
      return this;
    }

    identifier ??= Trace.current(1).frames.first.formatted;

    @pragma('vm:prefer-inline')
    @pragma('dart2js:tryInline')
    void logEvent(String content) =>
        log('${DateTime.now()}: $identifier -> $content');

    @pragma('vm:prefer-inline')
    @pragma('dart2js:tryInline')
    void logDataErrorDoneEvent(String description) {
      const maxEventTextLength = 40;
      final descriptionNormalized = description.length > maxEventTextLength &&
              trimOutput
          ? '${description.take(maxEventTextLength ~/ 2)}...${description.takeLast(maxEventTextLength ~/ 2)}'
          : description;

      logEvent('Event $descriptionNormalized');
    }

    return transform<T>(
      DoStreamTransformer<T>(
        onData: (data) => logDataErrorDoneEvent('data($data)'),
        onError: (e, s) => logDataErrorDoneEvent('error($e, $s)'),
        onDone: () => logDataErrorDoneEvent('done'),
        onListen: () => logEvent('Listened'),
        onCancel: () => logEvent('Cancelled'),
        onPause: () => logEvent('Paused'),
        onResume: () => logEvent('Resumed'),
      ),
    );
  }
}

/// Listen without any handler.
extension CollectStreamExtension<T> on Stream<T> {
  /// Listen without any handler.
  StreamSubscription<T> collect() =>
      _CollectStreamSubscription<T>(listen(null));
}

/// A [StreamSubscription] cannot replace any handler.
class _CollectStreamSubscription<T> implements StreamSubscription<T> {
  final StreamSubscription<T> _delegate;

  /// Construct a [_CollectStreamSubscription] that delegates all implementation to other [StreamSubscription].
  _CollectStreamSubscription(this._delegate);

  @override
  Future<E> asFuture<E>([E? futureValue]) => _delegate.asFuture(futureValue);

  @override
  Future<void> cancel() => _delegate.cancel();

  @override
  bool get isPaused => _delegate.isPaused;

  @override
  Never onData(void Function(T data)? handleData) =>
      throw StateError('Cannot change onData');

  @override
  Never onDone(void Function()? handleDone) =>
      throw StateError('Cannot change onDone');

  @override
  Never onError(Function? handleError) =>
      throw StateError('Cannot change onError');

  @override
  void pause([Future<void>? resumeSignal]) => _delegate.pause(resumeSignal);

  @override
  void resume() => _delegate.resume();
}
