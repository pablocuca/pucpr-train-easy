import '../error/failures.dart';

sealed class Result<T> {
  const Result();
  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
  T? get value => this is Ok<T> ? (this as Ok<T>).data : null;
  Failure? get error => this is Err<T> ? (this as Err<T>).failure : null;
}

class Ok<T> extends Result<T> {
  final T data;
  const Ok(this.data);
}

class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
