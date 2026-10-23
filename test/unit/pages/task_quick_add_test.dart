import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knote/data/app_bloc/auth_repository/user.dart';
import 'package:knote/data/database/firebase_manager.dart';
import 'package:knote/src/pages/pages/task_quick_add.dart';

const _user = User(id: 'user-1', email: 'a@b.c', name: null, photoMail: null);

void main() {
  late FirebaseManager manager;

  setUp(() {
    manager = FirebaseManager.user(_user, FakeFirebaseFirestore());
  });

  Future<void> pumpSheet(WidgetTester tester) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(body: TaskQuickAddSheet(firebaseManager: manager)),
    ));
  }

  testWidgets('adds tasks without leaving the sheet', (tester) async {
    await pumpSheet(tester);

    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Buy milk'), findsNothing, reason: 'field is cleared');
    expect(find.byType(TaskQuickAddSheet), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Call mom');
    await tester.pump(); // enables the send button
    await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_upward));
    await tester.pump();

    final tasks = await manager.getTasksInCloud();
    expect(
        tasks.map((t) => t.title), unorderedEquals(['Buy milk', 'Call mom']));
    expect(tasks.every((t) => t.list.isEmpty && !t.isAllChecked), isTrue);
  });

  testWidgets('ignores blank titles', (tester) async {
    await pumpSheet(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(await manager.getTasksInCloud(), isEmpty);
    final addButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_upward));
    expect(addButton.onPressed, isNull);
  });
}
