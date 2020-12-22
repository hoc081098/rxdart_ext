import 'package:rxdart/rxdart.dart' show ValueStream;

/// An [Stream] that provides synchronous access to the last emitted item,
/// but not replay the latest value.
abstract class NotReplayValueStream<T> extends ValueStream<T> {}
