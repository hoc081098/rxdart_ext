import 'dart:async';

import '../utils/default_sink.dart';
import 'single.dart';

class _OnErrorReturnSingleSink<T> extends BaseEventSink<T, T> {
  final T returnValue;

  _OnErrorReturnSingleSink(EventSink<T> sink, this.returnValue) : super(sink);

  @override
  void add(T data) => sink.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      sink.add(returnValue);
}

class _OnErrorReturnWithSingleSink<T> extends BaseEventSink<T, T> {
  final T Function(Object error, StackTrace stackTrace) itemSupplier;

  _OnErrorReturnWithSingleSink(EventSink<T> sink, this.itemSupplier)
      : super(sink);

  @override
  void add(T data) => sink.add(data);

  @override
  void addError(Object error, [StackTrace? st]) {
    final T item;
    try {
      item = itemSupplier(error, st!); // NOTE: `st` is always not `null`.
    } catch (e, s) {
      sink.addError(e, s);
      return;
    }
    sink.add(item);
  }
}

class _OnErrorResumeNextSingleSingleSink<T>
    with ForwardingSinkMixin<T, T>
    implements ForwardingSink<T, T> {
  final Single<T> recoverySingle;
  StreamSubscription<T>? subscription;

  _OnErrorResumeNextSingleSingleSink(this.recoverySingle);

  @override
  void add(EventSink<T> sink, T data) => sink.add(data);

  @override
  void addError(EventSink<T> sink, Object error, StackTrace st) {
    subscription = recoverySingle.listen(
      (value) {
        sink.add(value);
        sink.close();
      },
      onError: (Object e, StackTrace s) {
        sink.addError(e, s);
        sink.close();
      },
    );
  }

  @override
  void close(EventSink<T> sink) {
    if (subscription == null) {
      sink.close();
    }
  }

  @override
  FutureOr<void> onCancel(EventSink<T> sink) => subscription?.cancel();

  @override
  void onPause(EventSink<T> sink) => subscription?.pause();

  @override
  void onResume(EventSink<T> sink) => subscription?.resume();
}

class _OnErrorResumeSingleSingleSink<T>
    with ForwardingSinkMixin<T, T>
    implements ForwardingSink<T, T> {
  final Single<T> Function(Object, StackTrace) fallbackSupplier;
  StreamSubscription<T>? subscription;

  _OnErrorResumeSingleSingleSink(this.fallbackSupplier);

  @override
  void add(EventSink<T> sink, T data) => sink.add(data);

  @override
  void addError(EventSink<T> sink, Object error, StackTrace st) {
    final Single<T> fallback;
    try {
      fallback = fallbackSupplier(error, st);
    } catch (e, s) {
      sink.addError(e, s);
      return;
    }
    subscription = fallback.listen(
      (value) {
        sink.add(value);
        sink.close();
      },
      onError: (Object e, StackTrace s) {
        sink.addError(e, s);
        sink.close();
      },
    );
  }

  @override
  void close(EventSink<T> sink) {
    if (subscription == null) {
      sink.close();
    }
  }

  @override
  FutureOr<void> onCancel(EventSink<T> sink) => subscription?.cancel();

  @override
  void onPause(EventSink<T> sink) => subscription?.pause();

  @override
  void onResume(EventSink<T> sink) => subscription?.resume();
}

/// Extends the Single class with the ability to recover from errors in various ways.
extension OnErrorResumeSingleExtensions<T> on Single<T> {
  /// Intercepts error events and switches to the given recovery Single in
  /// that case.
  ///
  /// The onErrorResumeNextSingle operator intercepts an onError notification from
  /// the source Single. Instead of passing the error through to any
  /// listeners, it replaces it with another Single.
  ///
  /// If you need to perform logic based on the type of error that was emitted,
  /// please consider using [onErrorResumeSingle].
  ///
  /// ### Marble
  /// ```text
  /// single         : ----------x|
  /// recoverySingle : ----a|
  /// result         : --------------a|
  ///
  /// single         : ----------x|
  /// recoverySingle : ----x|
  /// result         : --------------x|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// ### Example
  ///
  ///     Single<int>.error(Exception())
  ///       .onErrorResumeNextSingle(Single.value(1))
  ///       .listen(print); // prints 1
  Single<T> onErrorResumeNextSingle(Single<T> recoverySingle) =>
      forwardSingleWithSink(_OnErrorResumeNextSingleSingleSink(recoverySingle));

  /// Intercepts error events and switches to a recovery [Single] created by the
  /// provided [fallbackSupplier].
  ///
  /// The onErrorResumeSingle operator intercepts an onError notification from
  /// the source Stream. Instead of passing the error through to any
  /// listeners, it replaces it with another Single created by the [fallbackSupplier].
  ///
  /// The [fallbackSupplier] receives the emitted error and returns a [Single]. You can
  /// perform logic in the [fallbackSupplier] to return different [Single]s based on the
  /// type of error that was emitted.
  ///
  /// If you do not need to perform logic based on the type of error that was
  /// emitted, please consider using [onErrorResumeNextSingle] or [onErrorReturn].
  ///
  /// ### Example
  ///
  ///     Single<int>.error(Exception())
  ///         .onErrorResumeSingle((e, st) => Single.value(e is StateError ? 1 : 0))
  ///         .listen(print); // prints 0
  Single<T> onErrorResumeSingle(
          Single<T> Function(Object error, StackTrace stackTrace)
              fallbackSupplier) =>
      forwardSingleWithSink(_OnErrorResumeSingleSingleSink(fallbackSupplier));

  /// Instructs a Single to emit a particular item when it encounters an
  /// error, and then terminate normally.
  ///
  /// The onErrorReturn operator intercepts an onError notification from
  /// the source Single. Instead of passing it through to any observers, it
  /// replaces it with a given item, and then terminates normally.
  ///
  /// If you need to perform logic based on the type of error that was emitted,
  /// please consider using [onErrorReturnWith].
  ///
  /// ### Marble
  ///
  /// ```text
  /// single      : ----------x|
  /// returnValue : a
  /// result      : ----------a|
  ///
  /// NOTE: x is error event
  /// ```
  ///
  /// ### Example
  ///
  ///     Single<int>.error(Exception())
  ///       .onErrorReturn(1)
  ///       .listen(print); // prints 1
  Single<T> onErrorReturn(T returnValue) =>
      Single.safe(Stream<T>.eventTransformed(
          this, (sink) => _OnErrorReturnSingleSink<T>(sink, returnValue)));

  /// Instructs a Single to emit a particular item created by the
  /// [itemSupplier] when it encounters an error, and then terminate normally.
  ///
  /// The onErrorReturnWith operator intercepts an onError notification from
  /// the source Single. Instead of passing it through to any observers, it
  /// replaces it with a given item, and then terminates normally.
  ///
  /// The [itemSupplier] receives the emitted error and returns a value. You can
  /// perform logic in the [itemSupplier] to return different value based on the
  /// type of error that was emitted.
  ///
  /// If you do not need to perform logic based on the type of error that was
  /// emitted, please consider using [onErrorReturn].
  ///
  /// ### Example
  ///
  ///     Single<int>.error(Exception())
  ///       .onErrorReturnWith((e, s) => e is Exception ? 1 : 0)
  ///       .listen(print); // prints 1
  Single<T> onErrorReturnWith(
          T Function(Object error, StackTrace stackTrace) itemSupplier) =>
      Single.safe(Stream<T>.eventTransformed(
          this, (sink) => _OnErrorReturnWithSingleSink<T>(sink, itemSupplier)));
}
