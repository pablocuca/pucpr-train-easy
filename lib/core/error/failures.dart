class Failure {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const Failure(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => 'Failure(message: $message, cause: $cause)';
}
