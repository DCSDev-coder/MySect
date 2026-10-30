import 'package:flutter_test/flutter_test.dart';
import 'package:secretary_app/main.dart';
import 'package:secretary_app/screens/main_navigation_shell.dart';

void main() {
  testWidgets('Secretary App renders dashboard and review queue navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MySectSecretaryApp(home: MainNavigationShell()));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Review Queue'), findsOneWidget);
    expect(find.text('Companies'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Tapping Log Out in Profile shows confirmation popup', (WidgetTester tester) async {
    await tester.pumpWidget(const MySectSecretaryApp(home: MainNavigationShell(initialIndex: 3)));
    await tester.pumpAndSettle();

    // Verify Log Out button is visible
    final logoutButton = find.text('Log Out');
    expect(logoutButton, findsOneWidget);

    // Scroll into view & Tap Log Out
    await tester.ensureVisible(logoutButton);
    await tester.pumpAndSettle();
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Verify confirmation popup appears
    expect(find.text('Are you sure you want to log out? You will need to enter your credentials again.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Yes, Log out'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify popup is dismissed and profile is still there
    expect(find.text('Are you sure you want to log out? You will need to enter your credentials again.'), findsNothing);
    expect(find.text('Log Out'), findsOneWidget);
  });
}
