import 'dart:convert';
import 'dart:io';

import 'package:dart_either/dart_either.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart_ext/rxdart_ext.dart';

import 'utils.dart';

class AppError {
  final Object error;
  final StackTrace stackTrace;
  final String message;

  AppError(this.error, this.stackTrace, this.message);

  @override
  String toString() =>
      'AppError{error: $error, stackTrace: $stackTrace, message: $message}';
}

ErrorMapper<AppError> toAppError(String message) =>
    (e, s) => AppError(e, s, message);

typedef Result<T> = Either<AppError, T>;
typedef Eff<T> = Single<Result<T>>;

Eff<R> Function(T) just<T, R>(Result<R> Function(T) f) =>
    (t) => Single.value(f(t));

Result<Uri> parseUri(String uri) =>
    Either.catchError(toAppError('parseUri: $uri'), () => Uri.parse(uri));

Eff<http.Response> httpGet(Uri uri) => Single.fromCallable(() => http.get(uri))
    .toEitherSingle(toAppError('httpGet: $uri'));

Result<String> checkStatusCode(http.Response response) {
  final statusCode = response.statusCode;
  return statusCode >= 200 && statusCode < 300
      ? response.body.right()
      : AppError(
          HttpException(
            'statusCode=$statusCode',
            uri: response.request?.url,
          ),
          StackTrace.current,
          'ensureStatusCode: $response',
        ).left();
}

Result<Object?> parseJson(String body) =>
    Either.catchError(toAppError('parseJson: $body'), () => jsonDecode(body));

Eff<Object?> httpGetEither(String uri) =>
    Single.fromCallable(() => parseUri(uri))
        .flatMapEitherSingle(httpGet)
        .flatMapEitherSingle(just(checkStatusCode))
        .flatMapEitherSingle(just(parseJson));

void main() async {
  await httpGetEither('https://jsonplaceholder.typicode.com/users/1')
      .forEach(print);

  printSeparator();

  await httpGetEither('https://jsonplaceholder.typicode.com/user')
      .forEach(print);

  printSeparator();

  await httpGetEither('::invalid::').forEach(print);
}
