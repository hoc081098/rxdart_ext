import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../utils/default_sink.dart';
import 'single.dart';

class _DelaySingleSink<T> extends ForwardingSink<T, T>
    with ForwardingSinkMixin<T, T> {
  final Duration duration;
  StreamSubscription<T>? subscription;

  _DelaySingleSink(this.duration);

  @override
  void onData(T data) {
    subscription = Rx.timer(data, duration).listen((v) {
      sink.add(v);
      sink.close();
    });
  }

  @override
  void onDone() {
    if (subscription == null) {
      sink.close();
    }
  }

  @override
  FutureOr<void> onCancel() {
    final cancel = subscription?.cancel();
    subscription = null;
    return cancel;
  }

  @override
  void onPause() => subscription?.pause();

  @override
  void onResume() => subscription?.resume();

  @override
  FutureOr<void> onListen() {}
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
  ///source: ---------a|
  ///delay:           ----
  ///result: -------------a|
  ///
  ///source: ---------a|
  ///delay:           -----------
  ///result: --------------------a|
  ///
  ///source: ---------x|
  ///result: ---------x|
  /// ```
  /// [Interactive marble diagram](http://rxmarbles.com/#delay)
  Single<T> delay(Duration duration) =>
      forwardSingleWithSink(() => _DelaySingleSink(duration));
}
