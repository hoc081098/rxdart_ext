/// TODO
class APIContractViolationError extends Error {
  /// TODO
  final String message;

  /// TODO
  APIContractViolationError(this.message);

  @override
  String toString() => 'APIContractViolationError: $message';
}
