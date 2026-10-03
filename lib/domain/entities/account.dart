import 'money.dart';
import '../enums/personal_enums.dart';

/// Domain entity representing a financial account where money is stored.
/// Account balances are derived from transaction records or controlled initial funds.
class Account {
  final String id;
  final String name;
  final AccountType type;
  final String currencyCode;
  final Money balance;
  final String iconName;
  final String colorHex;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.currencyCode = 'INR',
    required this.balance,
    required this.iconName,
    required this.colorHex,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
  });

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? currencyCode,
    Money? balance,
    String? iconName,
    String? colorHex,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currencyCode: currencyCode ?? this.currencyCode,
      balance: balance ?? this.balance,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Account(id: $id, name: $name, type: $type, balance: $balance)';
}
