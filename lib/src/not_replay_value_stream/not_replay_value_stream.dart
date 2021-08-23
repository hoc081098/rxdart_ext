import 'package:rxdart/rxdart.dart' show ValueStream;

/// The marker interface for [ValueStream] classes
/// that provide synchronous access to the last emitted item,
/// but do not replay the latest value.
abstract class NotReplayValueStream<T> extends ValueStream<T> {}
