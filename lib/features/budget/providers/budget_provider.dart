import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/budget.dart';
import '../../../data/providers/repositories_provider.dart';
import '../../../features/passbook/providers/passbook_provider.dart';

class BudgetProgress {
  final Budget budget;
  final double spent;
  final double remaining;
  final double progressPercent;

  BudgetProgress({
    required this.budget,
    required this.spent,
  })  : remaining = budget.limitAmount - spent,
        progressPercent = budget.limitAmount > 0 ? (spent / budget.limitAmount).clamp(0.0, 1.0) : 0.0;
}

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchBudgets();
});

final budgetProgressProvider = Provider<List<BudgetProgress>>((ref) {
  final budgets = ref.watch(budgetsProvider).value ?? [];
  final transactions = ref.watch(transactionsProvider).value ?? [];

  final now = DateTime.now();
  final currentMonthExpenses = transactions.where((t) => 
    !t.isCredit && 
    t.date.year == now.year && 
    t.date.month == now.month
  ).toList();

  return budgets.map((budget) {
    double spent = 0;
    if (budget.categoryId == null || budget.categoryId!.isEmpty) {
      // Overall budget
      spent = currentMonthExpenses.fold(0.0, (sum, t) => sum + t.amount);
    } else {
      // Category specific budget
      spent = currentMonthExpenses
          .where((t) => t.categoryId == budget.categoryId)
          .fold(0.0, (sum, t) => sum + t.amount);
    }
    return BudgetProgress(budget: budget, spent: spent);
  }).toList();
});
