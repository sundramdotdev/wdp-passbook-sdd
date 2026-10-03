enum TransactionType {
  expense,
  income,
  transfer;

  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}

enum PaymentMethod {
  cash,
  upi,
  bankTransfer,
  creditCard,
  debitCard,
  wallet,
  other;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

enum AccountType {
  cash,
  bank,
  wallet,
  card,
  other;

  String get displayName {
    switch (this) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.wallet:
        return 'Digital Wallet';
      case AccountType.card:
        return 'Card';
      case AccountType.other:
        return 'Other';
    }
  }
}

enum CategoryType {
  expense,
  income;
}

enum BudgetPeriod {
  monthly,
  weekly,
  yearly;
}

enum GoalStatus {
  active,
  achieved,
  completed,
  paused,
  cancelled,
  archived;

  String get displayName {
    switch (this) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.achieved:
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.paused:
        return 'Paused';
      case GoalStatus.cancelled:
        return 'Cancelled';
      case GoalStatus.archived:
        return 'Archived';
    }
  }

  bool get isCompleted => this == GoalStatus.completed || this == GoalStatus.achieved;
}

enum SyncStatus {
  localOnly,
  pendingSync,
  synced,
  error;
}

