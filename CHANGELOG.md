## 0.1.0 - May 7, 2021

-   Support `rxdart: ^0.27.0`.
-   Add `asVoid`.

## 0.0.1 - Feb 28, 2021

-   Add `doOn` extension.
-   Update dependencies to latest version.

## 0.0.1-nullsafety.7 - Feb 8, 2021

-   Add `whereNotNull`.
-   Update `ignoreElements` and `ignoreErrors`.
-   Update `ForwardingSinkMixin`.
-   Rename `ListenNullStreamExtension` to `CollectStreamExtension`.
-   Update docs.

## 0.0.1-nullsafety.6 - Jan 31, 2021

-   Enhance `debug` operator: prints current stacktrace, including location, line and member if not provide the identifier (ie. it is `null`).

## 0.0.1-nullsafety.5 - Jan 31, 2021

-   Added `ValueStreamController`: like a single-subscription `StreamController` except
    the stream of this controller is a single-subscription `NotReplayValueStream`.
-   Added `toNotReplayValueStream` extension: converts a `Stream` to a single-subscription `NotReplayValueStream`.

## 0.0.1-nullsafety.4 - Jan 23, 2021

-   Now, return type of `collect`  is `StreamSubscription<T>`.

## 0.0.1-nullsafety.3 - Jan 21, 2021

-   Added `distinctBy`.
-   Removed generic type of `CollectStreamSubscription`.

## 0.0.1-nullsafety.2 - Jan 08, 2021

-   Update dependency: `rxdart: ^0.26.0-nullsafety.1`.

## 0.0.1-nullsafety.1 - Dec 24, 2020

-   Fix missing exports.

## 0.0.1-nullsafety.0 - Dec 24, 2020

-   Initial version.
