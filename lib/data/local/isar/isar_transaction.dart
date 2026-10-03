import 'package:isar/isar.dart';

part 'isar_transaction.g.dart';

@collection
class IsarTransaction {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late int minorUnits; // Amount in minor units (e.g. paisa)
  String currencyCode = 'INR';

  @Index()
  late String type; // 'expense' | 'income' | 'transfer'

  @Index()
  late String categoryId;
  late String categoryName;

  @Index()
  late String accountId;
  late String accountName;

  @Index()
  String? targetAccountId;
  String? targetAccountName;

  late String remark;

  @Index()
  late String paymentMethod;

  @Index()
  late DateTime date;

  String? merchantId;
  String? merchantName;

  bool isUpiVerified = false;
  String? upiTxnId;

  late DateTime createdAt;
  DateTime? updatedAt;
}
