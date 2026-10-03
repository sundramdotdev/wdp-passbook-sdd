import 'money.dart';

class CategorySpending {
  final String categoryId;
  final String categoryName;
  final Money totalAmount;
  final double percentage;
  final String colorHex;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    required this.colorHex,
  });
}

class DailyCashFlow {
  final DateTime date;
  final Money income;
  final Money expense;

  const DailyCashFlow({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class AnalyticsSummary {
  final Money totalIncome;
  final Money totalExpense;
  final Money netCashFlow;
  final List<CategorySpending> categoryBreakdown;
  final List<DailyCashFlow> dailyCashFlows;
  final List<CategorySpending> topCategories;

  const AnalyticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
    required this.categoryBreakdown,
    required this.dailyCashFlows,
    required this.topCategories,
  });

  factory AnalyticsSummary.empty() => AnalyticsSummary(
        totalIncome: Money.zero(),
        totalExpense: Money.zero(),
        netCashFlow: Money.zero(),
        categoryBreakdown: const [],
        dailyCashFlows: const [],
        topCategories: const [],
      );
}

