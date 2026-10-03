import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wdp_passbook/app/app.dart';

void main() {
  testWidgets('WdpApp smoke test initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WdpApp(),
      ),
    );

    // Initial frame pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify root app renders without crashing
    expect(find.byType(WdpApp), findsOneWidget);
  });
}
