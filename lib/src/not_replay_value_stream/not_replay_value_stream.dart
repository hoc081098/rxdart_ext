import 'package:rxdart/rxdart.dart' show ValueStream;

/// A [Stream] that provides synchronous access to the last emitted item,
/// but not replay the latest value.
abstract class NotReplayValueStream<T> extends ValueStream<T> {}
