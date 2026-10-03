/// Base exception classes for data & external layers.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.details});
}

class SecurityException extends AppException {
  const SecurityException(super.message, {super.code, super.details});
}

// Domain Specific Exceptions
class CurrencyMismatchException extends AppException {
  const CurrencyMismatchException(
    String expected,
    String actual,
  ) : super(
          'Currency mismatch: cannot operate on $expected and $actual without explicit conversion.',
          code: 'CURRENCY_MISMATCH',
        );
}

class InvalidMoneyException extends AppException {
  const InvalidMoneyException(super.message) : super(code: 'INVALID_MONEY');
}

class InvalidTransactionException extends AppException {
  const InvalidTransactionException(super.message) : super(code: 'INVALID_TRANSACTION');
}

class AccountNotFoundException extends AppException {
  const AccountNotFoundException(String id)
      : super('Account with ID "$id" not found.', code: 'ACCOUNT_NOT_FOUND');
}

class CategoryNotFoundException extends AppException {
  const CategoryNotFoundException(String id)
      : super('Category with ID "$id" not found.', code: 'CATEGORY_NOT_FOUND');
}

class TransactionNotFoundException extends AppException {
  const TransactionNotFoundException(String id)
      : super('Transaction with ID "$id" not found.', code: 'TRANSACTION_NOT_FOUND');
}

class DuplicateEntityException extends AppException {
  const DuplicateEntityException(super.message) : super(code: 'DUPLICATE_ENTITY');
}
