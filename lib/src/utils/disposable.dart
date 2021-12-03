import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// This mixin adds an easy option to dispose streams without having to store a
/// [StreamSubscription] variable.
///
/// {@tool snippet}
/// Typical usage is as follows:
///
/// ```dart
/// class ExampleProvider with DisposableMixin {
///   void init() {
///     _stream.takeUntil(dispose$).listen(_handleStream);
///   }
/// }
/// ```
/// {@end-tool}
mixin Disposable {
  final _dispose$ = PublishSubject<void>();

  /// The [PublishSubject] that emits null when the dispose method is called.
  Stream<void> get dispose$ => _dispose$.stream.asBroadcastStream();

  /// Dispose the object and emit null to the [dispose$] stream.
  @mustCallSuper
  void dispose() {
    _dispose$
      ..add(null)
      ..close();
  }
}
