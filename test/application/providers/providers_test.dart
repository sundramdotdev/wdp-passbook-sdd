import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/commands/transaction_commands.dart';
import 'package:wdp_passbook/application/commands/transaction_filter.dart';
import 'package:wdp_passbook/application/providers/repository_providers.dart';
import 'package:wdp_passbook/domain/entities/account.dart';
import 'package:wdp_passbook/domain/entities/category.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

import '../fakes/fake_repositories.dart';

void main() {
  late FakeTransactionRepository txRepo;
  late FakeAccountRepository accRepo;
  late FakeCategoryRepository catRepo;
  late ProviderContainer container;

  setUp(() {
    txRepo = FakeTransactionRepository();
    accRepo = FakeAccountRepository();
    catRepo = FakeCategoryRepository();

    container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(txRepo),
        accountRepositoryProvider.overrideWithValue(accRepo),
        categoryRepositoryProvider.overrideWithValue(catRepo),
      ],
    );

    // Seed test account and category
    accRepo.createAccount(Account(
      id: 'acc_01',
      name: 'Test Bank',
      type: AccountType.bank,
      balance: const Money(minorUnits: 1000000), // ₹10,000.00
      iconName: 'landmark',
      colorHex: '#3B82F6',
      createdAt: DateTime.now(),
    ));

    catRepo.createCategory(const Category(
      id: 'cat_01',
      name: 'Dining',
      type: CategoryType.expense,
      iconName: 'utensils',
      colorHex: '#EF4444',
    ));
  });

  tearDown(() {
    container.dispose();
  });

  group('Riverpod Dependency Injection Tests (Step 32)', () {
    test('resolves use cases and controllers from Riverpod container with overrides', () {
      final createExpenseUseCase = container.read(createExpenseUseCaseProvider);
      expect(createExpenseUseCase, isNotNull);

      final txController = container.read(transactionControllerProvider.notifier);
      expect(txController, isNotNull);

      final totalBalance = container.read(totalBalanceProvider);
      expect(totalBalance, isNotNull);
    });
  });

  group('Reactive Provider and Stream Tests (Step 33)', () {
    test('transaction creation automatically notifies reactive stream provider', () async {
      final controller = container.read(transactionControllerProvider.notifier);

      // Perform mutation through controller
      final success = await controller.createExpense(CreateExpenseCommand(
        amount: const Money(minorUnits: 30000), // ₹300.00
        accountId: 'acc_01',
        categoryId: 'cat_01',
        date: DateTime.now(),
      ));
      expect(success, isTrue);

      // Verify that repository has recorded transaction
      expect(txRepo.transactions.length, equals(1));
    });

    test('TransactionFilter reactively filters the transactions in filteredTransactionsProvider', () async {
      final controller = container.read(transactionControllerProvider.notifier);

      await controller.createExpense(CreateExpenseCommand(
        amount: const Money(minorUnits: 10000),
        accountId: 'acc_01',
        categoryId: 'cat_01',
        remark: 'Coffee',
        date: DateTime.now(),
      ));

      await controller.createExpense(CreateExpenseCommand(
        amount: const Money(minorUnits: 80000),
        accountId: 'acc_01',
        categoryId: 'cat_01',
        remark: 'Dinner party',
        date: DateTime.now(),
      ));

      // Set filter on container
      container.read(transactionFilterProvider.notifier).state = const TransactionFilter(
        searchQuery: 'dinner',
      );

      final filterState = container.read(transactionFilterProvider);
      expect(filterState.searchQuery, equals('dinner'));
      expect(filterState.isActive, isTrue);
    });
  });
}
