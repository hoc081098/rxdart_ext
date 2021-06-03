import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import 'single_test_utils.dart';

void main() {
  group('Single.onErrorReturn', () {
    test('.success', () async {
      final build = () => Single.value(1).onErrorReturn(99);
      await singleRule(build(), Either.right(1));
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('.failure', () async {
      final build = () => Single<int>.error(Exception()).onErrorReturn(1);
      await singleRule(build(), Either.right(1));
      broadcastRule(build(), false);
      await cancelRule(build());
    });
  });

  group('Single.onErrorReturnWith', () {
    test('.success', () async {
      final build = () =>
          Single.value(1).onErrorReturnWith((e, s) => e is Exception ? 99 : 0);
      await singleRule(build(), Either.right(1));
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('.failure', () async {
      final build1 = () => Single<int>.error(Exception())
          .onErrorReturnWith((e, s) => e is Exception ? 99 : 0);
      await singleRule(build1(), Either.right(99));
      broadcastRule(build1(), false);
      await cancelRule(build1());

      final build2 = () => Single<int>.error(Exception())
          .onErrorReturnWith((e, s) => e is Exception ? throw e : 0);
      await singleRule(build2(), exceptionLeft);
      broadcastRule(build2(), false);
      await cancelRule(build2());
    });
  });

  group('Single.onErrorResumeSingle', () {
    test('.success', () async {
      final build = () => Single.value(1)
          .onErrorResumeSingle((e, s) => Single.value(e is Exception ? 99 : 0));
      await singleRule(build(), Either.right(1));
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('.failure', () async {
      final build1 = () => Single<int>.error(Exception())
          .onErrorResumeSingle((e, s) => Single.value(e is Exception ? 99 : 0));
      await singleRule(build1(), Either.right(99));
      broadcastRule(build1(), false);
      await cancelRule(build1());

      final build2 = () => Single<int>.error(Exception())
          .onErrorResumeSingle((e, s) => Single.error(e, s));
      await singleRule(build2(), exceptionLeft);
      broadcastRule(build2(), false);
      await cancelRule(build2());

      final build3 = () =>
          Single<int>.error(Exception()).onErrorResumeSingle((e, s) => throw e);
      await singleRule(build3(), exceptionLeft);
      broadcastRule(build3(), false);
      await cancelRule(build3());
    });
  });

  group('Single.onErrorResumeNextSingle', () {
    test('.success', () async {
      final build =
          () => Single.value(1).onErrorResumeNextSingle(Single.value(2));
      await singleRule(build(), Either.right(1));
      broadcastRule(build(), false);
      await cancelRule(build());
    });

    test('.failure', () async {
      {
        final build = () => Single<int>.error(Exception())
            .onErrorResumeNextSingle(Single.value(99));
        await singleRule(build(), Either.right(99));
        broadcastRule(build(), false);
        await cancelRule(build());
      }

      {
        final build = () => Single<int>.error(StateError(''))
            .onErrorResumeNextSingle(Single.error(Exception()));
        await singleRule(build(), exceptionLeft);
        broadcastRule(build(), false);
        await cancelRule(build());
      }
    });
  });
}
