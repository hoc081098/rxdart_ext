import 'package:dart_either/dart_either.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void broadcastRule<T>(Single<T> single, bool isBroadcast) {
  final ignoreError = (Object e) {};

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
      e.fold((e) => emitsError(e), (v) => emits(v)),
      emitsDone,
    ]),
  );
}

Future<void> cancelRule<T>(
  Single<T> single, [
  Duration timeout = const Duration(seconds: 1),
]) async {
  unawaited(single
      .listen(
        (v) => expect(false, true),
        onError: (Object e, StackTrace s) => expect(false, true),
        onDone: () => expect(false, true),
      )
      .cancel());
  await Future<void>.delayed(timeout);
}

final exceptionLeft = Either<Object, Never>.left(isA<Exception>());
final APIContractViolationErrorWithMessage = (String s) => Either<Object, Never>.left(
    isA<APIContractViolationError>().having((o) => o.message, 'message', s));
