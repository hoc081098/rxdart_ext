/// Creates a future that completed with `null` after a delay.
Future<void> delay(int milliseconds) =>
    Future.delayed(Duration(milliseconds: milliseconds));
