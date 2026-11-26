import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/task_repeat.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/tasks/widgets/task_editor_page.dart';

import '../../../helpers/localized_app.dart';

const _user = User(id: 'user-1', email: 'a@b.c', name: null, photoMail: null);

void main() {
  Future<void> pumpEditor(WidgetTester tester, {String? repeat}) {
    return tester.pumpWidget(localizedApp(
      home: TaskEditorPage(
        task: CheckList(title: 'Declare taxes', list: const [], repeat: repeat),
        firebaseManager: FirestoreService.user(_user, FakeFirebaseFirestore()),
      ),
    ));
  }

  testWidgets('picks a preset repeat from the menu', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();
    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Never repeat'), findsNothing,
        reason: 'nothing to remove');
    await tester.tap(find.text('Weekdays'));
    await tester.pumpAndSettle();

    expect(find.text('Weekdays'), findsOneWidget);
  });

  testWidgets('sets a custom repeat rule', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    expect(find.text('Repeat every'), findsOneWidget);

    await tester.tap(find.byTooltip('More'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The dialog starts on today; January 1, 2024 is a Monday.
    final weekday =
        DateFormat.E('en').format(DateTime(2024, 1, DateTime.now().weekday));
    expect(find.text('Every 2 weeks on $weekday'), findsOneWidget);
  });

  testWidgets('opens the custom dialog on the current custom rule',
      (tester) async {
    await pumpEditor(tester,
        repeat: const TaskRepeat.custom(interval: 3, unit: RepeatUnit.month)
            .encode());
    expect(find.text('Every 3 months'), findsOneWidget);

    await tester.tap(find.text('Every 3 months'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('months'), findsOneWidget);
  });

  testWidgets('removes the repeat with Never', (tester) async {
    await pumpEditor(tester, repeat: TaskRepeat.daily.encode());

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Never repeat'));
    await tester.pumpAndSettle();

    expect(find.text('Repeat'), findsOneWidget);
  });
}
