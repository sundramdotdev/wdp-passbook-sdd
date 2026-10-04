import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/enums/personal_enums.dart';
import '../../domain/repositories/personal_repositories.dart';
import '../commands/budget_commands.dart';

/// Orchestrates validated creation of category monthly budgets.
class CreateBudgetUseCase {
  final BudgetRepository budgetRepository;
  final CategoryRepository categoryRepository;

  const CreateBudgetUseCase({
    required this.budgetRepository,
    required this.categoryRepository,
  });

  Future<Result<Budget>> call(CreateBudgetCommand command) async {
    if (command.categoryId.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Category must be selected for budget.'));
    }

    if (command.limitAmount.minorUnits <= 0) {
      return Result.failure(const ValidationFailure('Budget limit amount must be strictly greater than zero.'));
    }

    // Verify category exists and is an EXPENSE category
    final categoryRes = await categoryRepository.getCategoryById(command.categoryId);
    if (categoryRes.isFailure) return Result.failure(categoryRes.failureOrNull!);
    final category = categoryRes.valueOrNull;
    if (category == null) {
      return Result.failure(NotFoundFailure('Category with ID ${command.categoryId} not found.'));
    }

    if (category.type != CategoryType.expense) {
      return Result.failure(const ValidationFailure('Budgets can only be set for Expense categories.'));
    }

    // Compute calendar month range accurately (handles 28, 29, 30, 31 days)
    final range = BudgetDateRange.currentMonthRange(command.referenceDate);

    // Check if a budget already exists for this category in the current month
    final existingBudgetsRes = await budgetRepository.getBudgets();
    if (existingBudgetsRes.isSuccess) {
      final duplicates = existingBudgetsRes.valueOrNull!.where(
        (b) => b.categoryId == command.categoryId &&
               b.startDate.year == range.start.year &&
               b.startDate.month == range.start.month,
      );
      if (duplicates.isNotEmpty) {
        return Result.failure(ValidationFailure('A budget for "${category.name}" already exists for this month.'));
      }
    }

    final budget = Budget(
      id: const Uuid().v4(),
      categoryId: category.id,
      categoryName: category.name,
      limitAmount: command.limitAmount,
      spentAmount: Money.zero(command.limitAmount.currencyCode),
      period: command.period,
      startDate: range.start,
      endDate: range.end,
    );

    return budgetRepository.createBudget(budget);
  }
}

/// Orchestrates deletion of an existing budget.
class DeleteBudgetUseCase {
  final BudgetRepository budgetRepository;

  const DeleteBudgetUseCase(this.budgetRepository);

  Future<Result<void>> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Budget ID cannot be empty.'));
    }
    return budgetRepository.deleteBudget(id);
  }
}

/// Derives budget spending purely from transaction records.
/// Invariants:
/// - Only Expense transactions affect budgets.
/// - Income is strictly ignored.
/// - Transfers are strictly ignored.
/// - Only transactions matching categoryId and date range are included.
class CalculateBudgetSpendingUseCase {
  const CalculateBudgetSpendingUseCase();

  CalculatedBudget call({
    required Budget budget,
    required List<Transaction> transactions,
  }) {
    int spentMinorUnits = 0;

    for (final t in transactions) {
      // 1. Must be Expense
      if (t.type != TransactionType.expense) continue;

      // 2. Must match category
      if (t.categoryId != budget.categoryId) continue;

      // 3. Must be within date range
      if (t.date.isBefore(budget.startDate) || t.date.isAfter(budget.endDate)) continue;

      spentMinorUnits += t.amount.minorUnits;
    }

    final spentMoney = Money(
      minorUnits: spentMinorUnits,
      currencyCode: budget.limitAmount.currencyCode,
    );

    return CalculatedBudget(
      budget: budget,
      spentAmount: spentMoney,
    );
  }
}
