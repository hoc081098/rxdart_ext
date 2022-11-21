# rxdart_ext

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)

[![codecov](https://codecov.io/gh/hoc081098/rxdart_ext/branch/master/graph/badge.svg?token=OYMVzeUB1m)](https://codecov.io/gh/hoc081098/rxdart_ext)
[![Dart CI](https://github.com/hoc081098/rxdart_ext/actions/workflows/dart.yml/badge.svg)](https://github.com/hoc081098/rxdart_ext/actions/workflows/dart.yml)
[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/rxdart_ext?include_prereleases)](https://pub.dev/packages/rxdart_ext)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fhoc081098%2Frxdart_ext&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
[![GitHub](https://img.shields.io/github/license/hoc081098/rxdart_ext?color=4EB1BA)](https://opensource.org/licenses/MIT)
[![Style](https://img.shields.io/badge/style-lints-40c4ff.svg)](https://pub.dev/packages/lints)

Some extension methods and classes built on top of [`RxDart`](https://pub.dev/packages/rxdart) - [`RxDart`](https://pub.dev/packages/rxdart) extension.

<br>
Liked some of my work? Buy me a coffee (or more likely a beer)

<a href="https://www.buymeacoffee.com/hoc081098" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" height=64></a>

## Supported Dart SDK version: `>=2.12.0 <3.0.0`

## RxDart compatibility

| **rxdart** | **rxdart_ext**  |
|:----------:|:---------------:|
| `^0.27.2`  |     `0.1.2`     |
| `^0.27.3`  | `0.1.3 → 0.2.0` |
| `^0.27.4`  | `0.2.1 → 0.2.2` |
| `^0.27.5`  | `0.2.3 → 0.2.7` |

- For example: when using `rxdart: ^0.27.4` → we can use `rxdart_ext: ^v` where `v` in `0.2.1 → 0.2.7`
  (i.e. all rows since `^0.27.4` row in the above table).

- But in some cases there is any **conflict** between `rxdart` version and `rxdart_ext` version,
  you must use **stricter version**, eg. `rxdart: ^0.27.4` → `rxdart_ext: ^v` where `v` in `0.2.1 → 0.2.2`
  (**same row** in the above table)

- **The latest version of `rxdart_ext` always works fine with the latest version of `rxdart`.**

## API - [Documentation](https://pub.dev/documentation/rxdart_ext/latest/)

### 1. [Single](https://pub.dev/documentation/rxdart_ext/latest/single/Single-class.html)

A Stream which emits single event, either data or error, and then close with a done-event.

```text
Success case: ------------(*)|------
                         data done

Failure case: ------------(x)|------
                        error done
```

> NOTE: Single extends Stream, so all operators and transformers for Stream are available for Single as well.

`Single` is suitable for one-shot operations (likes `Future` but **lazy** - executes when listening), eg. making API request, reading local storage, ...

```dart
import 'package:http/http.dart' as http;

Single<User> fetchUser(String id) {
  return Single.fromCallable(() => http.get(Uri.parse('$baseUrl/users/$id')))
      .flatMapSingle((res) => res.statusCode == HttpStatus.ok
          ? Single.value(res.body)
          : Single.error(Exception('Cannot fetch user with id=$id')))
      .map((body) => User.fromJson(jsonEncode(body)));
}
```

-   Create Single
    -   Factory constructors.
        -   [Single.unsafeFromStream](https://pub.dev/documentation/rxdart_ext/latest/single/Single/Single.unsafeFromStream.html)
        -   [Single.value](https://pub.dev/documentation/rxdart_ext/latest/single/Single/Single.value.html)
        -   [Single.error](https://pub.dev/documentation/rxdart_ext/latest/single/Single/Single.error.html)
        -   [Single.fromFuture](https://pub.dev/documentation/rxdart_ext/latest/single/Single/Single.fromFuture.html)
        -   [Single.fromCallable](https://pub.dev/documentation/rxdart_ext/latest/single/Single/Single.fromCallable.html)
        -   [Single.timer](https://pub.dev/documentation/rxdart_ext/latest/single/Single/Single.timer.html)
        -   [Single.defer](https://pub.dev/documentation/rxdart_ext/latest/single/Single/Single.defer.html)
        -   [Single.retry](https://pub.dev/documentation/rxdart_ext/latest/single/Single/Single.retry.html)

    -   Static methods provided by [RxSingles]() class
        -   [RxSingles.zip2](https://pub.dev/documentation/rxdart_ext/latest/single/RxSingles/zip2.html)
        -   [RxSingles.forkJoin2](https://pub.dev/documentation/rxdart_ext/latest/single/RxSingles/forkJoin2.html)
            ..[RxSingles.forkJoin9](https://pub.dev/documentation/rxdart_ext/latest/single/RxSingles/forkJoin9.html)
            and [RxSingles.forkJoinList](https://pub.dev/documentation/rxdart_ext/latest/single/RxSingles/forkJoinList.html)
        -   [RxSingles.using](https://pub.dev/documentation/rxdart_ext/latest/single/RxSingles/using.html)
        
    -   Convert others to Single via extensions.
        -   [Stream.singleOrError](https://pub.dev/documentation/rxdart_ext/latest/single/SingleOrErrorStreamExtension/singleOrError.html)
        -   [Future.asSingle](https://pub.dev/documentation/rxdart_ext/latest/single/AsSingleFutureExtension/asSingle.html)
        -   [`(FutureOr<T> Function())`.asSingle](https://pub.dev/documentation/rxdart_ext/latest/single/AsSingleFunctionExtension/asSingle.html)

-   Operators for Single (returns a Single instead of Stream)
    -   [flatMapSingle](https://pub.dev/documentation/rxdart_ext/latest/single/FlatMapSingleExtension/flatMapSingle.html)
    -   [flatMapEitherSingle](https://pub.dev/documentation/rxdart_ext/latest/single/FlatMapEitherSingleExtension/flatMapEitherSingle.html)
    -   [asyncExpandSingle](https://pub.dev/documentation/rxdart_ext/latest/single/AsyncExpandSingleExtension/asyncExpandSingle.html)
    -   [switchMapSingle](https://pub.dev/documentation/rxdart_ext/latest/single/SwitchMapSingleExtension/switchMapSingle.html)
    -   [exhaustMapSingle](https://pub.dev/documentation/rxdart_ext/latest/single/ExhaustMapSingleExtension/exhaustMapSingle.html)
    -   [debug](https://pub.dev/documentation/rxdart_ext/latest/single/DebugSingleExtension/debug.html)
    -   [delay](https://pub.dev/documentation/rxdart_ext/latest/single/DelaySingleExtension/delay.html)
    -   [doOnCancel](https://pub.dev/documentation/rxdart_ext/latest/single/DoSingleExtensions/doOnCancel.html)
    -   [doOnData](https://pub.dev/documentation/rxdart_ext/latest/single/DoSingleExtensions/doOnData.html)
    -   [doOnError](https://pub.dev/documentation/rxdart_ext/latest/single/DoSingleExtensions/doOnError.html)
    -   [doOnListen](https://pub.dev/documentation/rxdart_ext/latest/single/DoSingleExtensions/doOnListen.html)
    -   [onErrorReturn](https://pub.dev/documentation/rxdart_ext/latest/single/OnErrorResumeSingleExtensions/onErrorReturn.html)
    -   [onErrorReturnWith](https://pub.dev/documentation/rxdart_ext/latest/single/OnErrorResumeSingleExtensions/onErrorReturnWith.html)
    -   [onErrorResumeSingle](https://pub.dev/documentation/rxdart_ext/latest/single/OnErrorResumeSingleExtensions/onErrorResumeSingle.html)
    -   [onErrorResumeNextSingle](https://pub.dev/documentation/rxdart_ext/latest/single/OnErrorResumeSingleExtensions/onErrorResumeNextSingle.html)
    -   [mapTo](https://pub.dev/documentation/rxdart_ext/latest/single/MapToSingleExtension/mapTo.html)
    -   [toEitherSingle](https://pub.dev/documentation/rxdart_ext/latest/single/ToEitherSingleExtension/toEitherSingle.html)
    -   [asVoid](https://pub.dev/documentation/rxdart_ext/latest/single/AsVoidSingleExtension/asVoid.html)

### 2. Operators for Stream

- [debug](https://pub.dev/documentation/rxdart_ext/latest/operators/DebugStreamExtension/debug.html), [collect](https://pub.dev/documentation/rxdart_ext/latest/operators/CollectStreamExtension/collect.html)
- [distinctUniqueBy](https://pub.dev/documentation/rxdart_ext/latest/operators/DistinctUniqueByStreamExtension/distinctUniqueBy.html)
- [distinctBy](https://pub.dev/documentation/rxdart_ext/latest/operators/DistinctByExtension/distinctBy.html)
- [doOn](https://pub.dev/documentation/rxdart_ext/latest/operators/DoOnStreamExtensions/doOn.html)
- [doneOnError](https://pub.dev/documentation/rxdart_ext/latest/operators/DoneOnErrorStreamExtension/doneOnError.html)
- [flatMapBatches](https://pub.dev/documentation/rxdart_ext/latest/operators/FlatMapBatchesStreamExtension/flatMapBatches.html)
- [flatMapBatchesSingle](https://pub.dev/documentation/rxdart_ext/latest/operators/FlatMapBatchesStreamExtension/flatMapBatchesSingle.html)
- [ignoreErrors](https://pub.dev/documentation/rxdart_ext/latest/operators/IgnoreErrorsStreamExtension/ignoreErrors.html)
- `mapNotNull` (moved to `rxdart 0.27.4` as standard operator: [mapNotNull](https://pub.dev/documentation/rxdart/latest/rx/MapNotNullExtension/mapNotNull.html))
- [toSingleSubscription](https://pub.dev/documentation/rxdart_ext/latest/operators/ToSingleSubscriptionStreamExtension/toSingleSubscriptionStream.html)
- [asVoid](https://pub.dev/documentation/rxdart_ext/latest/operators/AsVoidStreamExtension/asVoid.html)
- `whereNotNull` (moved to `rxdart 0.27.4` as standard operator: [whereNotNull](https://pub.dev/documentation/rxdart/latest/rx/WhereNotNullExtension/whereNotNull.html))

### 3. [StateStream](https://pub.dev/documentation/rxdart_ext/latest/state_stream/StateStream-class.html)

A Stream that provides synchronous access to the last emitted item,
and two consecutive values are not equal.
The equality between previous data event and current data event is determined by [StateStream.equals]((https://pub.dev/documentation/rxdart_ext/latest/state_stream/StateStream/equals.html)).
This Stream always has no error.

-   Broadcast
    - [StateSubject](https://pub.dev/documentation/rxdart_ext/latest/state_stream/StateSubject-class.html)
    - [StateConnectableStream](https://pub.dev/documentation/rxdart_ext/latest/state_stream/StateConnectableStream-class.html)
        - [publishState](https://pub.dev/documentation/rxdart_ext/latest/state_stream/StateConnectableExtensions/publishState.html)
        - [shareState](https://pub.dev/documentation/rxdart_ext/latest/state_stream/StateConnectableExtensions/shareState.html)
-   Single-subscription
    -   [toStateStream](https://pub.dev/documentation/rxdart_ext/latest/state_stream/ToStateStreamExtension/toStateStream.html)

#### Example

Useful for `Flutter BLoC pattern` - `StreamBuilder`, expose broadcast state stream to UI, can synchronous access to the last emitted item, and distinct until changed

-   [x] `Distinct`: distinct until changed.
-   [x] `Value`: can synchronous access to the last emitted item.
-   [x] `NotReplay`: not replay the latest value.
-   [x] `Connectable`: broadcast stream - can be listened to multiple time.

```
                                Stream (dart:core)
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

```dart
class UiState { ... }

final Stream<UiState> state$ = ...;

final StateConnectableStream<UiState> state$ = state$.publishState(UiState.initial());
final connection = state$.connect();

StreamBuilder<UiState>(
  initialData: state$.value,
  stream: state$,
  builder: (context, snapshot) {
    final UiState state = snapshot.requireData;
    
    return ...;
  },
);
```

See also [flutter_bloc_pattern/RxStreamBuilder](https://pub.dev/documentation/flutter_bloc_pattern/latest/flutter_bloc_pattern/RxStreamBuilder-class.html),
it can be used with `StateStream` perfectly and more easily (don't require `initialData` and don't need to call `snapshot.requireData`).

```dart
final StateStream<UiState> state$;

RxStreamBuilder<UiState>(
  stream: state$,
  builder: (context, UiState state) {
    // use state directly
    return ...;
  }
);
```

### 4. [NotReplayValueStream](https://pub.dev/documentation/rxdart_ext/latest/not_replay_value_stream/NotReplayValueStream-class.html)

A Stream that provides synchronous access to the last emitted item, but not replay the latest value.

-   Broadcast
    - [ValueSubject](https://pub.dev/documentation/rxdart_ext/latest/not_replay_value_stream/ValueSubject-class.html)
    - [NotReplayValueConnectableStream](https://pub.dev/documentation/rxdart_ext/latest/not_replay_value_stream/NotReplayValueConnectableStream-class.html)
        - [publishValueNotReplay](https://pub.dev/documentation/rxdart_ext/latest/not_replay_value_stream/ValueConnectableNotReplayStreamExtensions/publishValueNotReplay.html)
        - [shareValueNotReplay](https://pub.dev/documentation/rxdart_ext/latest/not_replay_value_stream/ValueConnectableNotReplayStreamExtensions/shareValueNotReplay.html)
-   Single-subscription
    -   [ValueStreamController](https://pub.dev/documentation/rxdart_ext/latest/not_replay_value_stream/ValueStreamController-class.html)
    -   [toNotReplayValueStream](https://pub.dev/documentation/rxdart_ext/latest/not_replay_value_stream/ToNotReplayValueStreamExtension/toNotReplayValueStream.html)

### 5. Utils

#### DisposableMixin

A mixin that makes it easy to dispose streams without having to store and close a `StreamSubscription` variable.

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

## License

    MIT License

    Copyright (c) 2020-2022 Petrus Nguyễn Thái Học

![Tim Cook dancing to the sound of a permissive license.](http://i.imgur.com/mONiWzj.gif)
