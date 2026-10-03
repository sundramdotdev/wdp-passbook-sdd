import '../../domain/entities/money.dart';
import '../../domain/enums/personal_enums.dart';

/// Typed filter for querying transactions without loosely typed Maps.
class TransactionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final String? accountId;
  final TransactionType? type;
  final String? searchQuery;
  final Money? minAmount;
  final Money? maxAmount;

  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.accountId,
    this.type,
    this.searchQuery,
    this.minAmount,
    this.maxAmount,
  });

  /// Factory creating an empty/unfiltered filter.
  const TransactionFilter.empty()
      : startDate = null,
        endDate = null,
        categoryId = null,
        accountId = null,
        type = null,
        searchQuery = null,
        minAmount = null,
        maxAmount = null;

  bool get isActive =>
      startDate != null ||
      endDate != null ||
      (categoryId != null && categoryId!.isNotEmpty) ||
      (accountId != null && accountId!.isNotEmpty) ||
      type != null ||
      (searchQuery != null && searchQuery!.trim().isNotEmpty) ||
      minAmount != null ||
      maxAmount != null;

  TransactionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
    TransactionType? type,
    String? searchQuery,
    Money? minAmount,
    Money? maxAmount,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearCategoryId = false,
    bool clearAccountId = false,
    bool clearType = false,
    bool clearSearchQuery = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return TransactionFilter(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      type: clearType ? null : (type ?? this.type),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionFilter &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          categoryId == other.categoryId &&
          accountId == other.accountId &&
          type == other.type &&
          searchQuery == other.searchQuery &&
          minAmount == other.minAmount &&
          maxAmount == other.maxAmount;

  @override
  int get hashCode => Object.hash(
        startDate,
        endDate,
        categoryId,
        accountId,
        type,
        searchQuery,
        minAmount,
        maxAmount,
      );
}
