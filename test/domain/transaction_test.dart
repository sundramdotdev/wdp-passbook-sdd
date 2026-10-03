import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/core/errors/exceptions.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/entities/transaction.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

void main() {
  group('Transaction Domain Entity Invariants & Validation', () {
    final now = DateTime.now();

    test('successfully instantiates a valid expense transaction', () {
      final tx = Transaction.validated(
        id: 'tx_exp_1',
        amount: const Money(minorUnits: 45000), // ₹450.00
        type: TransactionType.expense,
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        accountId: 'acc_bank',
        accountName: 'Primary Bank',
        date: now,
        remark: 'Weekly supermarket',
      );

      expect(tx.id, equals('tx_exp_1'));
      expect(tx.amount.minorUnits, equals(45000));
      expect(tx.type, equals(TransactionType.expense));
      expect(tx.categoryId, equals('cat_groceries'));
      expect(tx.isUpiVerified, isFalse);
    });

    test('successfully instantiates a valid income transaction', () {
      final tx = Transaction.validated(
        id: 'tx_inc_1',
        amount: const Money(minorUnits: 12000000), // ₹1,20,000.00
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
        accountId: 'acc_bank',
        accountName: 'Primary Bank',
        date: now,
        remark: 'Monthly Salary',
      );

      expect(tx.id, equals('tx_inc_1'));
      expect(tx.type, equals(TransactionType.income));
    });

    test('successfully instantiates a valid transfer between two accounts', () {
      final tx = Transaction.validated(
        id: 'tx_trn_1',
        amount: const Money(minorUnits: 500000), // ₹5,000.00
        type: TransactionType.transfer,
        accountId: 'acc_bank',
        accountName: 'Primary Bank',
        targetAccountId: 'acc_cash',
        targetAccountName: 'Cash in Hand',
        date: now,
        remark: 'ATM withdrawal',
      );

      expect(tx.id, equals('tx_trn_1'));
      expect(tx.type, equals(TransactionType.transfer));
      expect(tx.accountId, equals('acc_bank'));
      expect(tx.targetAccountId, equals('acc_cash'));
    });

    test('throws InvalidMoneyException when amount is zero or negative', () {
      expect(
        () => Transaction.validated(
          id: 'tx_invalid_amt_0',
          amount: const Money.zero(),
          type: TransactionType.expense,
          categoryId: 'cat_food',
          categoryName: 'Food',
          accountId: 'acc_bank',
          accountName: 'Bank',
          date: now,
        ),
        throwsA(isA<InvalidMoneyException>()),
      );

      expect(
        () => Transaction.validated(
          id: 'tx_invalid_amt_neg',
          amount: const Money(minorUnits: -100),
          type: TransactionType.expense,
          categoryId: 'cat_food',
          categoryName: 'Food',
          accountId: 'acc_bank',
          accountName: 'Bank',
          date: now,
        ),
        throwsA(isA<InvalidMoneyException>()),
      );
    });

    test('throws InvalidTransactionException when accountId is missing or blank', () {
      expect(
        () => Transaction.validated(
          id: 'tx_missing_acc',
          amount: const Money(minorUnits: 1000),
          type: TransactionType.expense,
          categoryId: 'cat_food',
          categoryName: 'Food',
          accountId: '   ',
          accountName: 'Bank',
          date: now,
        ),
        throwsA(isA<InvalidTransactionException>()),
      );
    });

    test('throws InvalidTransactionException when category is missing for expense or income', () {
      expect(
        () => Transaction.validated(
          id: 'tx_no_cat_expense',
          amount: const Money(minorUnits: 1000),
          type: TransactionType.expense,
          categoryId: null,
          categoryName: null,
          accountId: 'acc_bank',
          accountName: 'Bank',
          date: now,
        ),
        throwsA(isA<InvalidTransactionException>()),
      );

      expect(
        () => Transaction.validated(
          id: 'tx_no_cat_income',
          amount: const Money(minorUnits: 1000),
          type: TransactionType.income,
          categoryId: '',
          categoryName: '',
          accountId: 'acc_bank',
          accountName: 'Bank',
          date: now,
        ),
        throwsA(isA<InvalidTransactionException>()),
      );
    });

    test('transfer validation rules: requires targetAccountId and cannot transfer to same account', () {
      // Missing target account
      expect(
        () => Transaction.validated(
          id: 'tx_trn_no_target',
          amount: const Money(minorUnits: 2000),
          type: TransactionType.transfer,
          accountId: 'acc_bank',
          accountName: 'Bank',
          targetAccountId: null,
          date: now,
        ),
        throwsA(isA<InvalidTransactionException>()),
      );

      // Same account transfer
      expect(
        () => Transaction.validated(
          id: 'tx_trn_same_acc',
          amount: const Money(minorUnits: 2000),
          type: TransactionType.transfer,
          accountId: 'acc_bank',
          accountName: 'Bank',
          targetAccountId: 'acc_bank',
          targetAccountName: 'Bank',
          date: now,
        ),
        throwsA(isA<InvalidTransactionException>()),
      );
    });
  });
}
