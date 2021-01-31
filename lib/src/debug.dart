import 'dart:async';
import 'dart:math' as math;

import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart'
    show DoStreamTransformer, Kind, Notification;
import 'package:stack_trace/stack_trace.dart';

extension _NotificationDescriptionExt<T> on Notification<T> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String get description {
    switch (kind) {
      case Kind.OnData:
        return 'data($requireData)';
      case Kind.OnDone:
        return 'done';
      case Kind.OnError:
        final error = errorAndStackTrace!;
        return 'error(${error.error}, ${error.stackTrace})';
    }
  }
}

extension on Frame {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String get formatted {
    final trimmedFile = path.basename(uri.toString());
    return '$trimmedFile:$line ($member)';
  }
}

extension on String {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String take(int n) {
    if (n < 0) {
      throw ArgumentError.value(
        n,
        'n',
        'Requested character count is less than zero.',
      );
    }
    return substring(0, math.min(n, length));
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String takeLast(int n) {
    if (n < 0) {
      throw ArgumentError.value(
        n,
        'n',
        'Requested character count is less than zero.',
      );
    }
    return substring(length - math.min(n, length));
  }
}

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

    return transform<T>(
      DoStreamTransformer<T>(
        onEach: (notification) {
          const maxEventTextLength = 40;

          final description = notification.description;
          final descriptionNormalized = description.length >
                      maxEventTextLength &&
                  trimOutput
              ? '${description.take(maxEventTextLength ~/ 2)}...${description.takeLast(maxEventTextLength ~/ 2)}'
              : description;

          logEvent('Event $descriptionNormalized');
        },
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
