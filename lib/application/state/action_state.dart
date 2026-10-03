import '../../core/errors/failures.dart';

/// Sealed class representing the lifecycle of an application mutation/command.
sealed class ActionState<T> {
  const ActionState();

  const factory ActionState.idle() = IdleActionState<T>;
  const factory ActionState.loading() = LoadingActionState<T>;
  const factory ActionState.success(T data) = SuccessActionState<T>;
  const factory ActionState.error(String message, {Failure? failure}) = ErrorActionState<T>;

  bool get isIdle => this is IdleActionState<T>;
  bool get isLoading => this is LoadingActionState<T>;
  bool get isSuccess => this is SuccessActionState<T>;
  bool get isError => this is ErrorActionState<T>;

  T? get dataOrNull => this is SuccessActionState<T> ? (this as SuccessActionState<T>).data : null;
  String? get errorOrNull => this is ErrorActionState<T> ? (this as ErrorActionState<T>).message : null;
  Failure? get failureOrNull => this is ErrorActionState<T> ? (this as ErrorActionState<T>).failure : null;

  R fold<R>({
    required R Function() onIdle,
    required R Function() onLoading,
    required R Function(T data) onSuccess,
    required R Function(String message, Failure? failure) onError,
  }) {
    return switch (this) {
      IdleActionState<T>() => onIdle(),
      LoadingActionState<T>() => onLoading(),
      SuccessActionState<T>(:final data) => onSuccess(data),
      ErrorActionState<T>(:final message, :final failure) => onError(message, failure),
    };
  }

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message, Failure? failure) error,
  }) {
    return switch (this) {
      IdleActionState<T>() => idle(),
      LoadingActionState<T>() => loading(),
      SuccessActionState<T>(:final data) => success(data),
      ErrorActionState<T>(:final message, :final failure) => error(message, failure),
    };
  }

  R? whenOrNull<R>({
    R Function()? idle,
    R Function()? loading,
    R Function(T data)? success,
    R Function(String message, Failure? failure)? error,
  }) {
    return switch (this) {
      IdleActionState<T>() => idle?.call(),
      LoadingActionState<T>() => loading?.call(),
      SuccessActionState<T>(:final data) => success?.call(data),
      ErrorActionState<T>(:final message, :final failure) => error?.call(message, failure),
    };
  }
}

class IdleActionState<T> extends ActionState<T> {
  const IdleActionState();
}

class LoadingActionState<T> extends ActionState<T> {
  const LoadingActionState();
}

class SuccessActionState<T> extends ActionState<T> {
  final T data;
  const SuccessActionState(this.data);
}

class ErrorActionState<T> extends ActionState<T> {
  final String message;
  final Failure? failure;
  const ErrorActionState(this.message, {this.failure});
}
