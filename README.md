# rxdart_ext

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)

[![codecov](https://codecov.io/gh/hoc081098/rxdart_ext/branch/master/graph/badge.svg?token=OYMVzeUB1m)](https://codecov.io/gh/hoc081098/rxdart_ext)
![Dart CI](https://github.com/hoc081098/rxdart_ext/workflows/Dart%20CI/badge.svg)
[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/rxdart_ext?include_prereleases)](https://pub.dev/packages/rxdart_ext)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fhoc081098%2Frxdart_ext&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
[![GitHub](https://img.shields.io/github/license/hoc081098/rxdart_ext?color=4EB1BA)](https://opensource.org/licenses/MIT)
[![Style](https://img.shields.io/badge/style-pedantic-40c4ff.svg)](https://github.com/dart-lang/pedantic)

Some extension methods and classes built on top of [`RxDart`](https://pub.dev/packages/rxdart) - [`RxDart`](https://pub.dev/packages/rxdart) extension.

## RxDart compatibility

|  rxdart   | rxdart_ext |
|  :---:    | :---:      |
|  `0.26.0`  | `<=0.0.1`     |
|  `>=0.27.0 <=0.27.1`  | `>=0.1.0 <=0.1.1`  |
|  `>=0.27.2`           | `>=0.1.2`  |


## API

### 1. [Single](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single-class.html)

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
        -   [Single.fromStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.fromStream.html)
        -   [Single.value](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.value.html)
        -   [Single.error](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.error.html)
        -   [Single.fromFuture](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.fromFuture.html)
        -   [Single.fromCallable](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.fromCallable.html)
        -   [Single.timer](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.timer.html)
        -   [Single.defer](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.defer.html)
        -   [Single.retry](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/Single/Single.retry.html)

    -   Static methods provided by [RxSingles]() class
        -   [RxSingles.zip2](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/RxSingles/zip2.html)
        -   [RxSingles.forkJoin2](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/RxSingles/forkJoin2.html)
        
    -   Convert others to Single via extensions.
        -   [Stream.singleOrError](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/SingleOrErrorStreamExtension/singleOrError.html)
        -   [Future.asSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsSingleFutureExtension/asSingle.html)
        -   [`(FutureOr<T> Function())`.asSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsSingleFunctionExtension/asSingle.html)

-   Operators for Single (returns a Single instead of Stream)
    -   [flatMapSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/FlatMapSingleExtension/flatMapSingle.html)
    -   [asyncExpandSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsyncExpandSingleExtension/asyncExpandSingle.html)
    -   [switchMapSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/SwitchMapSingleExtension/switchMapSingle.html)
    -   [exhaustMapSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ExhaustMapSingleExtension/exhaustMapSingle.html)
    -   [debug](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DebugSingleExtension/debug.html)
    -   [delay](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DelaySingleExtension/delay.html)
    -   [doOnCancel](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoSingleExtensions/doOnCancel.html)
    -   [doOnData](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoSingleExtensions/doOnData.html)
    -   [doOnError](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoSingleExtensions/doOnError.html)
    -   [doOnListen](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoSingleExtensions/doOnListen.html)
    -   [onErrorReturn](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/OnErrorResumeSingleExtensions/onErrorReturn.html)
    -   [onErrorReturnWith](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/OnErrorResumeSingleExtensions/onErrorReturnWith.html)
    -   [onErrorResumeSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/OnErrorResumeSingleExtensions/onErrorResumeSingle.html)
    -   [onErrorResumeNextSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/OnErrorResumeSingleExtensions/onErrorResumeNextSingle.html)
    -   [mapTo](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/MapToSingleExtension/mapTo.html)
    -   [asVoid](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsVoidSingleExtension/asVoid.html)

### 2. Operators for Stream

- [debug](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DebugStreamExtension/debug.html), [collect](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/CollectStreamExtension/collect.html)
- [distinctUniqueBy](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DistinctUniqueByStreamExtension/distinctUniqueBy.html)
- [distinctBy](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DistinctByExtension/distinctBy.html)
- [doOn](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoOnStreamExtensions/doOn.html)
- [doneOnError](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DoneOnErrorStreamExtension/doneOnError.html)
- [flatMapBatches](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/FlatMapBatchesStreamExtension/flatMapBatches.html)
- [flatMapBatchesSingle](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/FlatMapBatchesStreamExtension/flatMapBatchesSingle.html)
- [ignoreErrors](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/IgnoreErrorsStreamExtension/ignoreErrors.html)
- [mapNotNull](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/MapNotNullStreamExtension/mapNotNull.html)
- [toSingleSubscription](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ToSingleSubscriptionStreamExtension/toSingleSubscriptionStream.html)
- [asVoid](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsVoidStreamExtension/asVoid.html)
- [whereNotNull](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/WhereNotNullStreamExtension/whereNotNull.html)

### 3. [StateStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateStream-class.html)

A Stream that provides synchronous access to the last emitted item,
and two consecutive values are not equal.
The equality between previous data event and current data event is determined by [StateStream.equals]((https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateStream/equals.html)).
This Stream always has no error.

-   Broadcast
    - [StateSubject](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateSubject-class.html)
    - [StateConnectableStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateConnectableStream-class.html)
        - [publishState](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateConnectableExtensions/publishState.html)
        - [shareState](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/StateConnectableExtensions/shareState.html)
-   Single-subscription
    -   [toStateStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ToStateStreamExtension/toStateStream.html)

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

### 4. [NotReplayValueStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/NotReplayValueStream-class.html)

A Stream that provides synchronous access to the last emitted item, but not replay the latest value.

-   Broadcast
    - [ValueSubject](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueSubject-class.html)
    - [NotReplayValueConnectableStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/NotReplayValueConnectableStream-class.html)
        - [publishValueNotReplay](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueConnectableNotReplayStreamExtensions/publishValueNotReplay.html)
        - [shareValueNotReplay](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueConnectableNotReplayStreamExtensions/shareValueNotReplay.html)
-   Single-subscription
    -   [ValueStreamController](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueStreamController-class.html)
    -   [toNotReplayValueStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ToNotReplayValueStreamExtension/toNotReplayValueStream.html)
    
## License

    MIT License

    Copyright (c) 2020-2021 Petrus Nguyễn Thái Học

![Tim Cook dancing to the sound of a permissive license.](http://i.imgur.com/mONiWzj.gif)
