import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../passbook/providers/passbook_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Analytics', style: AppTypography.titleLarge),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions to analyze'));
          }

          // Simple category aggregation for expenses
          final Map<String, double> categoryTotals = {};
          for (var t in transactions.where((t) => !t.isCredit)) {
            categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + t.amount;
          }

          if (categoryTotals.isEmpty) {
            return const Center(child: Text('No expenses to analyze'));
          }

          final sections = categoryTotals.entries.map((e) {
            return PieChartSectionData(
              value: e.value,
              title: '${e.key}\n${e.value.toStringAsFixed(0)}',
              radius: 100,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              color: _getColorForCategory(e.key),
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Expense by Category', style: AppTypography.titleMedium),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.expense,
      AppColors.info,
      AppColors.udhar,
      Colors.orange,
      Colors.purple,
    ];
    return colors[category.hashCode % colors.length];
  }
}
