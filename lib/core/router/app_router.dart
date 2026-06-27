import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Placeholder imports for screens
// Removed dashboard_screen.dart import
import '../../features/passbook/passbook_screen.dart';
import '../../features/merchants/merchants_screen.dart';
import '../../features/udhar/udhar_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/qr_scanner/qr_scanner_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/add_transaction/upi_payment_flow.dart';
import '../widgets/scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/qr_scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/upi_payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return UpiPaymentFlow(
            upiId: extra['upiId'] ?? '',
            merchantName: extra['merchantName'] ?? 'Unknown',
          );
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/passbook',
            builder: (context, state) => const PassbookScreen(),
          ),
          GoRoute(
            path: '/merchants',
            builder: (context, state) => const MerchantsScreen(),
          ),
          GoRoute(
            path: '/udhar',
            builder: (context, state) => const UdharScreen(),
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/more',
            builder: (context, state) => const MoreScreen(),
          ),
        ],
      ),
    ],
  );
}
