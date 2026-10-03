import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/commands/budget_commands.dart';
import 'package:wdp_passbook/application/usecases/budget_usecases.dart';
import 'package:wdp_passbook/core/errors/failures.dart';
import 'package:wdp_passbook/domain/entities/category.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/entities/transaction.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

import '../fakes/fake_repositories.dart';

void main() {
  group('Budget Use Cases & Dynamic Spending Calculation', () {
    late FakeBudgetRepository budgetRepo;
    late FakeCategoryRepository categoryRepo;
    late FakeTransactionRepository transactionRepo;

    late CreateBudgetUseCase createBudgetUseCase;
    late DeleteBudgetUseCase deleteBudgetUseCase;
    const calculateBudgetSpendingUseCase = CalculateBudgetSpendingUseCase();

    final testMonth = DateTime(2026, 9, 15);

    setUp(() async {
      budgetRepo = FakeBudgetRepository();
      categoryRepo = FakeCategoryRepository();
      transactionRepo = FakeTransactionRepository();

      createBudgetUseCase = CreateBudgetUseCase(
        budgetRepository: budgetRepo,
        categoryRepository: categoryRepo,
      );
      deleteBudgetUseCase = DeleteBudgetUseCase(budgetRepo);

      // Seed categories
      await categoryRepo.createCategory(
        Category(
          id: 'cat-dining',
          name: 'Food & Dining',
          type: CategoryType.expense,
          iconName: 'utensils',
          colorHex: '#FF5722',
        ),
      );
      await categoryRepo.createCategory(
        Category(
          id: 'cat-salary',
          name: 'Salary',
          type: CategoryType.income,
          iconName: 'briefcase',
          colorHex: '#4CAF50',
        ),
      );
    });

    test('Creates valid monthly budget for Expense category', () async {
      final res = await createBudgetUseCase(
        CreateBudgetCommand(
          categoryId: 'cat-dining',
          limitAmount: const Money(minorUnits: 1000000), // ₹10,000
          period: BudgetPeriod.monthly,
          referenceDate: testMonth,
        ),
      );

      expect(res.isSuccess, isTrue);
      final budget = res.valueOrNull!;
      expect(budget.categoryName, equals('Food & Dining'));
      expect(budget.limitAmount.minorUnits, equals(1000000));
      expect(budget.startDate.day, equals(1));
      expect(budget.endDate.day, equals(30)); // Sept has 30 days
    });

    test('Rejects budget with zero or negative limit amount', () async {
      final res = await createBudgetUseCase(
        CreateBudgetCommand(
          categoryId: 'cat-dining',
          limitAmount: Money.zero(),
          referenceDate: testMonth,
        ),
      );

      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('Rejects budget for non-existent category', () async {
      final res = await createBudgetUseCase(
        CreateBudgetCommand(
          categoryId: 'non-existent-cat',
          limitAmount: const Money(minorUnits: 500000),
          referenceDate: testMonth,
        ),
      );

      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<NotFoundFailure>());
    });

    test('Rejects budget for Income category (budgets are expense-only)', () async {
      final res = await createBudgetUseCase(
        CreateBudgetCommand(
          categoryId: 'cat-salary',
          limitAmount: const Money(minorUnits: 500000),
          referenceDate: testMonth,
        ),
      );

      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('Derives spending strictly from Expense transactions, ignoring Income and Transfers', () async {
      // 1. Create Budget
      final budgetRes = await createBudgetUseCase(
        CreateBudgetCommand(
          categoryId: 'cat-dining',
          limitAmount: const Money(minorUnits: 1000000), // ₹10,000
          referenceDate: testMonth,
        ),
      );
      final budget = budgetRes.valueOrNull!;

      // 2. Add an Expense of ₹4,000 in September
      await transactionRepo.createTransaction(
        Transaction(
          id: 'tx-1',
          amount: const Money(minorUnits: 400000),
          accountId: 'acc-1',
          accountName: 'Bank',
          categoryId: 'cat-dining',
          categoryName: 'Food & Dining',
          type: TransactionType.expense,
          date: DateTime(2026, 9, 10),
          remark: 'Restaurant dinner',
          paymentMethod: PaymentMethod.upi,
          createdAt: DateTime.now(),
        ),
      );

      // 3. Add an Expense of ₹2,500 in September
      await transactionRepo.createTransaction(
        Transaction(
          id: 'tx-2',
          amount: const Money(minorUnits: 250000),
          accountId: 'acc-1',
          accountName: 'Bank',
          categoryId: 'cat-dining',
          categoryName: 'Food & Dining',
          type: TransactionType.expense,
          date: DateTime(2026, 9, 20),
          remark: 'Groceries',
          paymentMethod: PaymentMethod.upi,
          createdAt: DateTime.now(),
        ),
      );

      // 4. Add an Income transaction with cat-dining (Must be IGNORED by budget calculation)
      await transactionRepo.createTransaction(
        Transaction(
          id: 'tx-3',
          amount: const Money(minorUnits: 500000),
          accountId: 'acc-1',
          accountName: 'Bank',
          categoryId: 'cat-dining',
          categoryName: 'Food & Dining',
          type: TransactionType.income,
          date: DateTime(2026, 9, 21),
          remark: 'Refund',
          paymentMethod: PaymentMethod.upi,
          createdAt: DateTime.now(),
        ),
      );

      // 5. Add a Transfer transaction (Must be IGNORED by budget calculation)
      await transactionRepo.createTransaction(
        Transaction(
          id: 'tx-4',
          amount: const Money(minorUnits: 300000),
          accountId: 'acc-1',
          accountName: 'Bank',
          targetAccountId: 'acc-2',
          targetAccountName: 'Cash',
          categoryId: 'cat-dining',
          categoryName: 'Food & Dining',
          type: TransactionType.transfer,
          date: DateTime(2026, 9, 22),
          remark: 'Transfer',
          paymentMethod: PaymentMethod.bankTransfer,
          createdAt: DateTime.now(),
        ),
      );

      // 6. Add an Expense outside the month (August) (Must be IGNORED)
      await transactionRepo.createTransaction(
        Transaction(
          id: 'tx-5',
          amount: const Money(minorUnits: 500000),
          accountId: 'acc-1',
          accountName: 'Bank',
          categoryId: 'cat-dining',
          categoryName: 'Food & Dining',
          type: TransactionType.expense,
          date: DateTime(2026, 8, 25),
          remark: 'August Dinner',
          paymentMethod: PaymentMethod.upi,
          createdAt: DateTime.now(),
        ),
      );

      // 7. Calculate spending for budget
      final allTx = (await transactionRepo.getTransactions()).valueOrNull!;
      final calculated = calculateBudgetSpendingUseCase(
        budget: budget,
        transactions: allTx,
      );

      // Total spent = 4,000 + 2,500 = ₹6,500 (650,000 minorUnits)
      expect(calculated.spentAmount.minorUnits, equals(650000));
      expect(calculated.remainingAmount.minorUnits, equals(350000));
      expect(calculated.usagePercentage, equals(65.0));
      expect(calculated.isUnderBudget, isTrue);
      expect(calculated.isNearLimit, isFalse);
      expect(calculated.isExceeded, isFalse);
    });

    test('Budget status dynamically transitions: under -> near limit -> exceeded', () async {
      final budgetRes = await createBudgetUseCase(
        CreateBudgetCommand(
          categoryId: 'cat-dining',
          limitAmount: const Money(minorUnits: 1000000), // ₹10,000
          referenceDate: testMonth,
        ),
      );
      final budget = budgetRes.valueOrNull!;

      // 1. Initial spending: ₹5,000 (50%) -> Under budget
      await transactionRepo.createTransaction(
        Transaction(
          id: 't-1',
          amount: const Money(minorUnits: 500000),
          accountId: 'acc-1',
          accountName: 'Bank',
          categoryId: 'cat-dining',
          categoryName: 'Food & Dining',
          type: TransactionType.expense,
          date: DateTime(2026, 9, 5),
          remark: 'Groceries',
          paymentMethod: PaymentMethod.upi,
          createdAt: DateTime.now(),
        ),
      );

      var txList = (await transactionRepo.getTransactions()).valueOrNull!;
      var calc = calculateBudgetSpendingUseCase(budget: budget, transactions: txList);
      expect(calc.isUnderBudget, isTrue);
      expect(calc.isNearLimit, isFalse);
      expect(calc.isExceeded, isFalse);

      // 2. Additional spending: ₹3,500 (total ₹8,500, 85%) -> Near limit
      await transactionRepo.createTransaction(
        Transaction(
          id: 't-2',
          amount: const Money(minorUnits: 350000),
          accountId: 'acc-1',
          accountName: 'Bank',
          categoryId: 'cat-dining',
          categoryName: 'Food & Dining',
          type: TransactionType.expense,
          date: DateTime(2026, 9, 15),
          remark: 'Dinner',
          paymentMethod: PaymentMethod.upi,
          createdAt: DateTime.now(),
        ),
      );

      txList = (await transactionRepo.getTransactions()).valueOrNull!;
      calc = calculateBudgetSpendingUseCase(budget: budget, transactions: txList);
      expect(calc.isUnderBudget, isFalse);
      expect(calc.isNearLimit, isTrue);
      expect(calc.isExceeded, isFalse);

      // 3. Additional spending: ₹2,000 (total ₹10,500, 105%) -> Exceeded
      await transactionRepo.createTransaction(
        Transaction(
          id: 't-3',
          amount: const Money(minorUnits: 200000),
          accountId: 'acc-1',
          accountName: 'Bank',
          categoryId: 'cat-dining',
          categoryName: 'Food & Dining',
          type: TransactionType.expense,
          date: DateTime(2026, 9, 25),
          remark: 'Party',
          paymentMethod: PaymentMethod.upi,
          createdAt: DateTime.now(),
        ),
      );

      txList = (await transactionRepo.getTransactions()).valueOrNull!;
      calc = calculateBudgetSpendingUseCase(budget: budget, transactions: txList);
      expect(calc.isUnderBudget, isFalse);
      expect(calc.isNearLimit, isFalse);
      expect(calc.isExceeded, isTrue);
    });

    test('Deletes budget successfully', () async {
      final budgetRes = await createBudgetUseCase(
        CreateBudgetCommand(
          categoryId: 'cat-dining',
          limitAmount: const Money(minorUnits: 1000000),
          referenceDate: testMonth,
        ),
      );
      final budget = budgetRes.valueOrNull!;

      final delRes = await deleteBudgetUseCase(budget.id);
      expect(delRes.isSuccess, isTrue);

      final list = await budgetRepo.getBudgets();
      expect(list.valueOrNull!.isEmpty, isTrue);
    });
  });
}
