import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/commands/account_commands.dart';
import 'package:wdp_passbook/application/commands/category_commands.dart';
import 'package:wdp_passbook/application/commands/transaction_commands.dart';
import 'package:wdp_passbook/application/usecases/account_usecases.dart';
import 'package:wdp_passbook/application/usecases/balance_usecases.dart';
import 'package:wdp_passbook/application/usecases/category_usecases.dart';
import 'package:wdp_passbook/application/usecases/transaction_usecases.dart';
import 'package:wdp_passbook/core/errors/failures.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

import '../fakes/fake_repositories.dart';

void main() {
  late FakeAccountRepository accRepo;
  late FakeCategoryRepository catRepo;
  late FakeTransactionRepository txRepo;

  late CreateAccountUseCase createAccountUseCase;
  late UpdateAccountUseCase updateAccountUseCase;
  late ArchiveAccountUseCase archiveAccountUseCase;
  late RestoreAccountUseCase restoreAccountUseCase;
  late GetAccountsUseCase getAccountsUseCase;

  late CreateCategoryUseCase createCategoryUseCase;
  late UpdateCategoryUseCase updateCategoryUseCase;
  late ArchiveCategoryUseCase archiveCategoryUseCase;
  late GetCategoriesUseCase getCategoriesUseCase;

  late GetTotalBalanceUseCase getTotalBalanceUseCase;
  late GetAccountBalanceUseCase getAccountBalanceUseCase;
  late CreateExpenseUseCase createExpenseUseCase;

  setUp(() {
    accRepo = FakeAccountRepository();
    catRepo = FakeCategoryRepository();
    txRepo = FakeTransactionRepository();

    createAccountUseCase = CreateAccountUseCase(accRepo);
    updateAccountUseCase = UpdateAccountUseCase(accRepo);
    archiveAccountUseCase = ArchiveAccountUseCase(accRepo);
    restoreAccountUseCase = RestoreAccountUseCase(accRepo);
    getAccountsUseCase = GetAccountsUseCase(accRepo);

    createCategoryUseCase = CreateCategoryUseCase(catRepo);
    updateCategoryUseCase = UpdateCategoryUseCase(catRepo);
    archiveCategoryUseCase = ArchiveCategoryUseCase(catRepo);
    getCategoriesUseCase = GetCategoriesUseCase(catRepo);

    getTotalBalanceUseCase = GetTotalBalanceUseCase(accRepo);
    getAccountBalanceUseCase = GetAccountBalanceUseCase(txRepo);

    createExpenseUseCase = CreateExpenseUseCase(
      transactionRepository: txRepo,
      accountRepository: accRepo,
      categoryRepository: catRepo,
    );
  });

  group('Account Use Cases', () {
    test('creates account with initial balance', () async {
      final cmd = CreateAccountCommand(
        name: 'ICICI Salary Account',
        type: AccountType.bank,
        initialBalance: const Money(minorUnits: 5000000), // ₹50,000.00
      );

      final res = await createAccountUseCase(cmd);
      expect(res.isSuccess, isTrue);
      final acc = res.valueOrNull!;
      expect(acc.name, equals('ICICI Salary Account'));
      expect(acc.balance.minorUnits, equals(5000000));
      expect(acc.isArchived, isFalse);
    });

    test('fails when account name is blank', () async {
      final cmd = CreateAccountCommand(
        name: '   ',
        type: AccountType.bank,
      );

      final res = await createAccountUseCase(cmd);
      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('archives and restores account correctly', () async {
      final createRes = await createAccountUseCase(const CreateAccountCommand(
        name: 'Savings',
        type: AccountType.bank,
      ));
      final id = createRes.valueOrNull!.id;

      // Archive
      final archRes = await archiveAccountUseCase(id);
      expect(archRes.isSuccess, isTrue);
      var accounts = (await getAccountsUseCase(includeArchived: false)).valueOrNull!;
      expect(accounts.any((a) => a.id == id), isFalse);

      // Restore
      final restRes = await restoreAccountUseCase(id);
      expect(restRes.isSuccess, isTrue);
      accounts = (await getAccountsUseCase(includeArchived: false)).valueOrNull!;
      expect(accounts.any((a) => a.id == id), isTrue);

      // Update
      final updateRes = await updateAccountUseCase(UpdateAccountCommand(
        id: id,
        name: 'Updated Savings',
        type: AccountType.bank,
        iconName: 'landmark',
        colorHex: '#2563EB',
      ));
      expect(updateRes.isSuccess, isTrue);
      expect(updateRes.valueOrNull!.name, equals('Updated Savings'));
    });
  });

  group('Category Use Cases', () {
    test('creates category successfully', () async {
      final cmd = const CreateCategoryCommand(
        name: 'Entertainment',
        type: CategoryType.expense,
        iconName: 'film',
        colorHex: '#8B5CF6',
      );

      final res = await createCategoryUseCase(cmd);
      expect(res.isSuccess, isTrue);
      expect(res.valueOrNull!.name, equals('Entertainment'));
      expect(res.valueOrNull!.type, equals(CategoryType.expense));
    });

    test('archives category successfully', () async {
      final createRes = await createCategoryUseCase(const CreateCategoryCommand(
        name: 'Old Bills',
        type: CategoryType.expense,
      ));
      final id = createRes.valueOrNull!.id;

      final archRes = await archiveCategoryUseCase(id);
      expect(archRes.isSuccess, isTrue);

      final activeCats = (await getCategoriesUseCase(includeArchived: false)).valueOrNull!;
      expect(activeCats.any((c) => c.id == id), isFalse);

      // Update
      final updateRes = await updateCategoryUseCase(UpdateCategoryCommand(
        id: id,
        name: 'New Bills',
        type: CategoryType.expense,
        iconName: 'receipt',
        colorHex: '#64748B',
      ));
      expect(updateRes.isSuccess, isTrue);
      expect(updateRes.valueOrNull!.name, equals('New Bills'));
    });
  });

  group('Balance Use Cases', () {
    test('calculates total portfolio balance across multiple accounts', () async {
      await createAccountUseCase(const CreateAccountCommand(
        name: 'Account 1',
        type: AccountType.bank,
        initialBalance: Money(minorUnits: 1000000), // ₹10,000.00
      ));
      await createAccountUseCase(const CreateAccountCommand(
        name: 'Account 2',
        type: AccountType.cash,
        initialBalance: Money(minorUnits: 500000), // ₹5,000.00
      ));

      final balanceRes = await getTotalBalanceUseCase();
      expect(balanceRes.isSuccess, isTrue);
      expect(balanceRes.valueOrNull!.minorUnits, equals(1500000));
      expect(balanceRes.valueOrNull!.toMajor, equals(15000.0));
    });

    test('derives individual account balance from transactions history', () async {
      final accRes = await createAccountUseCase(const CreateAccountCommand(
        name: 'Bank',
        type: AccountType.bank,
      ));
      final acc = accRes.valueOrNull!;

      final catRes = await createCategoryUseCase(const CreateCategoryCommand(
        name: 'Groceries',
        type: CategoryType.expense,
      ));
      final cat = catRes.valueOrNull!;

      // Create expense
      await createExpenseUseCase(CreateExpenseCommand(
        amount: const Money(minorUnits: 250000), // ₹2,500.00
        accountId: acc.id,
        categoryId: cat.id,
        date: DateTime.now(),
      ));

      final balanceRes = await getAccountBalanceUseCase(acc.id);
      expect(balanceRes.isSuccess, isTrue);
      expect(balanceRes.valueOrNull!.minorUnits, equals(-250000));
    });
  });
}
