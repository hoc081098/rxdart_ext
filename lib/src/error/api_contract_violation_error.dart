
class APIContractViolationError extends Error {
  final String message;

  APIContractViolationError(this.message);

  @override
  String toString() => 'APIContractViolationError: $message';
}