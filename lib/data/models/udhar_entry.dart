import 'package:isar/isar.dart';

part 'udhar_entry.g.dart';

@collection
class UdharEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String personName;
  String? phone; // Optional
  late double amount;

  late bool iGave; // true = I gave them, false = they gave me

  late String reason;

  @Index()
  late DateTime date;

  bool isSettled = false;
  DateTime? settledAt;
  String? settledVia; // 'cash' | 'upi' | 'adjusted'
  double? settledAmount;
  String? settlementNote;

  String? linkedTransactionId; // If settled via UPI tracked in passbook

  late DateTime createdAt;
}
