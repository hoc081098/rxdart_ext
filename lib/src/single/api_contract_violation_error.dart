/// Generic error thrown on API contract violations.
class APIContractViolationError extends Error {
  /// Error message.
  final String message;

  /// Construct error with message.
  APIContractViolationError(this.message);

  @override
  String toString() => 'APIContractViolationError: $message';
}
