import '../../core/errors/failures.dart';

/// Translates domain and data Failures into presentation-safe, human-readable strings.
class ErrorMapper {
  const ErrorMapper._();

  static String mapFailureToMessage(Failure failure) {
    assert(() {
      // In development, log the raw failure details without breaking production encapsulation
      // ignore: avoid_print
      print('[ErrorMapper] Mapping failure: $failure');
      return true;
    }());

    return switch (failure) {
      ValidationFailure(:final message) => message.isNotEmpty ? message : 'Invalid input provided.',
      NotFoundFailure(:final message) => message.isNotEmpty ? message : 'The requested item could not be found.',
      CurrencyMismatchFailure(:final message) => message.isNotEmpty ? message : 'Currency mismatch detected. Operations must use the same currency.',
      InvalidMoneyFailure(:final message) => message.isNotEmpty ? message : 'Invalid monetary amount. Must be greater than zero.',
      InvalidTransactionFailure(:final message) => message.isNotEmpty ? message : 'Transaction validation failed.',
      DuplicateEntityFailure(:final message) => message.isNotEmpty ? message : 'An item with this identifier already exists.',
      DatabaseFailure() => 'A database error occurred. Your changes were safely kept.',
      SecurityFailure() => 'Security verification failed.',
      FormatFailure() => 'Unable to process format.',
      _ => failure.message.isNotEmpty ? failure.message : 'An unexpected error occurred.',
    };
  }
}
