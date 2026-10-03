import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Financial Analytics',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: analyticsAsync.when(
          data: (summary) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Net Cash Flow Hero
                  ClayContainer(
                    borderRadius: AppRadii.hero,
                    padding: AppSpacing.heroCardPadding,
                    customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Net Cash Flow', style: AppTypography.labelSmall.copyWith(color: AppColors.lightTextMuted)),
                        const SizedBox(height: 8),
                        Text(
                          summary.netCashFlow.format(),
                          style: AppTypography.amountLarge.copyWith(
                            color: summary.netCashFlow.isNegative ? AppColors.expense : AppColors.income,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Inflow', style: AppTypography.caption),
                                  Text(summary.totalIncome.format(), style: AppTypography.amountSmall.copyWith(color: AppColors.income)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Outflow', style: AppTypography.caption),
                                  Text(summary.totalExpense.format(), style: AppTypography.amountSmall.copyWith(color: AppColors.expense)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Top Categories Breakdown
                  Text('Category Breakdown', style: AppTypography.headlineSmall),
                  const SizedBox(height: 12),
                  if (summary.categoryBreakdown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text('No spending category data available.', style: AppTypography.bodyMedium),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summary.categoryBreakdown.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cat = summary.categoryBreakdown[index];
                        return ClayContainer(
                          borderRadius: AppRadii.card,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(cat.categoryName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                  Text(cat.totalAmount.format(), style: AppTypography.amountSmall.copyWith(color: AppColors.expense)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: AppRadii.pillRadius,
                                      child: LinearProgressIndicator(
                                        value: (cat.percentage / 100.0).clamp(0.0, 1.0),
                                        minHeight: 6,
                                        backgroundColor: isDark ? AppColors.navyBorder : AppColors.lightSurfaceSoft,
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandOrange),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('${cat.percentage.toStringAsFixed(1)}%', style: AppTypography.caption),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Error loading analytics: $e'),
        ),
      ),
    );
  }
}

