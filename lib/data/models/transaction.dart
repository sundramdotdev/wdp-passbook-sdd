import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late double amount;
  late bool isCredit; // true = income/received, false = expense/debit

  @Index()
  late String type; // 'expense' | 'income' | 'udhar_given' | 'udhar_received'

  late String categoryId;
  String? merchantId; // Links to Merchant.uuid
  late String remark; // User note in any language

  @Index()
  late DateTime date;

  late String incomeSource; // 'pocket_money'|'scholarship'|'salary'|'refund'|'friend_return'|'other'
  // Empty string for expense transactions

  bool isUpiVerified = false; // User confirmed UPI payment done
  String? upiTxnId; // Optional transaction ID from UPI app
  bool isPendingConfirmation = false; // UPI redirected but not yet confirmed by user
  bool isSmsDetected = false; // Auto-detected from SMS
  String? smsRawText; // Original SMS for reference

  late DateTime createdAt;
  DateTime? updatedAt;
}
