# rxdart_ext

Some extension methods and classes built on top of `RxDart` - `RxDart` extension.

[![codecov](https://codecov.io/gh/hoc081098/rxdart_ext/branch/master/graph/badge.svg?token=OYMVzeUB1m)](https://codecov.io/gh/hoc081098/rxdart_ext)
![Dart CI](https://github.com/hoc081098/rxdart_ext/workflows/Dart%20CI/badge.svg)
[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/rxdart_ext?include_prereleases)](https://pub.dev/packages/rxdart_ext)

- `debug`, `collect`
- `ForwardingSinkMixin`
- `distinctUniqueBy`
- `distinctBy`
- `ignoreElements`, `ignoreErrors`
- `mapNotNull`
- `toSingleSubscription`
- `NotReplayValueStream`
    -   Broadcast
        -   `ValueSubject`
        -   `NotReplayValueConnectableStream`, `publishValueNotReplay`, `shareValueNotReplay`
    -   Single-subscription
        -   `ValueStreamController`
        -   `toNotReplayValueStream`
    
