/// Creates a future that completed with `null` value
/// after the given [milliseconds] has passed.
Future<void> delay(int milliseconds) =>
    Future.delayed(Duration(milliseconds: milliseconds));
