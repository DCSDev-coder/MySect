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

  testWidgets('LoadingPage plays sticker application animation and triggers onLoaded', (WidgetTester tester) async {
    var loaded = false;
    await tester.pumpWidget(
      MaterialApp(
        home: LoadingPage(
          duration: const Duration(milliseconds: 1000),
          onLoaded: () => loaded = true,
        ),
      ),
    );

    expect(find.byType(Image), findsAtLeastNWidgets(2));
    expect(loaded, isFalse);

    await tester.pump(const Duration(milliseconds: 500));
    expect(loaded, isFalse);

    await tester.pump(const Duration(milliseconds: 550));
    expect(loaded, isTrue);
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

    // Tap Transactions / Submissions tab (index 1) in bottom nav
    final transactionsTab = find.text('Submissions');
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

  testWidgets('HomePage lays out REQUIRED TASKS responsively on desktop width', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Request LHDN Document Stamping'), findsOneWidget);
    expect(find.text('File That Needs to be Submitted'), findsOneWidget);
    expect(find.text('Waiting for Secretary Review'), findsOneWidget);
    expect(find.text('Secretary Replies (Action Needed)'), findsOneWidget);

    // On 1200px desktop width, first 3 cards share the same row (same top Y)
    final y1 = tester.getTopLeft(find.text('Request LHDN Document Stamping')).dy;
    final y2 = tester.getTopLeft(find.text('File That Needs to be Submitted')).dy;
    final y3 = tester.getTopLeft(find.text('Waiting for Secretary Review')).dy;
    final y4 = tester.getTopLeft(find.text('Secretary Replies (Action Needed)')).dy;
    expect((y1 - y2).abs(), lessThan(12.0));
    expect((y2 - y3).abs(), lessThan(12.0));
    expect(y4, greaterThan(y1));
  });
}
