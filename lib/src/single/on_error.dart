import 'dart:async';

import '../default_sink.dart';
import 'single.dart';

class _OnErrorReturnSingleSink<T>
    with ForwardingSinkMixin<T, T>
    implements ForwardingSink<T, T> {
  final T returnValue;

  _OnErrorReturnSingleSink(this.returnValue);

  @override
  void add(EventSink<T> sink, T data) => sink.add(data);

  @override
  void addError(EventSink<T> sink, Object error, StackTrace st) =>
      sink.add(returnValue);
}

class _OnErrorReturnWithSingleSink<T>
    with ForwardingSinkMixin<T, T>
    implements ForwardingSink<T, T> {
  final T Function(Object error, StackTrace stackTrace) itemSupplier;

  _OnErrorReturnWithSingleSink(this.itemSupplier);

  @override
  void add(EventSink<T> sink, T data) => sink.add(data);

  @override
  void addError(EventSink<T> sink, Object error, StackTrace st) =>
      sink.add(itemSupplier(error, st));
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

class _OnErrorResumeingleSingleSink<T>
    with ForwardingSinkMixin<T, T>
    implements ForwardingSink<T, T> {
  final Single<T> Function(Object, StackTrace) fallbackSupplier;
  StreamSubscription<T>? subscription;

  _OnErrorResumeingleSingleSink(this.fallbackSupplier);

  @override
  void add(EventSink<T> sink, T data) => sink.add(data);

  @override
  void addError(EventSink<T> sink, Object error, StackTrace st) {
    subscription = fallbackSupplier(error, st).listen(
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

/// TODO
extension OnErrorSingleExtensions<T> on Single<T> {
  /// TODO
  Stream<T> onErrorResumeNextSingle(Single<T> recoverySingle) => Single.safe(
        forwardStream(
          this,
          _OnErrorResumeNextSingleSingleSink(recoverySingle),
        ),
      );

  /// TODO
  Stream<T> onErrorResumeSingle(
          Single<T> Function(Object error, StackTrace stackTrace)
              fallbackSupplier) =>
      Single.safe(
        forwardStream(
          this,
          _OnErrorResumeingleSingleSink(fallbackSupplier),
        ),
      );

  /// TODO
  Single<T> onErrorReturn(T returnValue) => Single.safe(
        forwardStream(
          this,
          _OnErrorReturnSingleSink(returnValue),
        ),
      );

  /// TODO
  Single<T> onErrorReturnWith(
          T Function(Object error, StackTrace stackTrace) itemSupplier) =>
      Single.safe(
        forwardStream(
          this,
          _OnErrorReturnWithSingleSink(itemSupplier),
        ),
      );
}
