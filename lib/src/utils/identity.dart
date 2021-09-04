// ignore_for_file: prefer_function_declarations_over_variables

/// A function that always returns the same value that was used as its argument.
final T Function<T>(T) identity = <T>(T i) => i;
