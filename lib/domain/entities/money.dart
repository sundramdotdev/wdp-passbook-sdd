import 'package:intl/intl.dart';
import '../../core/errors/exceptions.dart';

/// Immutable domain value object representing money in integer minor units (e.g., Paisa / Cents).
/// Financial calculations MUST NOT use floating-point numbers.
class Money implements Comparable<Money> {
  /// Amount stored strictly in integer minor units (e.g., 10050 = ₹100.50).
  final int minorUnits;

  /// ISO 4217 Currency Code (e.g., 'INR', 'USD').
  final String currencyCode;

  const Money({
    required this.minorUnits,
    this.currencyCode = 'INR',
  });

  /// Const constructor creating a zero Money instance.
  const Money.zero([this.currencyCode = 'INR']) : minorUnits = 0;

  /// Const constructor creating Money from integer minor units.
  const Money.fromMinor(this.minorUnits, [this.currencyCode = 'INR']);

  /// Factory creating Money from major units (e.g., 100.50 -> 10050).
  /// Multiplies by 100 and rounds to the nearest integer minor unit.
  factory Money.fromMajor(double majorUnits, [String currencyCode = 'INR']) {
    return Money(
      minorUnits: (majorUnits * 100).round(),
      currencyCode: currencyCode,
    );
  }

  /// Helper to convert minor units to major double strictly for display/formatting.
  double get toMajor => minorUnits / 100.0;

  bool get isZero => minorUnits == 0;
  bool get isPositive => minorUnits > 0;
  bool get isNegative => minorUnits < 0;

  /// Returns the absolute value of Money.
  Money abs() => Money(
        minorUnits: minorUnits.abs(),
        currencyCode: currencyCode,
      );

  void _assertSameCurrency(Money other) {
    if (currencyCode != other.currencyCode) {
      throw CurrencyMismatchException(currencyCode, other.currencyCode);
    }
  }

  /// Addition: Requires matching currencies, otherwise throws [CurrencyMismatchException].
  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(
      minorUnits: minorUnits + other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  /// Subtraction: Requires matching currencies, otherwise throws [CurrencyMismatchException].
  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(
      minorUnits: minorUnits - other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  /// Integer scalar multiplication.
  Money operator *(int factor) {
    return Money(
      minorUnits: minorUnits * factor,
      currencyCode: currencyCode,
    );
  }

  /// Safe percentage calculation returning integer minor units.
  Money percentage(int percent) {
    return Money(
      minorUnits: ((minorUnits * percent) ~/ 100),
      currencyCode: currencyCode,
    );
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;

  /// Pure string formatting for display.
  String format({bool includeSymbol = true}) {
    final symbol = currencyCode == 'INR'
        ? '₹'
        : currencyCode == 'USD'
            ? '\$'
            : '$currencyCode ';
    final formatter = NumberFormat.currency(
      symbol: includeSymbol ? symbol : '',
      decimalDigits: 2,
      locale: currencyCode == 'INR' ? 'en_IN' : 'en_US',
    );
    return formatter.format(toMajor);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          minorUnits == other.minorUnits &&
          currencyCode == other.currencyCode;

  @override
  int get hashCode => minorUnits.hashCode ^ currencyCode.hashCode;

  @override
  String toString() => format();
}
