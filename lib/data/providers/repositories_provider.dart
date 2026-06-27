import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db_provider.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/udhar_repository.dart';
import '../repositories/budget_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository?>((ref) {
  final isarAsyncValue = ref.watch(isarProvider);
  if (isarAsyncValue.hasValue) {
    return TransactionRepository(isarAsyncValue.value!);
  }
  return null;
});

final udharRepositoryProvider = Provider<UdharRepository?>((ref) {
  final isarAsyncValue = ref.watch(isarProvider);
  if (isarAsyncValue.hasValue) {
    return UdharRepository(isarAsyncValue.value!);
  }
  return null;
});

final budgetRepositoryProvider = Provider<BudgetRepository?>((ref) {
  final isarAsyncValue = ref.watch(isarProvider);
  if (isarAsyncValue.hasValue) {
    return BudgetRepository(isarAsyncValue.value!);
  }
  return null;
});
