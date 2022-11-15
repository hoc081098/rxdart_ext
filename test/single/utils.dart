import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

import '../utils.dart';

void broadcastRule<T>(Single<T> single, bool isBroadcast) {
  void ignoreError(Object e) {}

  if (isBroadcast) {
    expect(single.isBroadcast, true);
    single.listen(null, onError: ignoreError);
    single.listen(null, onError: ignoreError);
  } else {
    expect(single.isBroadcast, false);
    single.listen(null, onError: ignoreError);
    expect(() => single.listen(null, onError: ignoreError), throwsStateError);
  }
}

Future<void> singleRule<T>(Single<T> single, Either<Object, T> e) {
  return expectLater(
    single,
    emitsInOrder(<dynamic>[
      e.fold(ifLeft: (e) => emitsError(e), ifRight: (v) => emits(v)),
      emitsDone,
    ]),
  );
}

Future<void> cancelRule<T>(
  Single<T> single, [
  Duration timeout = const Duration(milliseconds: 10),
]) async {
  unawaited(single
      .listen(
        (v) => fail('$single: onData should not be called'),
        onError: (Object e, StackTrace s) =>
            fail('$single: onError should not be called'),
        onDone: () => fail('$single: onDone should not be called'),
      )
      .cancel());
  await Future<void>.delayed(timeout);
}

final exceptionLeft = Either<Object, Never>.left(isA<Exception>());

Either<Object, Never> buildAPIContractViolationErrorWithMessage(String s) =>
    Either<Object, Never>.left(isA<APIContractViolationError>()
        .having((o) => o.message, 'message', s));
