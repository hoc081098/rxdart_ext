# rxdart_ext

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)

[![codecov](https://codecov.io/gh/hoc081098/rxdart_ext/branch/master/graph/badge.svg?token=OYMVzeUB1m)](https://codecov.io/gh/hoc081098/rxdart_ext)
[![Dart CI](https://github.com/hoc081098/rxdart_ext/actions/workflows/dart.yml/badge.svg)](https://github.com/hoc081098/rxdart_ext/actions/workflows/dart.yml)
[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/rxdart_ext?include_prereleases)](https://pub.dev/packages/rxdart_ext)
[![Hits](https://hits.sh/github.com/hoc081098/rxdart_ext.svg)](https://hits.sh/github.com/hoc081098/rxdart_ext/)
[![GitHub](https://img.shields.io/github/license/hoc081098/rxdart_ext?color=4EB1BA)](https://opensource.org/licenses/MIT)
[![Style](https://img.shields.io/badge/style-lints-40c4ff.svg)](https://pub.dev/packages/lints)

Some extension methods and classes built on top of [`RxDart`](https://pub.dev/packages/rxdart) - [`RxDart`](https://pub.dev/packages/rxdart) extension.

<p align="center">
<img src="https://github.com/hoc081098/rxdart_ext/blob/master/screenshots/logo.png?raw=true" height="200" alt="RxDart" />
</p>

Liked some of my work? Buy me a coffee (or more likely a beer)

<a href="https://www.buymeacoffee.com/hoc081098" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" height=64></a>

## RxDart and Dart SDK compatibility

| **rxdart_ext**  | **rxdart** |   **Dart SDK**    |
|:---------------:|:----------:|:-----------------:|
|     `0.1.2`     | `^0.27.2`  | `>=2.12.0 <4.0.0` |
| `0.1.3 → 0.2.0` | `^0.27.3`  | `>=2.12.0 <4.0.0` |
| `0.2.1 → 0.2.2` | `^0.27.4`  | `>=2.12.0 <4.0.0` |
| `0.2.3 → 0.2.9` | `^0.27.5`  | `>=2.12.0 <4.0.0` |
|    `^0.3.0`     | `^0.28.0`  | `>=2.12.0 <4.0.0` |
|    `^0.4.0`     | `^0.28.0`  |     `^3.0.0`      |

**`rxdart_ext 0.4.x` supports `rxdart ^0.28.0` and requires Dart `^3.0.0`.**

> NOTE: `0.4.0` introduces Dart 3 class modifiers. `NotReplayValueStream`, `StateStream` and `MutableStateStream`
> can be implemented, but cannot be extended outside their defining libraries. See [CHANGELOG.md](CHANGELOG.md)
> for all inheritance restrictions and migration notes.

Add the package with `dart pub add rxdart_ext` (or `flutter pub add rxdart_ext` for Flutter projects), then import:

```dart
import 'package:rxdart_ext/rxdart_ext.dart';
```

The main library also exports RxDart. You can import individual libraries such as `package:rxdart_ext/single.dart`
or `package:rxdart_ext/state_stream.dart` when you only need part of the package.

## API - [Documentation](https://pub.dev/documentation/rxdart_ext/latest/)

### 1. [Single](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single-class.html)

A Stream which emits a single event, either data or error, and then closes with a done-event.

```text
Success case: ------------(*)|------
                         data done

Failure case: ------------(x)|------
                        error done
```

> NOTE: Single extends Stream, so all operators and transformers for Stream are available for Single as well.

`Single` is suitable for one-shot operations (like `Future`), eg. making an API request, reading local storage, ...

`Single` can also model a **deferred/lazy computation**. Use `Single.fromCallable` or `Single.defer`
to start the computation only when listening.
`Single.fromFuture` wraps a future that has already been created.

The computation's lifetime can be managed through its `StreamSubscription`.
Calling [`cancel()`](https://api.dart.dev/dart-async/StreamSubscription/cancel.html) stops listening and propagates cancellation upstream,
so the source can stop pending work and release its resources. This makes it easier to manage the computation,
eg. when a BLoC or widget is disposed. Use `await subscription.cancel()` to wait for the source's cleanup.

Cancellation of the underlying work depends on the source. When wrapping a plain `Future`, including one returned by
`Single.fromCallable`, cancelling the subscription stops result delivery but does not abort the future's work.

For example, assuming your app defines `baseUrl` and `User.fromJson`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rxdart_ext/rxdart_ext.dart';

Single<User> fetchUser(String id) {
  return Single.fromCallable(() => http.get(Uri.parse('$baseUrl/users/$id')))
      .flatMapSingle<String>((res) => res.statusCode == HttpStatus.ok
          ? Single.value(res.body)
          : Single.error(Exception('Cannot fetch user with id=$id')))
      .map((body) => User.fromJson(jsonDecode(body) as Map<String, dynamic>));
}
```

- Create Single

  - Factory constructors.

    - [Single.unsafeFromStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.unsafeFromStream.html)
    - [Single.value](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.value.html)
    - [Single.error](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.error.html)
    - [Single.fromFuture](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.fromFuture.html)
    - [Single.fromCallable](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.fromCallable.html)
    - [Single.timer](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.timer.html)
    - [Single.defer](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.defer.html)
    - [Single.retry](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.retry.html)

  - Static methods provided by [RxSingles](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/RxSingles-class.html) class
    - [RxSingles.zip2](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/RxSingles/zip2.html)
    - [RxSingles.forkJoin2](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/RxSingles/forkJoin2.html)
      ..[RxSingles.forkJoin9](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/RxSingles/forkJoin9.html)
      and [RxSingles.forkJoinList](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/RxSingles/forkJoinList.html)
    - [RxSingles.using](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/RxSingles/using.html)
  - Convert others to Single via extensions.
    - [Stream.singleOrError](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/SingleOrErrorStreamExtension/singleOrError.html)
    - [Future.asSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsSingleFutureExtension/asSingle.html)
    - [`(FutureOr<T> Function())`.asSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsSingleFunctionExtension/asSingle.html)

- Operators for Single (return a Single instead of Stream)
  - [asNullable](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsNullableSingleExtension/asNullable.html)
  - [flatMapSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/FlatMapSingleExtension/flatMapSingle.html)
  - [flatMapEitherSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/FlatMapEitherSingleExtension/flatMapEitherSingle.html)
  - [asyncExpandSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsyncExpandSingleExtension/asyncExpandSingle.html)
  - [switchMapSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/SwitchMapSingleExtension/switchMapSingle.html)
  - [exhaustMapSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ExhaustMapSingleExtension/exhaustMapSingle.html)
  - [debug](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DebugSingleExtension/debug.html)
  - [delay](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DelaySingleExtension/delay.html)
  - [doOnCancel](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoSingleExtensions/doOnCancel.html)
  - [doOnData](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoSingleExtensions/doOnData.html)
  - [doOnError](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoSingleExtensions/doOnError.html)
  - [doOnListen](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoSingleExtensions/doOnListen.html)
  - [onErrorReturn](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/OnErrorResumeSingleExtensions/onErrorReturn.html)
  - [onErrorReturnWith](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/OnErrorResumeSingleExtensions/onErrorReturnWith.html)
  - [onErrorResumeSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/OnErrorResumeSingleExtensions/onErrorResumeSingle.html)
  - [onErrorResumeNextSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/OnErrorResumeSingleExtensions/onErrorResumeNextSingle.html)
  - [mapTo](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/MapToSingleExtension/mapTo.html)
  - [toEitherSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ToEitherSingleExtension/toEitherSingle.html)
  - [asVoid](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsVoidSingleExtension/asVoid.html)

### 2. Operators for Stream

- [asNullable](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsNullableStreamExtension/asNullable.html)
- [debug](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DebugStreamExtension/debug.html), [collect](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/CollectStreamExtension/collect.html)
- [distinctUniqueBy](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DistinctUniqueByStreamExtension/distinctUniqueBy.html)
- [distinctBy](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DistinctByExtension/distinctBy.html)
- [doOn](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoOnStreamExtensions/doOn.html)
- [doneOnError](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoneOnErrorStreamExtension/doneOnError.html)
- [flatMapBatches](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/FlatMapBatchesStreamExtension/flatMapBatches.html)
- [flatMapBatchesSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/FlatMapBatchesStreamExtension/flatMapBatchesSingle.html)
- [ignoreErrors](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/IgnoreErrorsStreamExtension/ignoreErrors.html)
- `mapNotNull` (moved to `rxdart 0.27.4` as standard operator: [mapNotNull](https://pub.dev/documentation/rxdart/latest/rx/MapNotNullExtension/mapNotNull.html))
- [toSingleSubscriptionStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ToSingleSubscriptionStreamExtension/toSingleSubscriptionStream.html)
- [asVoid](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsVoidStreamExtension/asVoid.html)
- `whereNotNull` (moved to `rxdart 0.27.4` as standard operator: [whereNotNull](https://pub.dev/documentation/rxdart/latest/rx/WhereNotNullExtension/whereNotNull.html))

`asNullable()` adapts a `Stream<T>` to `Stream<T?>` without wrapping the source stream.
Useful when an operator needs a nullable seed value:

```dart
final source$ = Stream.fromIterable([1, 2, 3]);
final StateConnectableStream<int?> state$ = source$.asNullable().publishState(null);

// The Single version preserves the Single type and the original instance.
final Single<int?> single = Single.value(1).asNullable();
```

### 3. [StateStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateStream-class.html)

A Stream that provides synchronous access to the latest value,
and skips consecutive equal values.
The equality between the previous value and the current value is determined by [StateStream.equals](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateStream/equals.html), using `==` by default.
This Stream always has no error and **does not replay** the latest value to new listeners.

- Broadcast
  - [StateSubject](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateSubject-class.html)
  - [StateConnectableStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateConnectableStream-class.html)
    - [publishState](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateConnectableExtensions/publishState.html)
    - [shareState](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateConnectableExtensions/shareState.html)
- Single-subscription
  - [toStateStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ToStateStreamExtension/toStateStream.html)

`StateSubject` also implements [MutableStateStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/MutableStateStream-class.html),
so you can assign `value` directly or use `update`, `getAndUpdate` and `updateAndGet`.
`getAndUpdate` returns the previous value; `updateAndGet` returns the new value.

#### Example

Useful for `Flutter BLoC pattern` - `StreamBuilder`: expose a broadcast state stream to the UI,
with synchronous access to the latest value and distinct until changed behavior.

- [x] `Distinct`: distinct until changed.
- [x] `Value`: synchronous access to the latest value.
- [x] `NotReplay`: does not replay the latest value to new listeners.
- [x] `Connectable`: `publishState` creates a broadcast stream that starts when `connect()` is called.

The arrows below show subtype relationships:

```text
                                Stream (dart:async)
                                   ^
                                   |
                                   |
            |--------------------------------------------|
            |                                            |
            |                                            |
        ValueStream (rxdart)                             |
            ^                                            |
            |                                            |
            |                                            |
    NotReplayValueStream (rxdart_ext)                    |
            ^                                    ConnectableStream (rxdart)
            |                                            ^
            |                                            |
       StateStream (rxdart_ext)                          |
            ^                                            |
            |                                            |
            |------------                     -----------|
                        |                     |
                        |                     |
                     StateConnectableStream (rxdart_ext)
```

In a Flutter `State<ExamplePage>`, keep the stream and its connection as fields:

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class UiState { ... }

class _ExamplePageState extends State<ExamplePage> {
  late final StateConnectableStream<UiState> state$;
  late final StreamSubscription<UiState> connection;

  @override
  void initState() {
    super.initState();
    final Stream<UiState> source$ = ...;
    state$ = source$.publishState(UiState.initial());
    connection = state$.connect();
  }

  @override
  void dispose() {
    unawaited(connection.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UiState>(
      initialData: state$.value,
      stream: state$,
      builder: (context, snapshot) {
        final UiState state = snapshot.requireData;

        return ...;
      },
    );
  }
}
```

Create the connectable stream once in `initState()` and cancel `connection` in `dispose()`.
`State.dispose()` is synchronous, so use `unawaited` for the cleanup future returned by `connection.cancel()`.
Pass `state$.value` as `initialData` because the stream does not replay it.
This avoids a duplicate initial event that could trigger an unnecessary rebuild.
Use `shareState` when you want the stream to connect automatically on the first listener and disconnect when the last listener cancels.

See also [flutter_bloc_pattern/RxStreamBuilder](https://pub.dev/documentation/flutter_bloc_pattern/latest/flutter_bloc_pattern/RxStreamBuilder-class.html),
it can be used with the same `StateStream` more easily (no need for `initialData` or `snapshot.requireData`).

> NOTE: `flutter_bloc_pattern 3.0.0` depends on `rxdart_ext ^0.3.0`. With `rxdart_ext 0.4.x`,
> the example below requires a compatible `flutter_bloc_pattern` release.

```dart
// Inside build(), using the state$ field from the example above:

RxStreamBuilder<UiState>(
  stream: state$,
  builder: (context, UiState state) {
    // use state directly
    return ...;
  },
);
```

### 4. [NotReplayValueStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/NotReplayValueStream-class.html)

A Stream that provides synchronous access to the latest value, but does not replay it to new listeners.
`ValueSubject` and `ValueStreamController` require a seed value, so their streams have a value even before the first event.

- Broadcast
  - [ValueSubject](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueSubject-class.html)
  - [NotReplayValueConnectableStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/NotReplayValueConnectableStream-class.html)
    - [publishValueNotReplay](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueConnectableNotReplayStreamExtensions/publishValueNotReplay.html)
    - [shareValueNotReplay](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueConnectableNotReplayStreamExtensions/shareValueNotReplay.html)
- Single-subscription
  - [ValueStreamController](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueStreamController-class.html)
  - [toNotReplayValueStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ToNotReplayValueStreamExtension/toNotReplayValueStream.html)

### 5. Utils

#### DisposableMixin

A mixin that makes it easy to cancel stream subscriptions without having to store a `StreamSubscription` variable.

Typical usage is as follows:

```dart
class DisposableExample with DisposableMixin {
  DisposableExample({
    required Stream<DateTime> dateTimeStream,
  }) {
    dateTimeStream.takeUntil(dispose$).listen(
          (value) => print('Disposable example: $value'),
        );
  }
}
```

Call `dispose()` when the owner is no longer needed. This emits on `dispose$`, so `takeUntil(dispose$)`
cancels the subscription. If you override `dispose()`, call `super.dispose()`.

For example, in the `State` of a Flutter `DisposablePage` widget:

```dart
import 'package:flutter/widgets.dart';

class _DisposablePageState extends State<DisposablePage> {
  late final DisposableExample _disposableExample;

  @override
  void initState() {
    super.initState();
    _disposableExample = DisposableExample(
      dateTimeStream: Stream<DateTime>.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _disposableExample.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

## License

    MIT License

    Copyright (c) 2020-2022 Petrus Nguyễn Thái Học

![Tim Cook dancing to the sound of a permissive license.](http://i.imgur.com/mONiWzj.gif)
