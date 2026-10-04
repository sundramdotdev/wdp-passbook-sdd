import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings & Security',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Finance Management', style: AppTypography.labelMedium.copyWith(color: AppColors.brandOrange)),
              const SizedBox(height: 8),
              ClayContainer(
                borderRadius: AppRadii.card,
                padding: EdgeInsets.zero,
                customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined),
                      title: const Text('Manage Accounts'),
                      subtitle: const Text('Bank accounts, cash, and digital wallets'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/accounts'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: const Text('Manage Categories'),
                      subtitle: const Text('Custom expense and income categories'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/categories'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Preferences', style: AppTypography.labelMedium.copyWith(color: AppColors.brandOrange)),
              const SizedBox(height: 8),
              ClayContainer(
                borderRadius: AppRadii.card,
                padding: EdgeInsets.zero,
                customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      trailing: const Text('English (IN)', style: TextStyle(color: AppColors.lightTextMuted)),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.currency_rupee),
                      title: const Text('Currency'),
                      trailing: const Text('INR (₹)', style: TextStyle(color: AppColors.lightTextMuted)),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Security & Privacy', style: AppTypography.labelMedium.copyWith(color: AppColors.brandOrange)),
              const SizedBox(height: 8),
              ClayContainer(
                borderRadius: AppRadii.card,
                padding: EdgeInsets.zero,
                customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: false,
                      onChanged: (val) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App Lock PIN configuration enabled.')),
                        );
                      },
                      secondary: const Icon(Icons.lock_outline),
                      title: const Text('App Lock / PIN'),
                      subtitle: const Text('Require PIN to open WDP Passbook'),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: false,
                      onChanged: (val) {},
                      secondary: const Icon(Icons.fingerprint),
                      title: const Text('Biometric Auth'),
                      subtitle: const Text('Use Fingerprint or Face ID'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Data & Backup', style: AppTypography.labelMedium.copyWith(color: AppColors.brandOrange)),
              const SizedBox(height: 8),
              ClayContainer(
                borderRadius: AppRadii.card,
                padding: EdgeInsets.zero,
                customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.file_download_outlined),
                      title: const Text('Export Data (CSV / JSON)'),
                      subtitle: const Text('Generate offline financial backup'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting financial ledger data...')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.cloud_upload_outlined),
                      title: const Text('Cloud Backup'),
                      subtitle: const Text('Google Drive Backup (Readiness API)'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google Drive backup abstraction ready.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Center(
                child: Column(
                  children: [
                    Text('WDP Passbook v1.0.3+4', style: AppTypography.caption),
                    const SizedBox(height: 4),
                    Text('Production-Grade Personal Financial Engine', style: AppTypography.caption.copyWith(color: AppColors.lightTextMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

