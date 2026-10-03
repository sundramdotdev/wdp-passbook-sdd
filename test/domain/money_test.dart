import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/core/errors/exceptions.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/entities/budget.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

void main() {
  group('Money Value Object Core Invariants & Operations', () {
    test('instantiates with exact integer minor units (no float loss)', () {
      const zero = Money.zero();
      expect(zero.minorUnits, equals(0));
      expect(zero.isZero, isTrue);

      const onePaisa = Money(minorUnits: 1); // ₹0.01
      expect(onePaisa.minorUnits, equals(1));
      expect(onePaisa.toMajor, equals(0.01));

      const oneRupee = Money(minorUnits: 100); // ₹1.00
      expect(oneRupee.minorUnits, equals(100));
      expect(oneRupee.toMajor, equals(1.00));

      final hundredFifty = Money.fromMajor(100.50);
      expect(hundredFifty.minorUnits, equals(10050));
      expect(hundredFifty.toMajor, equals(100.50));
    });

    test('addition and subtraction enforce mathematical invariants', () {
      final m1 = Money(minorUnits: 10050); // ₹100.50
      final m2 = Money(minorUnits: 4950);  // ₹49.50

      final sum = m1 + m2;
      expect(sum.minorUnits, equals(15000));
      expect(sum.toMajor, equals(150.00));

      final diff = m1 - m2;
      expect(diff.minorUnits, equals(5100));
      expect(diff.toMajor, equals(51.00));

      final subZero = m2 - m1;
      expect(subZero.minorUnits, equals(-5100));
      expect(subZero.isNegative, isTrue);
      expect(subZero.abs().minorUnits, equals(5100));
    });

    test('scalar multiplication and percentage calculations', () {
      final m = Money(minorUnits: 5000); // ₹50.00
      final doubled = m * 2;
      expect(doubled.minorUnits, equals(10000));

      final pct = m.percentage(20); // 20% of ₹50.00 = ₹10.00
      expect(pct.minorUnits, equals(1000));
      expect(pct.toMajor, equals(10.00));
    });

    test('comparisons work reliably across instances', () {
      final a = Money(minorUnits: 100);
      final b = Money(minorUnits: 200);
      final a2 = Money(minorUnits: 100);

      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a <= b, isTrue);
      expect(b >= a, isTrue);
      expect(a == a2, isTrue);
      expect(a.compareTo(b), isNegative);
    });

    test('currency mismatch strictly throws CurrencyMismatchException', () {
      final inr = Money(minorUnits: 10000, currencyCode: 'INR');
      final usd = Money(minorUnits: 10000, currencyCode: 'USD');

      expect(() => inr + usd, throwsA(isA<CurrencyMismatchException>()));
      expect(() => inr - usd, throwsA(isA<CurrencyMismatchException>()));
      expect(() => inr.compareTo(usd), throwsA(isA<CurrencyMismatchException>()));
    });

    test('string formatting with and without currency symbol', () {
      final m = Money(minorUnits: 1234567); // ₹12,345.67
      expect(m.format(includeSymbol: false), equals('12,345.67'));
      expect(m.format(includeSymbol: true), contains('₹'));
      expect(m.format(includeSymbol: true), contains('12,345.67'));
    });
  });

  group('Budget Domain Invariant Tests', () {
    test('calculates budget remaining amount and usage percentage accurately', () {
      final budget = Budget(
        id: 'b1',
        categoryId: 'cat_food',
        categoryName: 'Food',
        limitAmount: Money.fromMajor(1000.0),
        spentAmount: Money.fromMajor(850.0),
        period: BudgetPeriod.monthly,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      expect(budget.remainingAmount.toMajor, equals(150.0));
      expect(budget.usagePercentage, equals(85.0));
      expect(budget.status, equals(BudgetStatus.approachingLimit));
    });

    test('detects budget exceeded state accurately', () {
      final budget = Budget(
        id: 'b2',
        categoryId: 'cat_fun',
        categoryName: 'Entertainment',
        limitAmount: Money.fromMajor(500.0),
        spentAmount: Money.fromMajor(550.0),
        period: BudgetPeriod.monthly,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      expect(budget.isExceeded, isTrue);
      expect(budget.status, equals(BudgetStatus.exceeded));
    });
  });
}
