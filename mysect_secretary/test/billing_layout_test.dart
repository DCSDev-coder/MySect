import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secretary_app/screens/settings/secretary_subscription_page.dart';

void main() {
  testWidgets('SecretarySubscriptionPage renders on wide view without overflow', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: SecretarySubscriptionPage(isEmbedded: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active SSM Portfolio'), findsOneWidget);
  });

  testWidgets('SecretarySubscriptionPage renders on mobile view without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: SecretarySubscriptionPage(isEmbedded: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active SSM Portfolio'), findsOneWidget);
  });
}
