import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knote/data/app_bloc/auth_repository/user.dart';
import 'package:knote/data/database/database_model.dart';
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

  testWidgets('sets a due date from the shortcut menu', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Set due date'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Today ('), findsOneWidget);
    expect(find.textContaining('Next week ('), findsOneWidget);
    expect(find.text('Pick a date'), findsOneWidget);
    expect(find.text('Remove due date'), findsNothing);

    await tester.tap(find.textContaining('Tomorrow ('));
    await tester.pumpAndSettle();
    expect(find.text('Due Tomorrow'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Pay rent');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    final now = DateTime.now();
    final task = (await manager.getTasksInCloud()).single;
    expect(task.dueDate, DateTime(now.year, now.month, now.day + 1));
    expect(find.text('Set due date'), findsOneWidget, reason: 'options reset');
  });

  testWidgets('sets and removes a reminder from the menu', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Remind me'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tomorrow ('), findsOneWidget);
    expect(find.text('Pick a date & time'), findsOneWidget);

    await tester.tap(find.textContaining('Tomorrow ('));
    await tester.pumpAndSettle();
    expect(find.text('Tomorrow, 9:00 AM'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Dentist');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    final now = DateTime.now();
    final task = (await manager.getTasksInCloud()).single;
    expect(task.reminderTime, DateTime(now.year, now.month, now.day + 1, 9));
    expect(find.text('Remind me'), findsOneWidget, reason: 'options reset');
  });

  testWidgets('picks a preset repeat', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();
    for (final label in [
      'Daily',
      'Weekdays',
      'Weekly',
      'Monthly',
      'Yearly',
      'Custom'
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    await tester.tap(find.text('Weekdays'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Stand-up');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect((await manager.getTasksInCloud()).single.repeat, 'Weekdays');
  });

  testWidgets('saves a custom repeat rule', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    expect(find.text('Repeat every'), findsOneWidget);

    await tester.tap(find.byTooltip('More'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final expected = TaskRepeat.custom(
        interval: 2, unit: RepeatUnit.week, weekdays: {DateTime.now().weekday});
    expect(find.text(expected.describe()), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Water plants');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect((await manager.getTasksInCloud()).single.repeat, expected.encode());
  });

  testWidgets('removes a due date', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Set due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Today ('));
    await tester.pumpAndSettle();
    expect(find.text('Due Today'), findsOneWidget);

    await tester.tap(find.text('Due Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove due date'));
    await tester.pumpAndSettle();
    expect(find.text('Set due date'), findsOneWidget);
  });
}
