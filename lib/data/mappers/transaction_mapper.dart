import '../../domain/entities/money.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/enums/personal_enums.dart';
import '../local/isar/isar_transaction.dart';

class TransactionMapper {
  static Transaction toDomain(IsarTransaction isar) {
    return Transaction(
      id: isar.uuid,
      amount: Money(
        minorUnits: isar.minorUnits,
        currencyCode: isar.currencyCode,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == isar.type,
        orElse: () => TransactionType.expense,
      ),
      categoryId: isar.categoryId,
      categoryName: isar.categoryName,
      accountId: isar.accountId,
      accountName: isar.accountName,
      targetAccountId: isar.targetAccountId,
      targetAccountName: isar.targetAccountName,
      remark: isar.remark,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == isar.paymentMethod,
        orElse: () => PaymentMethod.cash,
      ),
      date: isar.date,
      merchantId: isar.merchantId,
      merchantName: isar.merchantName,
      isUpiVerified: isar.isUpiVerified,
      upiTxnId: isar.upiTxnId,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
    );
  }

  static IsarTransaction toIsar(Transaction domain, [IsarTransaction? existing]) {
    final isar = existing ?? IsarTransaction();
    isar.uuid = domain.id;
    isar.minorUnits = domain.amount.minorUnits;
    isar.currencyCode = domain.amount.currencyCode;
    isar.type = domain.type.name;
    isar.categoryId = domain.categoryId;
    isar.categoryName = domain.categoryName;
    isar.accountId = domain.accountId;
    isar.accountName = domain.accountName;
    isar.targetAccountId = domain.targetAccountId;
    isar.targetAccountName = domain.targetAccountName;
    isar.remark = domain.remark;
    isar.paymentMethod = domain.paymentMethod.name;
    isar.date = domain.date;
    isar.merchantId = domain.merchantId;
    isar.merchantName = domain.merchantName;
    isar.isUpiVerified = domain.isUpiVerified;
    isar.upiTxnId = domain.upiTxnId;
    isar.createdAt = domain.createdAt;
    isar.updatedAt = domain.updatedAt;
    return isar;
  }
}
