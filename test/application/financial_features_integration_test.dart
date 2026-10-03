import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/commands/account_commands.dart';
import 'package:wdp_passbook/application/commands/budget_commands.dart';
import 'package:wdp_passbook/application/commands/category_commands.dart';
import 'package:wdp_passbook/application/commands/goal_commands.dart';
import 'package:wdp_passbook/application/commands/transaction_commands.dart';
import 'package:wdp_passbook/application/usecases/account_usecases.dart';
import 'package:wdp_passbook/application/usecases/budget_usecases.dart';
import 'package:wdp_passbook/application/usecases/category_usecases.dart';
import 'package:wdp_passbook/application/usecases/goal_usecases.dart';
import 'package:wdp_passbook/application/usecases/transaction_usecases.dart';
import 'package:wdp_passbook/core/calculator/calculator_engine.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

import 'fakes/fake_repositories.dart';

void main() {
  group('Comprehensive Financial Features Integration Test', () {
    test('End-to-end integration: Categories + Budgets + Goals + Calculator + Transactions', () async {
      // 1. Data Layer Setup (Fake Repositories)
      final accountRepo = FakeAccountRepository();
      final categoryRepo = FakeCategoryRepository();
      final transactionRepo = FakeTransactionRepository();
      final budgetRepo = FakeBudgetRepository();
      final goalRepo = FakeGoalRepository();

      // 2. Application Layer Setup (Use Cases)
      final createAccount = CreateAccountUseCase(accountRepo);
      final createCategory = CreateCategoryUseCase(categoryRepo);
      final createExpense = CreateExpenseUseCase(
        transactionRepository: transactionRepo,
        accountRepository: accountRepo,
        categoryRepository: categoryRepo,
      );
      final createBudget = CreateBudgetUseCase(
        budgetRepository: budgetRepo,
        categoryRepository: categoryRepo,
      );
      const calculateBudgetSpending = CalculateBudgetSpendingUseCase();
      final createGoal = CreateGoalUseCase(goalRepo);
      final addGoalMoney = AddGoalMoneyUseCase(goalRepo);
      final removeGoalMoney = RemoveGoalMoneyUseCase(goalRepo);

      // 3. Setup Account
      final accRes = await createAccount(
        const CreateAccountCommand(
          name: 'Main Salary Account',
          type: AccountType.bank,
          initialBalance: Money(minorUnits: 50000000), // ₹5,00,000
        ),
      );
      expect(accRes.isSuccess, isTrue);
      final account = accRes.valueOrNull!;

      // 4. Feature 1: Category Management
      // Create custom Expense category
      final catRes = await createCategory(
        const CreateCategoryCommand(
          name: 'Coffee & Snacks',
          type: CategoryType.expense,
          iconName: 'coffee',
          colorHex: '#795548',
        ),
      );
      expect(catRes.isSuccess, isTrue);
      final category = catRes.valueOrNull!;

      // 5. Feature 2: Budget Creation
      final testMonth = DateTime(2026, 9, 1);
      final budgetRes = await createBudget(
        CreateBudgetCommand(
          categoryId: category.id,
          limitAmount: const Money(minorUnits: 500000), // ₹5,000 budget
          period: BudgetPeriod.monthly,
          referenceDate: testMonth,
        ),
      );
      expect(budgetRes.isSuccess, isTrue);
      final budget = budgetRes.valueOrNull!;
      expect(budget.categoryName, equals('Coffee & Snacks'));

      // 6. Feature 3: Financial Calculator
      // User inputs arithmetic: "120 + 80 × 2" (Standard precedence: 80×2=160, 120+160=280)
      final calcResult = CalculatorEngine.evaluate('120 + 80 × 2');
      expect(calcResult.isSuccess, isTrue);
      expect(calcResult.value, equals(280.0));
      expect(calcResult.formattedValue, equals('280'));

      // Convert calculated value to domain Money object (never float math in domain)
      final calculatedExpenseMoney = Money.fromMajor(calcResult.value!);
      expect(calculatedExpenseMoney.minorUnits, equals(28000)); // ₹280.00 = 28000 minorUnits

      // 7. Transaction Entry using calculated amount and custom category
      final txRes = await createExpense(
        CreateExpenseCommand(
          amount: calculatedExpenseMoney,
          accountId: account.id,
          categoryId: category.id,
          remark: 'Team coffee and croissants',
          paymentMethod: PaymentMethod.upi,
          date: DateTime(2026, 9, 10, 15, 30),
        ),
      );
      expect(txRes.isSuccess, isTrue);

      // 8. Dynamic Budget Calculation Update
      final allTx = (await transactionRepo.getTransactions()).valueOrNull!;
      final calculatedBudget = calculateBudgetSpending(
        budget: budget,
        transactions: allTx,
      );

      expect(calculatedBudget.spentAmount.minorUnits, equals(28000)); // ₹280
      expect(calculatedBudget.remainingAmount.minorUnits, equals(472000)); // ₹4,720
      expect(calculatedBudget.progress, closeTo(0.056, 0.001));
      expect(calculatedBudget.isUnderBudget, isTrue);
      expect(calculatedBudget.isNearLimit, isFalse);
      expect(calculatedBudget.isExceeded, isFalse);

      // 9. Feature 4: Savings Goals Management
      final goalRes = await createGoal(
        const CreateGoalCommand(
          title: 'MacBook Pro',
          targetAmount: Money(minorUnits: 15000000), // ₹1,50,000
          iconName: 'laptop',
        ),
      );
      expect(goalRes.isSuccess, isTrue);
      final goal = goalRes.valueOrNull!;
      expect(goal.savedAmount.minorUnits, equals(0));
      expect(goal.status, equals(GoalStatus.active));

      // Calculate deposit with calculator: "25000 + 50000" = 75000
      final depositCalc = CalculatorEngine.evaluate('25000 + 50000');
      expect(depositCalc.isSuccess, isTrue);
      final depositMoney = Money.fromMajor(depositCalc.value!);

      // Add money to goal
      final addDepositRes = await addGoalMoney(
        AddGoalMoneyCommand(
          goalId: goal.id,
          amount: depositMoney,
          note: 'Bonus deposit',
        ),
      );
      expect(addDepositRes.isSuccess, isTrue);
      final goalAfterDeposit = addDepositRes.valueOrNull!;
      expect(goalAfterDeposit.savedAmount.minorUnits, equals(7500000)); // ₹75,000
      expect(goalAfterDeposit.progressPercentage, equals(0.5)); // 50%
      expect(goalAfterDeposit.isAchieved, isFalse);
      expect(goalAfterDeposit.isCompleted, isFalse);

      // Withdraw ₹15,000
      final withdrawRes = await removeGoalMoney(
        RemoveGoalMoneyCommand(
          goalId: goal.id,
          amount: const Money(minorUnits: 1500000),
          note: 'Partial withdrawal for repair',
        ),
      );
      expect(withdrawRes.isSuccess, isTrue);
      final goalAfterWithdraw = withdrawRes.valueOrNull!;
      expect(goalAfterWithdraw.savedAmount.minorUnits, equals(6000000)); // ₹60,000
      expect(goalAfterWithdraw.progressPercentage, equals(0.4)); // 40%

      // Complete the goal: add ₹90,000
      final completeRes = await addGoalMoney(
        AddGoalMoneyCommand(
          goalId: goal.id,
          amount: const Money(minorUnits: 9000000),
          note: 'Final savings contribution',
        ),
      );
      expect(completeRes.isSuccess, isTrue);
      final completedGoal = completeRes.valueOrNull!;
      expect(completedGoal.savedAmount.minorUnits, equals(15000000)); // ₹1,50,000
      expect(completedGoal.progressPercentage, equals(1.0)); // Clamped 1.0
      expect(completedGoal.isAchieved, isTrue);
      expect(completedGoal.status, equals(GoalStatus.completed));
      expect(completedGoal.isCompleted, isTrue);
    });
  });
}
