import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/core/constants/app_icons.dart';
import 'package:wdp_passbook/core/theme/app_theme.dart';
import 'package:wdp_passbook/core/widgets/wdp_amount_field.dart';
import 'package:wdp_passbook/core/widgets/wdp_badge.dart';
import 'package:wdp_passbook/core/widgets/wdp_button.dart';
import 'package:wdp_passbook/core/widgets/wdp_card.dart';
import 'package:wdp_passbook/core/widgets/wdp_empty_state.dart';
import 'package:wdp_passbook/core/widgets/wdp_error_state.dart';
import 'package:wdp_passbook/core/widgets/wdp_icon_button.dart';

Widget _wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('WdpButton Widget Tests', () {
    testWidgets('renders button text and triggers callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          WdpButton(
            text: 'Save Details',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Save Details'), findsOneWidget);
      await tester.tap(find.text('Save Details'));
      expect(tapped, isTrue);
    });

    testWidgets('displays loading indicator and blocks tap when isLoading is true', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          WdpButton(
            text: 'Submit',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Submit'));
      expect(tapped, isFalse);
    });

    testWidgets('meets minimum 44x44 touch target size', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const WdpButton(
            text: 'Small Button',
            size: WdpButtonSize.small,
          ),
        ),
      );

      final size = tester.getSize(find.byType(WdpButton));
      expect(size.height, greaterThanOrEqualTo(44.0));
      expect(size.width, greaterThanOrEqualTo(44.0));
    });
  });

  group('WdpIconButton Widget Tests', () {
    testWidgets('meets minimum 44x44 touch target and triggers tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          WdpIconButton(
            icon: AppIcons.search,
            tooltip: 'Search',
            onPressed: () => tapped = true,
          ),
        ),
      );

      final size = tester.getSize(find.byType(WdpIconButton));
      expect(size.height, greaterThanOrEqualTo(44.0));
      expect(size.width, greaterThanOrEqualTo(44.0));

      await tester.tap(find.byType(WdpIconButton));
      expect(tapped, isTrue);
    });
  });

  group('WdpCard Widget Tests', () {
    testWidgets('renders child content and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          WdpCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });
  });

  group('WdpBadge Widget Tests', () {
    testWidgets('renders badge text with variant formatting', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const WdpBadge(
            text: 'Income',
            variant: WdpBadgeVariant.income,
          ),
        ),
      );

      expect(find.text('Income'), findsOneWidget);
    });
  });

  group('WdpEmptyState Widget Tests', () {
    testWidgets('renders empty state message and action button', (tester) async {
      bool actionTriggered = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          WdpEmptyState(
            icon: AppIcons.ledger,
            title: 'No Transactions',
            message: 'Your personal passbook has no entries yet.',
            actionText: 'Add First Entry',
            onAction: () => actionTriggered = true,
          ),
        ),
      );

      expect(find.text('No Transactions'), findsOneWidget);
      expect(find.text('Your personal passbook has no entries yet.'), findsOneWidget);
      expect(find.text('Add First Entry'), findsOneWidget);

      await tester.tap(find.text('Add First Entry'));
      expect(actionTriggered, isTrue);
    });
  });

  group('WdpErrorState Widget Tests', () {
    testWidgets('renders error message and triggers retry', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          WdpErrorState(
            message: 'Could not load ledger entries.',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Could not load ledger entries.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('WdpAmountField Widget Tests', () {
    testWidgets('displays currency symbol and enters amount', (tester) async {
      String value = '';
      await tester.pumpWidget(
        _wrapWithTheme(
          WdpAmountField(
            currencySymbol: '₹',
            onChanged: (val) => value = val,
          ),
        ),
      );

      expect(find.text('₹'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1250.50');
      expect(value, '1250.50');
    });
  });
}
