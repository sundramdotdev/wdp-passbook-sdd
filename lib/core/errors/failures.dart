/// Domain-level failure representations for Result<T>.
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure(this.message, {this.code, this.details});

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code, super.details});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.details});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.details});
}

class FormatFailure extends Failure {
  const FormatFailure(super.message, {super.code, super.details});
}

class SecurityFailure extends Failure {
  const SecurityFailure(super.message, {super.code, super.details});
}

class CurrencyMismatchFailure extends Failure {
  const CurrencyMismatchFailure(super.message, {super.code, super.details});
}

class InvalidMoneyFailure extends Failure {
  const InvalidMoneyFailure(super.message, {super.code, super.details});
}

class InvalidTransactionFailure extends Failure {
  const InvalidTransactionFailure(super.message, {super.code, super.details});
}

class DuplicateEntityFailure extends Failure {
  const DuplicateEntityFailure(super.message, {super.code, super.details});
}
