// ignore_for_file: prefer_void_to_null

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart' show DataNotification, ValueStreamError;

import 'state_stream.dart';

/// This mixin implements all [StateStream] members except [StateStream.value].
@internal
mixin StateStreamMixin<T> implements StateStream<T> {
  @nonVirtual
  @override
  Never get error => throw ValueStreamError.hasNoError();

  @nonVirtual
  @override
  Null get errorOrNull => null;

  @nonVirtual
  @override
  bool get hasError => false;

  @nonVirtual
  @override
  Null get stackTrace => null;

  @nonVirtual
  @override
  bool get hasValue => true;

  @nonVirtual
  @override
  T get valueOrNull => value;

  @override
  DataNotification<T> get lastEventOrNull => DataNotification(value);
}
