import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysect/main.dart';
import 'package:mysect/mobile_app/home/home_page.dart';
import 'package:mysect/mobile_app/more/more_page.dart';
import 'package:mysect/mobile_app/splash/loading_page.dart';
import 'package:mysect/mobile_app/widgets/mysect_stroke_logo_loader.dart';

void main() {
  testWidgets('MySectApp renders LoadingPage with brand assembly animation', (WidgetTester tester) async {
    await tester.pumpWidget(const MySectApp());
    expect(find.byType(LoadingPage), findsOneWidget);
  });

  testWidgets('Tapping Log out in MorePage shows confirmatory popup', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MorePage(),
      ),
    );
    await tester.pumpAndSettle();

    final logoutButton = find.text('Log out');
    expect(logoutButton, findsOneWidget);

    await tester.ensureVisible(logoutButton);
    await tester.pumpAndSettle();
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to log out? You will need to enter your credentials again.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Yes, Log out'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to log out? You will need to enter your credentials again.'), findsNothing);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('HomePage tab switching shows 2000ms looping stroke loader', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RepeatingStrokeLogoLoader), findsNothing);

    // Tap Transactions tab (index 1) in bottom nav
    final transactionsTab = find.text('SSM Filings');
    expect(transactionsTab, findsOneWidget);
    await tester.tap(transactionsTab);
    await tester.pump();

    // Loader is visible during the 2000ms transition
    expect(find.byType(RepeatingStrokeLogoLoader), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);

    // Advance 1000ms: still loading
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(RepeatingStrokeLogoLoader), findsOneWidget);

    // Advance remaining 1000ms: loading completes
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump();
    expect(find.byType(RepeatingStrokeLogoLoader), findsNothing);
  });
}

