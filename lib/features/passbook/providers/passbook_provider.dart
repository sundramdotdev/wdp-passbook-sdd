import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction.dart';
import '../../../data/providers/repositories_provider.dart';

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchTransactions();
});

final passbookDateFilterProvider = StateProvider<DateTime?>((ref) => null);
final passbookTypeFilterProvider = StateProvider<String>((ref) => 'All');

final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final txnsAsync = ref.watch(transactionsProvider);
  final dateFilter = ref.watch(passbookDateFilterProvider);
  final typeFilter = ref.watch(passbookTypeFilterProvider);

  return txnsAsync.whenData((txns) {
    return txns.where((txn) {
      if (dateFilter != null) {
        if (txn.date.year != dateFilter.year || txn.date.month != dateFilter.month) return false;
      }
      if (typeFilter != 'All') {
        if (typeFilter == 'Income' && !txn.isCredit) return false;
        if (typeFilter == 'Expense' && (txn.isCredit || txn.type.startsWith('udhar'))) return false;
        if (typeFilter == 'Udhar' && !txn.type.startsWith('udhar')) return false;
        if (typeFilter == 'UPI' && !txn.isUpiVerified) return false;
        if (typeFilter == 'SMS' && !txn.remark.contains('SMS Parse')) return false;
        if (typeFilter == 'Pending' && !txn.isPendingConfirmation) return false;
      }
      return true;
    }).toList();
  });
});

final balanceProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsProvider).value ?? [];
  double balance = 0.0;
  for (var txn in txns) {
    if (txn.isCredit) {
      balance += txn.amount;
    } else {
      balance -= txn.amount;
    }
  }
  return balance;
});

final incomeProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsProvider).value ?? [];
  return txns.where((t) => t.isCredit).fold(0.0, (sum, t) => sum + t.amount);
});

final spentProvider = Provider<double>((ref) {
  final txns = ref.watch(transactionsProvider).value ?? [];
  return txns.where((t) => !t.isCredit && t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);
});
