import '../../domain/entities/money.dart';

class CreateGoalCommand {
  final String title;
  final Money targetAmount;
  final DateTime? targetDate;
  final String iconName;
  final String description;

  const CreateGoalCommand({
    required this.title,
    required this.targetAmount,
    this.targetDate,
    this.iconName = 'piggyBank',
    this.description = '',
  });
}

class AddGoalMoneyCommand {
  final String goalId;
  final Money amount;
  final String? note;

  const AddGoalMoneyCommand({
    required this.goalId,
    required this.amount,
    this.note,
  });
}

class RemoveGoalMoneyCommand {
  final String goalId;
  final Money amount;
  final String? note;

  const RemoveGoalMoneyCommand({
    required this.goalId,
    required this.amount,
    this.note,
  });
}
