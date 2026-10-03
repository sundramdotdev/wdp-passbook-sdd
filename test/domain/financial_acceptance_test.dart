import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/domain/entities/account.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/entities/transaction.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

void main() {
  group('Phase 2 Financial Acceptance Invariants Test Suite (Step 39)', () {
    test('verifies complete ledger invariant sequence without floating-point distortion', () {
      final now = DateTime(2026, 9, 28, 10, 0, 0);

      // 1. Create account A with opening balance ₹10,000 (1000000 minor units)
      var accountA = Account(
        id: 'acc_A',
        name: 'Account A',
        type: AccountType.bank,
        balance: const Money(minorUnits: 1000000),
        iconName: 'landmark',
        colorHex: '#3B82F6',
        createdAt: now,
      );

      // 2. Create account B with opening balance ₹5,000 (500000 minor units)
      var accountB = Account(
        id: 'acc_B',
        name: 'Account B',
        type: AccountType.bank,
        balance: const Money(minorUnits: 500000),
        iconName: 'landmark',
        colorHex: '#10B981',
        createdAt: now,
      );

      final ledger = <Transaction>[];

      // Helper function to calculate account balance from initial balance + ledger transactions
      Money calculateBalance(Account account) {
        var balance = account.balance;
        for (final tx in ledger) {
          if (tx.type == TransactionType.income && tx.accountId == account.id) {
            balance += tx.amount;
          } else if (tx.type == TransactionType.expense && tx.accountId == account.id) {
            balance -= tx.amount;
          } else if (tx.type == TransactionType.transfer) {
            if (tx.accountId == account.id) {
              balance -= tx.amount; // Source deducted
            } else if (tx.targetAccountId == account.id) {
              balance += tx.amount; // Target credited
            }
          }
        }
        return balance;
      }

      // Helper function to calculate total income & expense strictly (excluding transfers)
      (Money income, Money expense) calculateTotals() {
        var totalIncome = const Money.zero();
        var totalExpense = const Money.zero();

        for (final tx in ledger) {
          if (tx.type == TransactionType.income) {
            totalIncome += tx.amount;
          } else if (tx.type == TransactionType.expense) {
            totalExpense += tx.amount;
          }
          // Transfers MUST NEVER be counted as income or expense
        }
        return (totalIncome, totalExpense);
      }

      // 3. Create expense transaction: ₹1,500 (150000 minor units) from A to category 'Food'
      final txExpense = Transaction.validated(
        id: 'tx_1',
        amount: const Money(minorUnits: 150000),
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food',
        accountId: accountA.id,
        accountName: accountA.name,
        date: now.add(const Duration(hours: 1)),
        remark: 'Groceries and snacks',
      );
      ledger.add(txExpense);

      // 4. Verify balance calculation
      // Account A balance = ₹8,500
      // Total income = ₹0
      // Total expenses = ₹1,500
      expect(calculateBalance(accountA).minorUnits, equals(850000));
      expect(calculateBalance(accountA).toMajor, equals(8500.0));
      var (income, expense) = calculateTotals();
      expect(income.minorUnits, equals(0));
      expect(expense.minorUnits, equals(150000));
      expect(expense.toMajor, equals(1500.0));

      // 5. Create income transaction: ₹20,000 (2000000 minor units) into B from category 'Salary'
      final txIncome = Transaction.validated(
        id: 'tx_2',
        amount: const Money(minorUnits: 2000000),
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
        accountId: accountB.id,
        accountName: accountB.name,
        date: now.add(const Duration(hours: 2)),
        remark: 'Consulting payment',
      );
      ledger.add(txIncome);

      // 6. Verify balance calculation
      // Account B balance = ₹25,000
      // Total income = ₹20,000
      // Total expenses = ₹1,500
      expect(calculateBalance(accountB).minorUnits, equals(2500000));
      expect(calculateBalance(accountB).toMajor, equals(25000.0));
      (income, expense) = calculateTotals();
      expect(income.minorUnits, equals(2000000));
      expect(income.toMajor, equals(20000.0));
      expect(expense.minorUnits, equals(150000));
      expect(expense.toMajor, equals(1500.0));

      // 7. Create transfer transaction: ₹3,000 (300000 minor units) from B to A
      final txTransfer = Transaction.validated(
        id: 'tx_3',
        amount: const Money(minorUnits: 300000),
        type: TransactionType.transfer,
        accountId: accountB.id,
        accountName: accountB.name,
        targetAccountId: accountA.id,
        targetAccountName: accountA.name,
        date: now.add(const Duration(hours: 3)),
        remark: 'Inter-account transfer from B to A',
      );
      ledger.add(txTransfer);

      // 8. Verify balance calculation
      // Account A balance = ₹8,500 + ₹3,000 = ₹11,500
      // Account B balance = ₹25,000 - ₹3,000 = ₹22,000
      // Total income = ₹20,000 (unchanged)
      // Total expenses = ₹1,500 (unchanged)
      expect(calculateBalance(accountA).minorUnits, equals(1150000));
      expect(calculateBalance(accountA).toMajor, equals(11500.0));
      expect(calculateBalance(accountB).minorUnits, equals(2200000));
      expect(calculateBalance(accountB).toMajor, equals(22000.0));

      (income, expense) = calculateTotals();
      expect(income.minorUnits, equals(2000000));
      expect(income.toMajor, equals(20000.0));
      expect(expense.minorUnits, equals(150000));
      expect(expense.toMajor, equals(1500.0));

      // 9. Verify transfer transaction DOES NOT appear in income or expense totals
      final nonTransferCount = ledger.where((t) => t.type != TransactionType.transfer).length;
      expect(nonTransferCount, equals(2));
      expect(ledger.length, equals(3));
    });
  });
}
