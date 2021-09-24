// ignore_for_file: prefer_void_to_null

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart' show ValueStreamError;

import '../state_stream.dart';
import 'as_broadcast.dart';

/// This mixin implements all [StateStream] members except [StateStream.value].
@internal
mixin StateStreamMixin<T> implements StateStream<T> {
  @override
  Never get error => throw ValueStreamError.hasNoError();

  @override
  Null get errorOrNull => null;

  @override
  bool get hasError => false;

  @override
  Null get stackTrace => null;

  @override
  bool get hasValue => true;

  @override
  T get valueOrNull => value;

  @override
  StateStream<T> asBroadcastStream({
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel,
  }) =>
      asBroadcastStateStream(onListen: onListen, onCancel: onCancel);
}
