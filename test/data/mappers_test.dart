import 'package:flutter_test/flutter_test.dart';

import 'package:wdp_passbook/data/mappers/personal_mappers.dart';
import 'package:wdp_passbook/data/mappers/transaction_mapper.dart';
import 'package:wdp_passbook/domain/entities/account.dart';
import 'package:wdp_passbook/domain/entities/budget.dart';
import 'package:wdp_passbook/domain/entities/category.dart';
import 'package:wdp_passbook/domain/entities/money.dart';
import 'package:wdp_passbook/domain/entities/savings_goal.dart';
import 'package:wdp_passbook/domain/entities/transaction.dart';
import 'package:wdp_passbook/domain/enums/personal_enums.dart';

void main() {
  group('Data Mappers Lossless Bidirectional Mapping Tests', () {
    final testDate = DateTime(2026, 9, 28, 12, 0, 0);

    test('AccountMapper bidirectionally maps Account <-> IsarAccount', () {
      final domain = Account(
        id: 'acc_001',
        name: 'HDFC Savings',
        type: AccountType.bank,
        currencyCode: 'INR',
        balance: const Money(minorUnits: 1500000), // ₹15,000.00
        iconName: 'landmark',
        colorHex: '#3B82F6',
        isArchived: false,
        createdAt: testDate,
      );

      final isar = AccountMapper.toIsar(domain);
      expect(isar.uuid, equals(domain.id));
      expect(isar.name, equals(domain.name));
      expect(isar.type, equals('bank'));
      expect(isar.balanceMinorUnits, equals(1500000));
      expect(isar.currencyCode, equals('INR'));
      expect(isar.iconName, equals('landmark'));
      expect(isar.colorHex, equals('#3B82F6'));
      expect(isar.isArchived, isFalse);

      final mappedDomain = AccountMapper.toDomain(isar);
      expect(mappedDomain.id, equals(domain.id));
      expect(mappedDomain.name, equals(domain.name));
      expect(mappedDomain.type, equals(AccountType.bank));
      expect(mappedDomain.balance.minorUnits, equals(1500000));
      expect(mappedDomain.currencyCode, equals('INR'));
      expect(mappedDomain.iconName, equals(domain.iconName));
      expect(mappedDomain.colorHex, equals(domain.colorHex));
    });

    test('CategoryMapper bidirectionally maps Category <-> IsarCategory', () {
      const domain = Category(
        id: 'cat_001',
        name: 'Groceries',
        type: CategoryType.expense,
        iconName: 'shopping-cart',
        colorHex: '#10B981',
        isDefault: true,
        isArchived: false,
      );

      final isar = CategoryMapper.toIsar(domain);
      expect(isar.uuid, equals(domain.id));
      expect(isar.name, equals(domain.name));
      expect(isar.type, equals('expense'));
      expect(isar.iconName, equals('shopping-cart'));
      expect(isar.colorHex, equals('#10B981'));
      expect(isar.isDefault, isTrue);

      final mappedDomain = CategoryMapper.toDomain(isar);
      expect(mappedDomain.id, equals(domain.id));
      expect(mappedDomain.name, equals(domain.name));
      expect(mappedDomain.type, equals(CategoryType.expense));
      expect(mappedDomain.iconName, equals(domain.iconName));
      expect(mappedDomain.colorHex, equals(domain.colorHex));
      expect(mappedDomain.isDefault, isTrue);
      expect(mappedDomain.isArchived, isFalse);
    });

    test('TransactionMapper bidirectionally maps Transaction <-> IsarTransaction', () {
      final domain = Transaction.validated(
        id: 'tx_999',
        amount: const Money(minorUnits: 250000), // ₹2,500.00
        type: TransactionType.expense,
        categoryId: 'cat_dining',
        categoryName: 'Dining Out',
        accountId: 'acc_001',
        accountName: 'HDFC Savings',
        date: testDate,
        remark: 'Family dinner',
        isUpiVerified: true,
        upiTxnId: 'UPI987654321',
      );

      final isar = TransactionMapper.toIsar(domain);
      expect(isar.uuid, equals(domain.id));
      expect(isar.minorUnits, equals(250000));
      expect(isar.type, equals('expense'));
      expect(isar.categoryId, equals('cat_dining'));
      expect(isar.categoryName, equals('Dining Out'));
      expect(isar.accountId, equals('acc_001'));
      expect(isar.accountName, equals('HDFC Savings'));
      expect(isar.remark, equals('Family dinner'));
      expect(isar.isUpiVerified, isTrue);
      expect(isar.upiTxnId, equals('UPI987654321'));

      final mappedDomain = TransactionMapper.toDomain(isar);
      expect(mappedDomain.id, equals(domain.id));
      expect(mappedDomain.amount.minorUnits, equals(250000));
      expect(mappedDomain.type, equals(TransactionType.expense));
      expect(mappedDomain.categoryId, equals('cat_dining'));
      expect(mappedDomain.accountId, equals('acc_001'));
      expect(mappedDomain.remark, equals('Family dinner'));
      expect(mappedDomain.isUpiVerified, isTrue);
      expect(mappedDomain.upiTxnId, equals('UPI987654321'));
    });

    test('BudgetMapper bidirectionally maps Budget <-> IsarBudget', () {
      final domain = Budget(
        id: 'bg_01',
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        limitAmount: const Money(minorUnits: 1000000), // ₹10,000.00
        spentAmount: const Money(minorUnits: 350000),  // ₹3,500.00
        period: BudgetPeriod.monthly,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30),
      );

      final isar = BudgetMapper.toIsar(domain);
      expect(isar.uuid, equals(domain.id));
      expect(isar.categoryId, equals(domain.categoryId));
      expect(isar.limitMinorUnits, equals(1000000));
      expect(isar.spentMinorUnits, equals(350000));
      expect(isar.period, equals('monthly'));

      final mappedDomain = BudgetMapper.toDomain(isar);
      expect(mappedDomain.id, equals(domain.id));
      expect(mappedDomain.categoryId, equals(domain.categoryId));
      expect(mappedDomain.limitAmount.minorUnits, equals(1000000));
      expect(mappedDomain.spentAmount.minorUnits, equals(350000));
      expect(mappedDomain.period, equals(BudgetPeriod.monthly));
    });

    test('GoalMapper bidirectionally maps SavingsGoal <-> IsarGoal', () {
      final domain = SavingsGoal(
        id: 'gl_01',
        title: 'Emergency Fund',
        targetAmount: const Money(minorUnits: 50000000), // ₹5,00,000.00
        savedAmount: const Money(minorUnits: 12500000),  // ₹1,25,000.00
        targetDate: DateTime(2027, 3, 31),
        status: GoalStatus.active,
        iconName: 'shield',
      );

      final isar = GoalMapper.toIsar(domain);
      expect(isar.uuid, equals(domain.id));
      expect(isar.title, equals(domain.title));
      expect(isar.targetMinorUnits, equals(50000000));
      expect(isar.savedMinorUnits, equals(12500000));
      expect(isar.status, equals('active'));

      final mappedDomain = GoalMapper.toDomain(isar);
      expect(mappedDomain.id, equals(domain.id));
      expect(mappedDomain.title, equals(domain.title));
      expect(mappedDomain.targetAmount.minorUnits, equals(50000000));
      expect(mappedDomain.savedAmount.minorUnits, equals(12500000));
      expect(mappedDomain.status, equals(GoalStatus.active));
      expect(mappedDomain.iconName, equals('shield'));
    });
  });
}
