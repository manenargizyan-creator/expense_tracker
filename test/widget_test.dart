import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Finance app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceApp());

    expect(find.byType(FinanceApp), findsOneWidget);
  });
}
