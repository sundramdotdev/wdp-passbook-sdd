import '../../core/errors/exceptions.dart';
import 'money.dart';
import '../enums/personal_enums.dart';

/// Core domain entity representing a financial transaction.
/// Transactions are the single source of truth for financial history.
class Transaction {
  final String id;
  final Money amount;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String accountId;
  final String accountName;
  final String? targetAccountId;
  final String? targetAccountName;
  final String remark;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String? merchantId;
  final String? merchantName;
  final bool isUpiVerified;
  final String? upiTxnId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.accountId,
    required this.accountName,
    this.targetAccountId,
    this.targetAccountName,
    required this.remark,
    required this.paymentMethod,
    required this.date,
    this.merchantId,
    this.merchantName,
    this.isUpiVerified = false,
    this.upiTxnId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory creating and validating a Transaction according to domain invariants.
  factory Transaction.validated({
    required String id,
    required Money amount,
    required TransactionType type,
    String? categoryId,
    String? categoryName,
    required String accountId,
    required String accountName,
    String? targetAccountId,
    String? targetAccountName,
    String remark = '',
    PaymentMethod paymentMethod = PaymentMethod.other,
    required DateTime date,
    String? merchantId,
    String? merchantName,
    bool isUpiVerified = false,
    String? upiTxnId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // 1. Invariant: ID must not be empty
    if (id.trim().isEmpty) {
      throw const InvalidTransactionException('Transaction ID cannot be empty.');
    }

    // 2. Invariant: Amount must be greater than zero
    if (amount.minorUnits <= 0) {
      throw const InvalidMoneyException('Transaction amount must be strictly greater than zero.');
    }

    // 3. Invariant: Account ID must not be empty
    if (accountId.trim().isEmpty) {
      throw const InvalidTransactionException('Transaction must be associated with an account.');
    }

    // 4. Invariant: Transfer specifics
    if (type == TransactionType.transfer) {
      if (targetAccountId == null || targetAccountId.trim().isEmpty) {
        throw const InvalidTransactionException('Transfer transaction requires a target destination account.');
      }
      if (targetAccountId == accountId) {
        throw const InvalidTransactionException('Transfer source account cannot be identical to destination account.');
      }
    } else {
      // 5. Invariant: Expense and Income must have a category
      if (categoryId == null || categoryId.trim().isEmpty) {
        throw const InvalidTransactionException('Expense and Income transactions must have an associated category.');
      }
    }

    return Transaction(
      id: id,
      amount: amount,
      type: type,
      categoryId: categoryId ?? '',
      categoryName: categoryName ?? '',
      accountId: accountId,
      accountName: accountName,
      targetAccountId: targetAccountId,
      targetAccountName: targetAccountName,
      remark: remark,
      paymentMethod: paymentMethod,
      date: date,
      merchantId: merchantId,
      merchantName: merchantName,
      isUpiVerified: isUpiVerified,
      upiTxnId: upiTxnId,
      createdAt: createdAt ?? date,
      updatedAt: updatedAt,
    );
  }

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;

  Transaction copyWith({
    String? id,
    Money? amount,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? accountId,
    String? accountName,
    String? targetAccountId,
    String? targetAccountName,
    String? remark,
    PaymentMethod? paymentMethod,
    DateTime? date,
    String? merchantId,
    String? merchantName,
    bool? isUpiVerified,
    String? upiTxnId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      targetAccountName: targetAccountName ?? this.targetAccountName,
      remark: remark ?? this.remark,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      isUpiVerified: isUpiVerified ?? this.isUpiVerified,
      upiTxnId: upiTxnId ?? this.upiTxnId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Transaction(id: $id, type: $type, amount: $amount, date: $date, remark: $remark)';
}
