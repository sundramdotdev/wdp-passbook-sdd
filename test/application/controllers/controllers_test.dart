import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/commands/account_commands.dart';
import 'package:wdp_passbook/application/commands/category_commands.dart';
import 'package:wdp_passbook/application/commands/transaction_commands.dart';
import 'package:wdp_passbook/application/controllers/account_controller.dart';
import 'package:wdp_passbook/application/controllers/category_controller.dart';
import 'package:wdp_passbook/application/controllers/transaction_controller.dart';
import 'package:wdp_passbook/application/usecases/account_usecases.dart';
import 'package:wdp_passbook/application/usecases/category_usecases.dart';
import 'package:wdp_passbook/application/usecases/transaction_usecases.dart';
import 'package:wdp_passbook/domain/entities/account.dart';
import 'package:wdp_passbook/domain/entities/category.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

import '../fakes/fake_repositories.dart';

void main() {
  late FakeTransactionRepository txRepo;
  late FakeAccountRepository accRepo;
  late FakeCategoryRepository catRepo;

  late TransactionController txController;
  late AccountController accController;
  late CategoryController catController;

  setUp(() {
    txRepo = FakeTransactionRepository();
    accRepo = FakeAccountRepository();
    catRepo = FakeCategoryRepository();

    txController = TransactionController(
      createExpenseUseCase: CreateExpenseUseCase(
        transactionRepository: txRepo,
        accountRepository: accRepo,
        categoryRepository: catRepo,
      ),
      createIncomeUseCase: CreateIncomeUseCase(
        transactionRepository: txRepo,
        accountRepository: accRepo,
        categoryRepository: catRepo,
      ),
      createTransferUseCase: CreateTransferUseCase(
        transactionRepository: txRepo,
        accountRepository: accRepo,
      ),
      updateTransactionUseCase: UpdateTransactionUseCase(txRepo),
      deleteTransactionUseCase: DeleteTransactionUseCase(txRepo),
    );

    accController = AccountController(
      createAccountUseCase: CreateAccountUseCase(accRepo),
      updateAccountUseCase: UpdateAccountUseCase(accRepo),
      archiveAccountUseCase: ArchiveAccountUseCase(accRepo),
      restoreAccountUseCase: RestoreAccountUseCase(accRepo),
    );

    catController = CategoryController(
      createCategoryUseCase: CreateCategoryUseCase(catRepo),
      updateCategoryUseCase: UpdateCategoryUseCase(catRepo),
      archiveCategoryUseCase: ArchiveCategoryUseCase(catRepo),
    );

    // Seed test accounts and categories
    accRepo.createAccount(Account(
      id: 'acc_bank',
      name: 'Primary Bank',
      type: AccountType.bank,
      balance: const Money(minorUnits: 1000000),
      iconName: 'landmark',
      colorHex: '#3B82F6',
      createdAt: DateTime.now(),
    ));

    accRepo.createAccount(Account(
      id: 'acc_cash',
      name: 'Cash',
      type: AccountType.cash,
      balance: const Money(minorUnits: 500000),
      iconName: 'coins',
      colorHex: '#F97316',
      createdAt: DateTime.now(),
    ));

    catRepo.createCategory(const Category(
      id: 'cat_groceries',
      name: 'Groceries',
      type: CategoryType.expense,
      iconName: 'shopping-cart',
      colorHex: '#10B981',
    ));
  });

  group('TransactionController Lifecycle & State Tests', () {
    test('initial state is IdleActionState', () {
      expect(txController.state.isIdle, isTrue);
    });

    test('successful expense creation transitions to SuccessActionState', () async {
      final success = await txController.createExpense(CreateExpenseCommand(
        amount: const Money(minorUnits: 15000),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        date: DateTime.now(),
      ));

      expect(success, isTrue);
      expect(txController.state.isSuccess, isTrue);
      expect(txController.state.dataOrNull!.amount.minorUnits, equals(15000));
    });

    test('validation failure translates to ErrorActionState with readable message', () async {
      final success = await txController.createExpense(CreateExpenseCommand(
        amount: const Money.zero(), // Invalid zero amount
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        date: DateTime.now(),
      ));

      expect(success, isFalse);
      expect(txController.state.isError, isTrue);
      expect(txController.state.errorOrNull, contains('strictly greater than zero'));
    });

    test('successful transfer transitions to SuccessActionState', () async {
      final success = await txController.createTransfer(CreateTransferCommand(
        amount: const Money(minorUnits: 20000),
        sourceAccountId: 'acc_bank',
        targetAccountId: 'acc_cash',
        date: DateTime.now(),
      ));

      expect(success, isTrue);
      expect(txController.state.isSuccess, isTrue);
      expect(txController.state.dataOrNull!.type, equals(TransactionType.transfer));
    });

    test('deleting a transaction transitions back to IdleActionState', () async {
      final createRes = await txController.createExpense(CreateExpenseCommand(
        amount: const Money(minorUnits: 5000),
        accountId: 'acc_bank',
        categoryId: 'cat_groceries',
        date: DateTime.now(),
      ));
      expect(createRes, isTrue);
      final id = txController.state.dataOrNull!.id;

      final delRes = await txController.deleteTransaction(id);
      expect(delRes, isTrue);
      expect(txController.state.isIdle, isTrue);
    });
  });

  group('AccountController Lifecycle & State Tests', () {
    test('creates account and updates state', () async {
      final success = await accController.createAccount(const CreateAccountCommand(
        name: 'Investment',
        type: AccountType.bank,
        initialBalance: Money(minorUnits: 1000000),
      ));

      expect(success, isTrue);
      expect(accController.state.isSuccess, isTrue);
      expect(accController.state.dataOrNull!.name, equals('Investment'));
    });

    test('archives account and transitions to IdleActionState', () async {
      final success = await accController.archiveAccount('acc_bank');
      expect(success, isTrue);
      expect(accController.state.isIdle, isTrue);
    });
  });

  group('CategoryController Lifecycle & State Tests', () {
    test('creates category and updates state', () async {
      final success = await catController.createCategory(const CreateCategoryCommand(
        name: 'Utilities',
        type: CategoryType.expense,
      ));

      expect(success, isTrue);
      expect(catController.state.isSuccess, isTrue);
      expect(catController.state.dataOrNull!.name, equals('Utilities'));
    });
  });
}
