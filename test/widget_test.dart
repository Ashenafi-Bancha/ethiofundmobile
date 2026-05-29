// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ethiofundmobile/main.dart';

void main() {
  testWidgets('EthioFund app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'ethiofund_onboarding_seen': true});
    await tester.pumpWidget(const ProviderScope(child: EthioFundApp()));
    await tester.pump();

    expect(find.text('EthioFund'), findsOneWidget);
    expect(find.text('Crowdfunding for Ethiopia'), findsOneWidget);
  });
}
