import 'package:flutter/foundation.dart';
import 'calculator_engine.dart';
import 'calculator_models.dart';

/// State of the calculator session.
class CalculatorState {
  final String expression;
  final String displayValue;
  final double? numericValue;
  final CalculatorError? error;
  final bool hasEvaluated;

  const CalculatorState({
    required this.expression,
    required this.displayValue,
    this.numericValue,
    this.error,
    this.hasEvaluated = false,
  });

  CalculatorState.initial([double? initialAmount])
      : expression = initialAmount != null && initialAmount > 0
            ? CalculatorEngine.formatNumber(initialAmount)
            : '',
        displayValue = initialAmount != null && initialAmount > 0
            ? CalculatorEngine.formatNumber(initialAmount)
            : '0',
        numericValue = initialAmount != null && initialAmount > 0 ? initialAmount : 0.0,
        error = null,
        hasEvaluated = false;

  CalculatorState copyWith({
    String? expression,
    String? displayValue,
    double? numericValue,
    CalculatorError? error,
    bool? hasEvaluated,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      displayValue: displayValue ?? this.displayValue,
      numericValue: numericValue ?? this.numericValue,
      error: error,
      hasEvaluated: hasEvaluated ?? this.hasEvaluated,
    );
  }
}

/// Controller managing calculation input and interactions outside widgets.
class CalculatorController extends ChangeNotifier {
  final CalculatorEngine _engine;
  CalculatorState _state;

  CalculatorController({
    CalculatorEngine engine = const CalculatorEngine(),
    double? initialAmount,
  })  : _engine = engine,
        _state = CalculatorState.initial(initialAmount);

  CalculatorState get state => _state;

  void setInitialAmount(double amount) {
    _state = CalculatorState.initial(amount);
    notifyListeners();
  }

  void inputDigit(String digit) {
    if (_state.hasEvaluated) {
      // Starting new expression after evaluation
      _state = CalculatorState(
        expression: digit,
        displayValue: digit,
        numericValue: double.tryParse(digit),
        hasEvaluated: false,
      );
    } else {
      final newExpr = _state.expression + digit;
      _state = _state.copyWith(
        expression: newExpr,
        displayValue: newExpr,
        error: null,
      );
    }
    notifyListeners();
  }

  void inputDecimal() {
    if (_state.hasEvaluated) {
      _state = const CalculatorState(
        expression: '0.',
        displayValue: '0.',
        numericValue: 0.0,
        hasEvaluated: false,
      );
      notifyListeners();
      return;
    }

    if (_state.expression.isEmpty) {
      _state = _state.copyWith(
        expression: '0.',
        displayValue: '0.',
        error: null,
      );
      notifyListeners();
      return;
    }

    // Check if the current number segment already has a decimal
    final parts = _state.expression.split(RegExp(r'[+\-×÷]'));
    final lastPart = parts.isNotEmpty ? parts.last : '';
    if (lastPart.contains('.')) {
      _state = _state.copyWith(error: CalculatorError.invalidDecimal);
      notifyListeners();
      return;
    }

    final newExpr = '${_state.expression}.';
    _state = _state.copyWith(
      expression: newExpr,
      displayValue: newExpr,
      error: null,
    );
    notifyListeners();
  }

  void inputOperator(String op) {
    final symbol = op == '*' ? '×' : (op == '/' ? '÷' : op);

    if (_state.expression.isEmpty) {
      if (symbol == '-') {
        _state = _state.copyWith(expression: '-', displayValue: '-');
        notifyListeners();
      }
      return;
    }

    final lastChar = _state.expression[_state.expression.length - 1];
    if (lastChar == '+' || lastChar == '-' || lastChar == '×' || lastChar == '÷') {
      // Replace operator
      final newExpr = _state.expression.substring(0, _state.expression.length - 1) + symbol;
      _state = _state.copyWith(
        expression: newExpr,
        displayValue: newExpr,
        error: null,
        hasEvaluated: false,
      );
      notifyListeners();
      return;
    }

    final newExpr = _state.expression + symbol;
    _state = _state.copyWith(
      expression: newExpr,
      displayValue: newExpr,
      error: null,
      hasEvaluated: false,
    );
    notifyListeners();
  }

  void backspace() {
    if (_state.hasEvaluated) {
      clear();
      return;
    }

    if (_state.expression.isEmpty) return;

    final newExpr = _state.expression.substring(0, _state.expression.length - 1);
    _state = _state.copyWith(
      expression: newExpr,
      displayValue: newExpr.isEmpty ? '0' : newExpr,
      error: null,
    );
    notifyListeners();
  }

  void clear() {
    _state = CalculatorState.initial();
    notifyListeners();
  }

  CalculatorResult evaluate() {
    if (_state.expression.isEmpty) {
      return const CalculatorResult.failure(CalculatorError.emptyExpression);
    }

    final result = CalculatorEngine.evaluate(_state.expression);
    if (result.isSuccess) {
      if (result.value! < 0) {
        _state = _state.copyWith(error: CalculatorError.negativeResult);
        notifyListeners();
        return const CalculatorResult.failure(CalculatorError.negativeResult);
      }

      _state = _state.copyWith(
        expression: result.formattedResult,
        displayValue: result.formattedResult,
        numericValue: result.value,
        hasEvaluated: true,
        error: null,
      );
    } else {
      _state = _state.copyWith(error: result.error);
    }
    notifyListeners();
    return result;
  }
}
