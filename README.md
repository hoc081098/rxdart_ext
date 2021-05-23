# rxdart_ext

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)

[![codecov](https://codecov.io/gh/hoc081098/rxdart_ext/branch/master/graph/badge.svg?token=OYMVzeUB1m)](https://codecov.io/gh/hoc081098/rxdart_ext)
![Dart CI](https://github.com/hoc081098/rxdart_ext/workflows/Dart%20CI/badge.svg)
[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/rxdart_ext?include_prereleases)](https://pub.dev/packages/rxdart_ext)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fhoc081098%2Frxdart_ext&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
[![GitHub](https://img.shields.io/github/license/hoc081098/rxdart_ext?color=4EB1BA)](https://opensource.org/licenses/MIT)
[![Style](https://img.shields.io/badge/style-pedantic-40c4ff.svg)](https://github.com/dart-lang/pedantic)

Some extension methods and classes built on top of `RxDart` - `RxDart` extension.

## API

### Single

A Stream which emits single event, either data or error, and then close with a done-event.

```text
Success case: ------------(*)|------
                         data done

Failure case: ------------(x)|------
                        error done
```

> NOTE: Single extends Stream, so all operators and transformers for Stream are available for Single as well.

-   Create Single
    -   Factories and static methods.
        -   [Single.value]()
        -   [Single.error]()
        -   [Single.fromFuture]()
        -   [Single.fromCallable]()
        -   [Single.timer]()
        -   [Single.defer]()
        -   [Single.zip2]()
        
    -   Convert others to Single via extensions.
        -   [Stream.singleOrError]()
        -   [Future.asSingle]()
        -   [(FutureOr<T> Function()).asSingle]()
    
-   Operators for Single
    -   [flatMapSingle]()
    -   [asyncExpandSingle]()
    -   [switchMapSingle]()
    -   [exhaustMapSingle]()
    -   [delay]()

### Operators for Stream

- [debug](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DebugStreamExtension/debug.html), [collect](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/CollectStreamExtension/collect.html)
- [ForwardingSinkMixin](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ForwardingSinkMixin-mixin.html)
- [distinctUniqueBy](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DistinctUniqueByStreamExtension/distinctUniqueBy.html)
- [distinctBy](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/DistinctByExtension/distinctBy.html)
- [ignoreElements](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/IgnoreElementStreamExtension/ignoreElements.html), [ignoreErrors](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/IgnoreErrorsStreamExtension/ignoreErrors.html)
- [mapNotNull](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/MapNotNullStreamExtension/mapNotNull.html)
- [toSingleSubscription](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ToSingleSubscriptionStreamExtension/toSingleSubscriptionStream.html)
- [asVoid](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/AsVoidStreamExtension/asVoid.html)
- [whereNotNull](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/WhereNotNullStreamExtension/whereNotNull.html)

### [NotReplayValueStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/NotReplayValueStream-class.html)

A Stream that provides synchronous access to the last emitted item, but not replay the latest value.

-   Broadcast
    -   [ValueSubject](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueSubject-class.html)
    -   [NotReplayValueConnectableStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/NotReplayValueConnectableStream-class.html), [publishValueNotReplay](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueConnectableNotReplayStreamExtensions/publishValueNotReplay.html), [shareValueNotReplay](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueConnectableNotReplayStreamExtensions/shareValueNotReplay.html)
-   Single-subscription
    -   [ValueStreamController](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ValueStreamController-class.html)
    -   [toNotReplayValueStream](https://pub.dev/documentation/rxdart_ext/latest/rxdart_ext/ToNotReplayValueStreamExtension/toNotReplayValueStream.html)
    


## RxDart compatibility

|  rxdart   | rxdart_ext |
|  :---:    | :---:      |
|  ^0.26.0  | ^0.0.1     |
|  ^0.27.0  | ^0.1.0     |
