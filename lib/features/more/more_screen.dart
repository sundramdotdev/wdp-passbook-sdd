import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('More Features', style: AppTypography.titleLarge),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.pie_chart, color: AppColors.primary),
            title: const Text('Budget Tracking'),
            subtitle: const Text('Manage your monthly limits'),
            onTap: () => context.go('/budget'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: AppColors.info),
            title: const Text('Analytics & Charts'),
            subtitle: const Text('Visualise your spending'),
            onTap: () => context.go('/analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner, color: AppColors.info),
            title: const Text('QR Scanner'),
            subtitle: const Text('Scan & Pay'),
            onTap: () => context.go('/qr_scanner'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.textSecondary),
            title: const Text('Settings'),
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}
