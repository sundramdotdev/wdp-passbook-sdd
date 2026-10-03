/// Errors that can occur during calculator expression evaluation.
enum CalculatorError {
  divisionByZero,
  invalidExpression,
  multipleConsecutiveOperators,
  invalidDecimal,
  emptyExpression,
  negativeResult;

  String get message {
    switch (this) {
      case CalculatorError.divisionByZero:
        return 'Cannot divide by zero';
      case CalculatorError.invalidExpression:
        return 'Invalid expression';
      case CalculatorError.multipleConsecutiveOperators:
        return 'Multiple operators not allowed';
      case CalculatorError.invalidDecimal:
        return 'Invalid decimal number';
      case CalculatorError.emptyExpression:
        return 'Expression is empty';
      case CalculatorError.negativeResult:
        return 'Amount cannot be negative';
    }
  }
}

/// Represents the output of evaluating a calculator expression.
class CalculatorResult {
  final double? value;
  final String formattedResult;
  final CalculatorError? error;

  const CalculatorResult.success(this.value, this.formattedResult)
      : error = null;

  String get formattedValue => formattedResult;

  const CalculatorResult.failure(this.error)
      : value = null,
        formattedResult = '';

  bool get isSuccess => error == null && value != null;
  bool get isFailure => error != null;

  @override
  String toString() => isSuccess
      ? 'CalculatorResult.success($value, "$formattedResult")'
      : 'CalculatorResult.failure(${error?.message})';
}
