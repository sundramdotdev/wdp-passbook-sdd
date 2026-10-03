import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/core/calculator/calculator_controller.dart';
import 'package:wdp_passbook/core/calculator/calculator_engine.dart';
import 'package:wdp_passbook/core/calculator/calculator_models.dart';

void main() {
  group('CalculatorEngine Pure Logic Tests', () {
    test('Basic addition', () {
      final res = CalculatorEngine.evaluate('100 + 50');
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(150.0));
      expect(res.formattedValue, equals('150'));
    });

    test('Basic subtraction', () {
      final res = CalculatorEngine.evaluate('250 - 75');
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(175.0));
    });

    test('Basic multiplication', () {
      final res = CalculatorEngine.evaluate('12 × 4');
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(48.0));
    });

    test('Basic division', () {
      final res = CalculatorEngine.evaluate('100 ÷ 4');
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(25.0));
    });

    test('Standard operator precedence: multiplication before addition (100 + 50 × 2 = 200)', () {
      final res = CalculatorEngine.evaluate('100 + 50 × 2');
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(200.0));
      expect(res.formattedValue, equals('200'));
    });

    test('Standard operator precedence: division before subtraction (100 - 20 ÷ 4 = 95)', () {
      final res = CalculatorEngine.evaluate('100 - 20 ÷ 4');
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(95.0));
    });

    test('Complex mixed precedence: 50 + 10 × 3 - 20 ÷ 4 = 75', () {
      // 50 + 30 - 5 = 75
      final res = CalculatorEngine.evaluate('50 + 10 × 3 - 20 ÷ 4');
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(75.0));
    });

    test('Decimals handling: 0.50 + 1.25 = 1.75', () {
      final res = CalculatorEngine.evaluate('0.50 + 1.25');
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(1.75));
      expect(res.formattedValue, equals('1.75'));
    });

    test('Single number evaluation', () {
      final res = CalculatorEngine.evaluate('1234.56');
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(1234.56));
      expect(res.formattedValue, equals('1234.56'));
    });

    test('Division by zero returns divisionByZero error', () {
      final res = CalculatorEngine.evaluate('500 ÷ 0');
      expect(res.isSuccess, isFalse);
      expect(res.error, equals(CalculatorError.divisionByZero));
    });

    test('Empty expression returns emptyExpression error', () {
      final res = CalculatorEngine.evaluate('');
      expect(res.isSuccess, isFalse);
      expect(res.error, equals(CalculatorError.emptyExpression));
    });

    test('Negative result is rejected for financial entry', () {
      final res = CalculatorEngine.evaluate('50 - 100');
      expect(res.isSuccess, isFalse);
      expect(res.error, equals(CalculatorError.negativeResult));
    });

    test('Expression ending with operator evaluates up to that operator or reports error', () {
      final res = CalculatorEngine.evaluate('100 +');
      // In financial calculator, trailing operator can be stripped or evaluated cleanly
      expect(res.isSuccess, isTrue);
      expect(res.value, equals(100.0));
    });
  });

  group('CalculatorController State Management Tests', () {
    late CalculatorController controller;

    setUp(() {
      controller = CalculatorController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state is empty/zero', () {
      expect(controller.state.expression, equals(''));
      expect(controller.state.displayValue, equals('0'));
    });

    test('Input digits sequentially', () {
      controller.inputDigit('1');
      controller.inputDigit('5');
      controller.inputDigit('0');
      expect(controller.state.expression, equals('150'));
      expect(controller.state.displayValue, equals('150'));
    });

    test('Input decimal and prevent multiple dots in same operand', () {
      controller.inputDigit('1');
      controller.inputDecimal();
      controller.inputDigit('5');
      controller.inputDecimal(); // Should be ignored
      expect(controller.state.expression, equals('1.5'));
    });

    test('Input operators without spaces', () {
      controller.inputDigit('1');
      controller.inputDigit('0');
      controller.inputOperator('+');
      controller.inputDigit('5');
      expect(controller.state.expression, equals('10+5'));
    });

    test('Replacing operator when another operator is tapped immediately', () {
      controller.inputDigit('1');
      controller.inputDigit('0');
      controller.inputOperator('+');
      controller.inputOperator('×');
      expect(controller.state.expression, equals('10×'));
    });

    test('Backspace removes last character', () {
      controller.inputDigit('1');
      controller.inputDigit('2');
      controller.inputDigit('3');
      controller.backspace();
      expect(controller.state.expression, equals('12'));
    });

    test('Backspace removes operator', () {
      controller.inputDigit('1');
      controller.inputDigit('0');
      controller.inputOperator('+');
      expect(controller.state.expression, equals('10+'));
      controller.backspace();
      expect(controller.state.expression, equals('10'));
    });

    test('Clear resets calculator', () {
      controller.inputDigit('9');
      controller.inputDigit('9');
      controller.clear();
      expect(controller.state.expression, equals(''));
      expect(controller.state.displayValue, equals('0'));
    });

    test('Evaluate calculates result and updates display', () {
      controller.inputDigit('2');
      controller.inputDigit('0');
      controller.inputOperator('×');
      controller.inputDigit('5');
      controller.evaluate();
      expect(controller.state.expression, equals('100'));
      expect(controller.state.displayValue, equals('100'));
      expect(controller.state.error, isNull);
    });

    test('Evaluate division by zero sets error state', () {
      controller.inputDigit('1');
      controller.inputDigit('0');
      controller.inputOperator('÷');
      controller.inputDigit('0');
      controller.evaluate();
      expect(controller.state.error, equals(CalculatorError.divisionByZero));
    });
  });
}
