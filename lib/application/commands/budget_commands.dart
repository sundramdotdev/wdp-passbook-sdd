import '../../domain/entities/money.dart';
import '../../domain/enums/personal_enums.dart';

class CreateBudgetCommand {
  final String categoryId;
  final String? categoryName;
  final Money limitAmount;
  final BudgetPeriod period;
  final DateTime? referenceDate;

  const CreateBudgetCommand({
    required this.categoryId,
    this.categoryName,
    required this.limitAmount,
    this.period = BudgetPeriod.monthly,
    this.referenceDate,
  });
}
