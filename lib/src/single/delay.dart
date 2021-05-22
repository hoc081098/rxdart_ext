import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../default_sink.dart';
import 'single.dart';

class _DelaySingleSink<T>
    with ForwardingSinkMixin<T, T>
    implements ForwardingSink<T, T> {
  final Duration duration;
  var closed = false;
  StreamSubscription<T>? subscription;

  _DelaySingleSink(this.duration);

  @override
  void add(EventSink<T> sink, T data) {
    subscription = Rx.timer(data, duration).listen((v) {
      subscription = null;

      sink.add(v);
      if (closed) {
        sink.close();
      }
    });
  }

  @override
  void close(EventSink<T> sink) {
    if (subscription == null) {
      sink.close();
    } else {
      closed = true;
    }
  }

  @override
  FutureOr<void> onCancel(EventSink<T> sink) {
    final cancel = subscription?.cancel();
    subscription = null;
    return cancel;
  }

  @override
  void onPause(EventSink<T> sink) => subscription?.pause();

  @override
  void onResume(EventSink<T> sink) => subscription?.resume();
}

/// Extends the Single class with the ability to delay events being emitted
extension DelaySingleExtension<T> on Single<T> {
  /// The Delay operator modifies its source Single by pausing for a particular
  /// increment of time (that you specify) before emitting each of the source
  /// Stream’s items. This has the effect of shifting the entire sequence of
  /// items emitted by the Single forward in time by that specified increment.
  ///
  /// ## Marble
  /// ```text
  ///source: ---------a-------|
  ///result: -------------a---|
  ///
  ///source: ---------a-------|
  ///result: --------------------a|
  ///
  ///source: ---------x-------|
  ///result: ---------x-------|
  /// ```
  /// [Interactive marble diagram](http://rxmarbles.com/#delay)
  Single<T> delay(Duration duration) =>
      Single.safe(forwardStream(this, _DelaySingleSink(duration)));
}
