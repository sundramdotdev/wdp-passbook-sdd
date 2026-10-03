import '../../domain/entities/money.dart';
import '../../domain/enums/personal_enums.dart';

/// Command to create a new expense transaction.
class CreateExpenseCommand {
  final Money amount;
  final String accountId;
  final String categoryId;
  final String remark;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String? merchantId;
  final String? merchantName;

  const CreateExpenseCommand({
    required this.amount,
    required this.accountId,
    required this.categoryId,
    this.remark = '',
    this.paymentMethod = PaymentMethod.other,
    required this.date,
    this.merchantId,
    this.merchantName,
  });
}

/// Command to create a new income transaction.
class CreateIncomeCommand {
  final Money amount;
  final String accountId;
  final String categoryId;
  final String remark;
  final PaymentMethod paymentMethod;
  final DateTime date;

  const CreateIncomeCommand({
    required this.amount,
    required this.accountId,
    required this.categoryId,
    this.remark = '',
    this.paymentMethod = PaymentMethod.bankTransfer,
    required this.date,
  });
}

/// Command to transfer funds between two accounts.
class CreateTransferCommand {
  final Money amount;
  final String sourceAccountId;
  final String targetAccountId;
  final String remark;
  final DateTime date;

  const CreateTransferCommand({
    required this.amount,
    required this.sourceAccountId,
    required this.targetAccountId,
    this.remark = '',
    required this.date,
  });
}

/// Command to update an existing transaction.
class UpdateTransactionCommand {
  final String id;
  final Money amount;
  final TransactionType type;
  final String accountId;
  final String? targetAccountId;
  final String? categoryId;
  final String remark;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String? merchantId;
  final String? merchantName;

  const UpdateTransactionCommand({
    required this.id,
    required this.amount,
    required this.type,
    required this.accountId,
    this.targetAccountId,
    this.categoryId,
    this.remark = '',
    this.paymentMethod = PaymentMethod.other,
    required this.date,
    this.merchantId,
    this.merchantName,
  });
}
