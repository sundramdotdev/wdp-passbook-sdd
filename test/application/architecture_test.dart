import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/application/commands/account_commands.dart';
import 'package:wdp_passbook/application/commands/category_commands.dart';
import 'package:wdp_passbook/application/commands/transaction_commands.dart';
import 'package:wdp_passbook/application/usecases/account_usecases.dart';
import 'package:wdp_passbook/application/usecases/category_usecases.dart';
import 'package:wdp_passbook/application/usecases/transaction_usecases.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

import 'fakes/fake_repositories.dart';

void main() {
  group('Phase 3 Architecture Verification Test (Step 39)', () {
    test('proves completely UI-independent operation: Command -> UseCase -> Repository -> Result', () async {
      // Setup Repositories (Data Layer)
      final txRepo = FakeTransactionRepository();
      final accRepo = FakeAccountRepository();
      final catRepo = FakeCategoryRepository();

      // Setup Use Cases (Application Layer)
      final createAccountUseCase = CreateAccountUseCase(accRepo);
      final createCategoryUseCase = CreateCategoryUseCase(catRepo);
      final createExpenseUseCase = CreateExpenseUseCase(
        transactionRepository: txRepo,
        accountRepository: accRepo,
        categoryRepository: catRepo,
      );

      // 1. Create Account via Command
      const accCommand = CreateAccountCommand(
        name: 'HDFC Salary',
        type: AccountType.bank,
        initialBalance: Money(minorUnits: 10000000), // ₹1,00,000.00
      );
      final accResult = await createAccountUseCase(accCommand);
      expect(accResult.isSuccess, isTrue);
      final account = accResult.valueOrNull!;

      // 2. Create Category via Command
      const catCommand = CreateCategoryCommand(
        name: 'Groceries',
        type: CategoryType.expense,
        iconName: 'shopping-cart',
      );
      final catResult = await createCategoryUseCase(catCommand);
      expect(catResult.isSuccess, isTrue);
      final category = catResult.valueOrNull!;

      // 3. Create Expense Transaction via Command
      final expenseCommand = CreateExpenseCommand(
        amount: const Money(minorUnits: 450000), // ₹4,500.00
        accountId: account.id,
        categoryId: category.id,
        remark: 'Supermarket monthly bulk purchase',
        paymentMethod: PaymentMethod.upi,
        date: DateTime(2026, 9, 28, 14, 30),
      );

      final txResult = await createExpenseUseCase(expenseCommand);
      expect(txResult.isSuccess, isTrue);
      final transaction = txResult.valueOrNull!;

      // 4. Assert correctness without WidgetTester, BuildContext, or UI code
      expect(transaction.amount.minorUnits, equals(450000));
      expect(transaction.amount.toMajor, equals(4500.0));
      expect(transaction.accountId, equals(account.id));
      expect(transaction.accountName, equals('HDFC Salary'));
      expect(transaction.categoryId, equals(category.id));
      expect(transaction.categoryName, equals('Groceries'));
      expect(transaction.type, equals(TransactionType.expense));
      expect(transaction.remark, equals('Supermarket monthly bulk purchase'));

      // 5. Verify persistence in repository
      final fetchedRes = await txRepo.getTransactionById(transaction.id);
      expect(fetchedRes.isSuccess, isTrue);
      expect(fetchedRes.valueOrNull!.id, equals(transaction.id));
    });
  });
}
