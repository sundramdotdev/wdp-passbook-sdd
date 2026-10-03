import '../errors/failures.dart';

/// Type-safe Result sealed wrapper for domain operations.
sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success<T>;
  factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get valueOrNull => isSuccess ? (this as Success<T>).value : null;
  Failure? get failureOrNull => isFailure ? (this as FailureResult<T>).failure : null;

  R fold<R>(R Function(T value) onSuccess, R Function(Failure failure) onFailure) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).value);
    } else {
      return onFailure((this as FailureResult<T>).failure);
    }
  }
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
}

