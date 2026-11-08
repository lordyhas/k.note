import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/utils/save_in_background.dart';

import '../helpers/localized_app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
        localizedApp(
          scaffoldMessengerKey: appMessengerKey,
          home: const Scaffold(body: SizedBox()),
        ),
      );

  testWidgets('a successful write shows nothing', (tester) async {
    await pumpApp(tester);

    saveInBackground(() async {}, failureMessage: 'Not saved');
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a failed write shows a snack bar whose Retry writes again',
      (tester) async {
    await pumpApp(tester);
    var attempts = 0;
    Future<void> write() async {
      attempts++;
      if (attempts == 1) throw Exception('permission-denied');
    }

    saveInBackground(write, failureMessage: 'Not saved');
    await tester.pumpAndSettle();

    expect(find.text('Not saved'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
  });

  testWidgets('canRetry: false shows the message without Retry',
      (tester) async {
    await pumpApp(tester);

    saveInBackground(() async => throw Exception('denied'),
        failureMessage: 'Not saved', canRetry: false);
    await tester.pumpAndSettle();

    expect(find.text('Not saved'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('onFailure returning true replaces the snack bar',
      (tester) async {
    await pumpApp(tester);
    var handled = false;

    saveInBackground(() async => throw Exception('denied'),
        failureMessage: 'Not saved', onFailure: () => handled = true);
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });
}
