import '../../domain/entities/money.dart';
import '../../domain/enums/personal_enums.dart';

/// Command to create a new financial account.
class CreateAccountCommand {
  final String name;
  final AccountType type;
  final Money initialBalance;
  final String iconName;
  final String colorHex;
  final String currencyCode;

  const CreateAccountCommand({
    required this.name,
    required this.type,
    this.initialBalance = const Money.zero(),
    this.iconName = 'account_balance',
    this.colorHex = '#3B82F6',
    this.currencyCode = 'INR',
  });
}

/// Command to update an existing account.
class UpdateAccountCommand {
  final String id;
  final String name;
  final AccountType type;
  final String iconName;
  final String colorHex;

  const UpdateAccountCommand({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorHex,
  });
}
