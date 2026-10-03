import 'calculator_models.dart';

/// Pure calculation engine outside UI widgets.
/// Implements standard arithmetic precedence (multiplication and division before addition and subtraction).
class CalculatorEngine {
  const CalculatorEngine();

  /// Evaluates arithmetic string expression and returns a typed [CalculatorResult].
  static CalculatorResult evaluate(String expression) {
    return const CalculatorEngine().evaluateExpression(expression);
  }

  /// Evaluates arithmetic string expression and returns a typed [CalculatorResult].
  CalculatorResult evaluateExpression(String expression) {
    var sanitized = expression
        .replaceAll(' ', '')
        .replaceAll('*', '×')
        .replaceAll('/', '÷');

    if (sanitized.isEmpty) {
      return const CalculatorResult.failure(CalculatorError.emptyExpression);
    }

    // Strip trailing operator if present before evaluation (e.g. "250 +" -> "250")
    while (sanitized.isNotEmpty && _isOperator(sanitized[sanitized.length - 1])) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }

    if (sanitized.isEmpty) {
      return const CalculatorResult.failure(CalculatorError.emptyExpression);
    }

    // Tokenize
    final tokens = _tokenize(sanitized);
    if (tokens == null) {
      return const CalculatorResult.failure(CalculatorError.invalidExpression);
    }

    return _evaluateTokens(tokens);
  }

  bool _isOperator(String char) {
    return char == '+' || char == '-' || char == '×' || char == '÷';
  }

  List<String>? _tokenize(String expression) {
    final List<String> tokens = [];
    final StringBuffer currentNumber = StringBuffer();

    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];

      if (_isOperator(char)) {
        // Handle unary minus at start
        if (char == '-' && currentNumber.isEmpty && tokens.isEmpty) {
          currentNumber.write(char);
          continue;
        }

        if (currentNumber.isNotEmpty) {
          final numStr = currentNumber.toString();
          if (!_isValidNumber(numStr)) return null;
          tokens.add(numStr);
          currentNumber.clear();
        } else {
          // Two consecutive operators
          return null;
        }
        tokens.add(char);
      } else if ((char.compareTo('0') >= 0 && char.compareTo('9') <= 0) || char == '.') {
        currentNumber.write(char);
      } else {
        return null;
      }
    }

    if (currentNumber.isNotEmpty) {
      final numStr = currentNumber.toString();
      if (!_isValidNumber(numStr)) return null;
      tokens.add(numStr);
    }

    return tokens;
  }

  bool _isValidNumber(String s) {
    if (s == '.' || s == '-' || s == '-.') return false;
    final dotCount = s.split('.').length - 1;
    if (dotCount > 1) return false;
    return double.tryParse(s) != null;
  }

  CalculatorResult _evaluateTokens(List<String> tokens) {
    if (tokens.isEmpty) {
      return const CalculatorResult.failure(CalculatorError.emptyExpression);
    }

    // First pass: multiplication and division
    final List<String> afterMulDiv = [];
    int i = 0;

    while (i < tokens.length) {
      final token = tokens[i];
      if (token == '×' || token == '÷') {
        if (afterMulDiv.isEmpty || i + 1 >= tokens.length) {
          return const CalculatorResult.failure(CalculatorError.invalidExpression);
        }

        final prevStr = afterMulDiv.removeLast();
        final nextStr = tokens[i + 1];

        final prevVal = double.tryParse(prevStr);
        final nextVal = double.tryParse(nextStr);

        if (prevVal == null || nextVal == null) {
          return const CalculatorResult.failure(CalculatorError.invalidExpression);
        }

        if (token == '÷') {
          if (nextVal == 0.0) {
            return const CalculatorResult.failure(CalculatorError.divisionByZero);
          }
          final res = prevVal / nextVal;
          afterMulDiv.add(res.toString());
        } else {
          final res = prevVal * nextVal;
          afterMulDiv.add(res.toString());
        }
        i += 2;
      } else {
        afterMulDiv.add(token);
        i++;
      }
    }

    // Second pass: addition and subtraction
    if (afterMulDiv.isEmpty) {
      return const CalculatorResult.failure(CalculatorError.invalidExpression);
    }

    double result = double.tryParse(afterMulDiv[0]) ?? 0.0;
    int j = 1;

    while (j < afterMulDiv.length) {
      final op = afterMulDiv[j];
      if (j + 1 >= afterMulDiv.length) {
        return const CalculatorResult.failure(CalculatorError.invalidExpression);
      }
      final nextVal = double.tryParse(afterMulDiv[j + 1]);
      if (nextVal == null) {
        return const CalculatorResult.failure(CalculatorError.invalidExpression);
      }

      if (op == '+') {
        result += nextVal;
      } else if (op == '-') {
        result -= nextVal;
      } else {
        return const CalculatorResult.failure(CalculatorError.invalidExpression);
      }
      j += 2;
    }

    if (result < 0) {
      return const CalculatorResult.failure(CalculatorError.negativeResult);
    }

    // Format output
    final formatted = formatNumber(result);
    return CalculatorResult.success(result, formatted);
  }

  /// Cleanly formats a double value without redundant trailing decimal zeros.
  static String formatNumber(double val) {
    if (val.abs() >= 1e12) {
      return val.toString();
    }
    // Check if integer
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    // Round to 4 decimal places max and strip trailing zeros
    final fixed = val.toStringAsFixed(4);
    var trimmed = fixed;
    while (trimmed.endsWith('0')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('.')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
