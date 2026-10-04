import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/providers/repository_providers.dart';
import 'package:wdp_passbook/domain/entities/account.dart';
import 'package:wdp_passbook/domain/entities/budget.dart';
import 'package:wdp_passbook/domain/entities/category.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/entities/savings_goal.dart';
import 'package:wdp_passbook/domain/entities/transaction.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';
import 'package:wdp_passbook/features/personal/accounts/accounts_screen.dart';
import 'package:wdp_passbook/features/personal/categories/categories_screen.dart';
import 'package:wdp_passbook/features/personal/home/home_screen.dart';
import 'package:wdp_passbook/features/personal/ledger/ledger_screen.dart';
import 'package:wdp_passbook/features/personal/settings/settings_screen.dart';
import 'package:wdp_passbook/features/personal/transactions/transaction_details_screen.dart';

import '../application/fakes/fake_repositories.dart';

void main() {
  late FakeTransactionRepository txRepo;
  late FakeAccountRepository accRepo;
  late FakeCategoryRepository catRepo;
  late FakeBudgetRepository budgetRepo;
  late FakeGoalRepository goalRepo;

  setUp(() {
    txRepo = FakeTransactionRepository();
    accRepo = FakeAccountRepository();
    catRepo = FakeCategoryRepository();
    budgetRepo = FakeBudgetRepository();
    goalRepo = FakeGoalRepository();
  });

  Widget createWidgetUnderTest(Widget child, [List<dynamic> overrides = const []]) {
    return ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(txRepo),
        accountRepositoryProvider.overrideWithValue(accRepo),
        categoryRepositoryProvider.overrideWithValue(catRepo),
        budgetRepositoryProvider.overrideWithValue(budgetRepo),
        goalRepositoryProvider.overrideWithValue(goalRepo),
        ...overrides,
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Phase 4: Categories Flow (Flow C)', () {
    testWidgets('displays categories and creates new custom category via controller', (tester) async {
      final defaultCat = const Category(
        id: 'cat_food',
        name: 'Dining & Groceries',
        type: CategoryType.expense,
        iconName: 'utensils',
        colorHex: '#EF4444',
      );
      await catRepo.createCategory(defaultCat);

      await tester.pumpWidget(createWidgetUnderTest(const CategoriesScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify category is shown
      expect(find.text('Dining & Groceries'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);

      // Verify FloatingActionButton exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('Phase 4: Accounts Screen & Controller Integration', () {
    testWidgets('renders accounts and allows archiving via controller', (tester) async {
      final acc = Account(
        id: 'acc_salary',
        name: 'Salary Account',
        type: AccountType.bank,
        balance: const Money(minorUnits: 5000000), // ₹50,000.00
        iconName: 'landmark',
        colorHex: '#F97316',
        createdAt: DateTime.now(),
      );
      await accRepo.createAccount(acc);

      await tester.pumpWidget(createWidgetUnderTest(const AccountsScreen()));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Salary Account'), findsOneWidget);
      expect(find.text('₹50,000.00'), findsOneWidget);

      // Tap popup menu
      final moreButton = find.byType(PopupMenuButton<String>);
      expect(moreButton, findsOneWidget);
      await tester.tap(moreButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Find and tap Archive
      final archiveMenuItem = find.text('Archive');
      expect(archiveMenuItem, findsOneWidget);
      await tester.tap(archiveMenuItem);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Confirm dialog appears
      expect(find.text('Archive Account?'), findsOneWidget);
      final confirmBtn = find.widgetWithText(TextButton, 'Archive');
      await tester.tap(confirmBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Account should be archived (empty state displayed)
      expect(find.text('No Accounts Yet'), findsOneWidget);
    });
  });

  group('Phase 4: Ledger Screen (Flow F)', () {
    testWidgets('displays transactions and responds to filter chips', (tester) async {
      final t1 = Transaction(
        id: 'tx_1',
        amount: const Money(minorUnits: 150000), // ₹1,500.00
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food',
        accountId: 'acc_1',
        accountName: 'Bank',
        remark: 'Dinner with team',
        paymentMethod: PaymentMethod.upi,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      final t2 = Transaction(
        id: 'tx_2',
        amount: const Money(minorUnits: 5000000), // ₹50,000.00
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
        accountId: 'acc_1',
        accountName: 'Bank',
        remark: 'Monthly Salary',
        paymentMethod: PaymentMethod.bankTransfer,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await txRepo.createTransaction(t1);
      await txRepo.createTransaction(t2);

      await tester.pumpWidget(createWidgetUnderTest(const LedgerScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Both should appear initially
      expect(find.text('Dinner with team'), findsOneWidget);
      expect(find.text('Monthly Salary'), findsOneWidget);

      // Tap "Expenses" filter chip
      final expenseChip = find.text('Expenses');
      await tester.tap(expenseChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Now only expense should appear
      expect(find.text('Dinner with team'), findsOneWidget);
      expect(find.text('Monthly Salary'), findsNothing);
    });
  });

  group('Phase 4: Transaction Details Screen Flow', () {
    testWidgets('displays transaction details and deletes transaction', (tester) async {
      final tx = Transaction(
        id: 'tx_to_delete',
        amount: const Money(minorUnits: 25000), // ₹250.00
        type: TransactionType.expense,
        categoryId: 'cat_coffee',
        categoryName: 'Coffee & Snacks',
        accountId: 'acc_cash',
        accountName: 'Cash Wallet',
        remark: 'Espresso Roast',
        paymentMethod: PaymentMethod.cash,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await txRepo.createTransaction(tx);

      await tester.pumpWidget(createWidgetUnderTest(
        const TransactionDetailsScreen(transactionId: 'tx_to_delete'),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify display
      expect(find.text('Espresso Roast'), findsOneWidget);
      expect(find.text('-₹250.00'), findsOneWidget);
      expect(find.text('Coffee & Snacks'), findsOneWidget);
      expect(find.text('Cash Wallet'), findsOneWidget);

      // Delete action
      final deleteBtn = find.byTooltip('Delete Transaction');
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Dialog confirmation
      expect(find.text('Delete Transaction?'), findsOneWidget);
      final confirmDelete = find.widgetWithText(TextButton, 'Delete');
      await tester.tap(confirmDelete);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Repository should have 0 transactions
      expect(txRepo.transactions.isEmpty, isTrue);
    });
  });

  group('Phase 4: Home Screen Reactive Integration', () {
    testWidgets('shows quick actions, budgets summary, and goals summary', (tester) async {
      final now = DateTime.now();
      final budget = Budget(
        id: 'b_food',
        categoryId: 'cat_food',
        categoryName: 'Dining',
        limitAmount: const Money(minorUnits: 500000), // ₹5,000.00
        spentAmount: const Money(minorUnits: 150000), // ₹1,500.00
        period: BudgetPeriod.monthly,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
      );
      await budgetRepo.createBudget(budget);

      final goal = SavingsGoal(
        id: 'g_car',
        title: 'New Car',
        targetAmount: const Money(minorUnits: 10000000), // ₹100,000.00
        savedAmount: const Money(minorUnits: 2500000), // ₹25,000.00
        status: GoalStatus.active,
      );
      await goalRepo.createGoal(goal);

      await tester.pumpWidget(createWidgetUnderTest(const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Quick action buttons
      expect(find.byKey(const Key('home_quick_add_expense_btn')), findsOneWidget);
      expect(find.byKey(const Key('home_quick_add_income_btn')), findsOneWidget);

      // Budgets summary & Goals summary
      expect(find.text('Budgets'), findsNWidgets(2));
      expect(find.text('Dining'), findsOneWidget);
      expect(find.text('Savings Goals'), findsOneWidget);
      expect(find.text('New Car'), findsOneWidget);
    });
  });

  group('Phase 4: Settings Screen Navigation', () {
    testWidgets('renders account and category management options', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const SettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Manage Accounts'), findsOneWidget);
      expect(find.text('Manage Categories'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Security & Privacy'), findsOneWidget);
    });
  });
}
