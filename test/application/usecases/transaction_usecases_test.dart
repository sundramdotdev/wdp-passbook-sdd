import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/commands/transaction_commands.dart';
import 'package:wdp_passbook/application/commands/transaction_filter.dart';
import 'package:wdp_passbook/application/usecases/transaction_usecases.dart';
import 'package:wdp_passbook/core/errors/failures.dart';
import 'package:wdp_passbook/domain/entities/account.dart';
import 'package:wdp_passbook/domain/entities/category.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

import '../fakes/fake_repositories.dart';

void main() {
  late FakeTransactionRepository txRepo;
  late FakeAccountRepository accRepo;
  late FakeCategoryRepository catRepo;

  late CreateExpenseUseCase createExpenseUseCase;
  late CreateIncomeUseCase createIncomeUseCase;
  late CreateTransferUseCase createTransferUseCase;
  late UpdateTransactionUseCase updateTransactionUseCase;
  late DeleteTransactionUseCase deleteTransactionUseCase;
  late GetTransactionUseCase getTransactionUseCase;
  late GetTransactionsUseCase getTransactionsUseCase;
  late SearchTransactionsUseCase searchTransactionsUseCase;

  final now = DateTime(2026, 9, 28, 12, 0, 0);

  setUp(() {
    txRepo = FakeTransactionRepository();
    accRepo = FakeAccountRepository();
    catRepo = FakeCategoryRepository();

    createExpenseUseCase = CreateExpenseUseCase(
      transactionRepository: txRepo,
      accountRepository: accRepo,
      categoryRepository: catRepo,
    );
    createIncomeUseCase = CreateIncomeUseCase(
      transactionRepository: txRepo,
      accountRepository: accRepo,
      categoryRepository: catRepo,
    );
    createTransferUseCase = CreateTransferUseCase(
      transactionRepository: txRepo,
      accountRepository: accRepo,
    );
    updateTransactionUseCase = UpdateTransactionUseCase(txRepo);
    deleteTransactionUseCase = DeleteTransactionUseCase(txRepo);
    getTransactionUseCase = GetTransactionUseCase(txRepo);
    getTransactionsUseCase = GetTransactionsUseCase(txRepo);
    searchTransactionsUseCase = SearchTransactionsUseCase(txRepo);

    // Seed test accounts
    accRepo.createAccount(Account(
      id: 'acc_bank',
      name: 'Primary Bank',
      type: AccountType.bank,
      currencyCode: 'INR',
      balance: const Money(minorUnits: 5000000), // ₹50,000.00
      iconName: 'landmark',
      colorHex: '#3B82F6',
      createdAt: now,
    ));

    accRepo.createAccount(Account(
      id: 'acc_cash',
      name: 'Cash in Hand',
      type: AccountType.cash,
      currencyCode: 'INR',
      balance: const Money(minorUnits: 500000), // ₹5,000.00
      iconName: 'coins',
      colorHex: '#F97316',
      createdAt: now,
    ));

    accRepo.createAccount(Account(
      id: 'acc_usd',
      name: 'USD Account',
      type: AccountType.bank,
      currencyCode: 'USD',
      balance: const Money(minorUnits: 100000, currencyCode: 'USD'),
      iconName: 'landmark',
      colorHex: '#10B981',
      createdAt: now,
    ));

    accRepo.createAccount(Account(
      id: 'acc_archived',
      name: 'Old Account',
      type: AccountType.bank,
      currencyCode: 'INR',
      balance: const Money.zero(),
      iconName: 'archive',
      colorHex: '#64748B',
      isArchived: true,
      createdAt: now,
    ));

    // Seed test categories
    catRepo.createCategory(const Category(
      id: 'cat_groceries',
      name: 'Groceries',
      type: CategoryType.expense,
      iconName: 'shopping-cart',
      colorHex: '#10B981',
    ));

    catRepo.createCategory(const Category(
      id: 'cat_salary',
      name: 'Salary',
      type: CategoryType.income,
      iconName: 'briefcase',
      colorHex: '#3B82F6',
    ));
  });

  group('CreateExpenseUseCase Unit Tests', () {
    test('successfully creates a valid expense transaction', () async {
      final cmd = CreateExpenseCommand(
        amount: const Money(minorUnits: 25000), // ₹250.00
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        remark: 'Vegetables',
        paymentMethod: PaymentMethod.upi,
        date: now,
      );

      final result = await createExpenseUseCase(cmd);
      expect(result.isSuccess, isTrue);
      final tx = result.valueOrNull!;
      expect(tx.amount.minorUnits, equals(25000));
      expect(tx.type, equals(TransactionType.expense));
      expect(tx.categoryName, equals('Groceries'));
      expect(tx.accountName, equals('Primary Bank'));
      expect(txRepo.transactions.containsKey(tx.id), isTrue);
    });

    test('fails when amount is zero or negative', () async {
      final cmd = CreateExpenseCommand(
        amount: const Money.zero(),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        date: now,
      );

      final result = await createExpenseUseCase(cmd);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<InvalidMoneyFailure>());
    });

    test('fails when account does not exist', () async {
      final cmd = CreateExpenseCommand(
        amount: const Money(minorUnits: 1000),
        accountId: 'non_existent_acc',
        categoryId: 'cat_groceries',
        date: now,
      );

      final result = await createExpenseUseCase(cmd);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('fails when account is archived', () async {
      final cmd = CreateExpenseCommand(
        amount: const Money(minorUnits: 1000),
        accountId: 'acc_archived',
        categoryId: 'cat_groceries',
        date: now,
      );

      final result = await createExpenseUseCase(cmd);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('fails when currency does not match account currency', () async {
      final cmd = CreateExpenseCommand(
        amount: const Money(minorUnits: 1000, currencyCode: 'USD'),
        accountId: 'acc_bank', // INR
        categoryId: 'cat_groceries',
        date: now,
      );

      final result = await createExpenseUseCase(cmd);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<CurrencyMismatchFailure>());
    });

    test('fails when category is not an Expense category', () async {
      final cmd = CreateExpenseCommand(
        amount: const Money(minorUnits: 1000),
        accountId: 'acc_bank',
        categoryId: 'cat_salary', // Income category
        date: now,
      );

      final result = await createExpenseUseCase(cmd);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });
  });

  group('CreateIncomeUseCase Unit Tests', () {
    test('successfully creates a valid income transaction', () async {
      final cmd = CreateIncomeCommand(
        amount: const Money(minorUnits: 7500000), // ₹75,000.00
        accountId: 'acc_bank',
        categoryId: 'cat_salary',
        remark: 'Monthly salary',
        paymentMethod: PaymentMethod.bankTransfer,
        date: now,
      );

      final result = await createIncomeUseCase(cmd);
      expect(result.isSuccess, isTrue);
      final tx = result.valueOrNull!;
      expect(tx.type, equals(TransactionType.income));
      expect(tx.amount.minorUnits, equals(7500000));
    });

    test('fails when an expense category is used for income', () async {
      final cmd = CreateIncomeCommand(
        amount: const Money(minorUnits: 1000),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries', // Expense category
        date: now,
      );

      final result = await createIncomeUseCase(cmd);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });
  });

  group('CreateTransferUseCase Unit Tests', () {
    test('successfully creates a transfer between two distinct accounts', () async {
      final cmd = CreateTransferCommand(
        amount: const Money(minorUnits: 500000), // ₹5,000.00
        sourceAccountId: 'acc_bank',
        targetAccountId: 'acc_cash',
        remark: 'ATM cash withdrawal',
        date: now,
      );

      final result = await createTransferUseCase(cmd);
      expect(result.isSuccess, isTrue);
      final tx = result.valueOrNull!;
      expect(tx.type, equals(TransactionType.transfer));
      expect(tx.accountId, equals('acc_bank'));
      expect(tx.targetAccountId, equals('acc_cash'));
    });

    test('fails when source and target accounts are identical', () async {
      final cmd = CreateTransferCommand(
        amount: const Money(minorUnits: 1000),
        sourceAccountId: 'acc_bank',
        targetAccountId: 'acc_bank',
        date: now,
      );

      final result = await createTransferUseCase(cmd);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('fails when transferring between accounts with different currencies', () async {
      final cmd = CreateTransferCommand(
        amount: const Money(minorUnits: 1000),
        sourceAccountId: 'acc_bank', // INR
        targetAccountId: 'acc_usd',  // USD
        date: now,
      );

      final result = await createTransferUseCase(cmd);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<CurrencyMismatchFailure>());
    });
  });

  group('Transaction Modification and Querying Tests', () {
    test('updates an existing transaction successfully', () async {
      final createRes = await createExpenseUseCase(CreateExpenseCommand(
        amount: const Money(minorUnits: 1000),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        remark: 'Initial',
        date: now,
      ));
      final tx = createRes.valueOrNull!;

      final updateCmd = UpdateTransactionCommand(
        id: tx.id,
        amount: const Money(minorUnits: 1500),
        type: TransactionType.expense,
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        remark: 'Updated Remark',
        date: now,
      );

      final updateRes = await updateTransactionUseCase(updateCmd);
      expect(updateRes.isSuccess, isTrue);
      expect(updateRes.valueOrNull!.amount.minorUnits, equals(1500));
      expect(updateRes.valueOrNull!.remark, equals('Updated Remark'));
    });

    test('deletes a transaction successfully', () async {
      final createRes = await createExpenseUseCase(CreateExpenseCommand(
        amount: const Money(minorUnits: 1000),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        date: now,
      ));
      final id = createRes.valueOrNull!.id;

      final delRes = await deleteTransactionUseCase(id);
      expect(delRes.isSuccess, isTrue);
      expect(txRepo.transactions.containsKey(id), isFalse);
    });

    test('filters transactions by typed TransactionFilter', () async {
      await createExpenseUseCase(CreateExpenseCommand(
        amount: const Money(minorUnits: 1000),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        date: DateTime(2026, 9, 1),
      ));
      await createExpenseUseCase(CreateExpenseCommand(
        amount: const Money(minorUnits: 5000),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        date: DateTime(2026, 9, 15),
      ));

      final filter = TransactionFilter(
        minAmount: const Money(minorUnits: 2000),
      );

      final res = await getTransactionsUseCase(filter: filter);
      expect(res.isSuccess, isTrue);
      expect(res.valueOrNull!.length, equals(1));
      expect(res.valueOrNull!.first.amount.minorUnits, equals(5000));
    });

    test('searches transactions by keyword across remarks and categories', () async {
      await createExpenseUseCase(CreateExpenseCommand(
        amount: const Money(minorUnits: 1000),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        remark: 'Amul Milk and curd',
        date: now,
      ));

      final searchRes = await searchTransactionsUseCase('amul');
      expect(searchRes.isSuccess, isTrue);
      expect(searchRes.valueOrNull!.length, equals(1));
      expect(searchRes.valueOrNull!.first.remark, contains('Amul'));
    });

    test('retrieves individual transaction by ID', () async {
      final createRes = await createExpenseUseCase(CreateExpenseCommand(
        amount: const Money(minorUnits: 1200),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        date: now,
      ));
      final id = createRes.valueOrNull!.id;

      final fetchedRes = await getTransactionUseCase(id);
      expect(fetchedRes.isSuccess, isTrue);
      expect(fetchedRes.valueOrNull!.id, equals(id));
    });
  });
}
