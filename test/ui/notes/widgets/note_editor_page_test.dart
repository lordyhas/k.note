import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/notes/widgets/note_editor_page.dart';

const _user = User(id: 'user-1', email: 'a@b.c', name: null, photoMail: null);

void main() {
  late FirestoreService manager;

  setUp(() {
    manager = FirestoreService.user(_user, FakeFirebaseFirestore());
  });

  /// Opens the editor above a home page, as the router does.
  Future<void> openEditor(WidgetTester tester, {NoteModel? note}) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) =>
                  NoteEditorPage(note: note, firebaseManager: manager))),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder titleField() => find.byType(TextField).first;

  testWidgets('saves a new note when leaving with the back button',
      (tester) async {
    await openEditor(tester);

    await tester.enterText(titleField(), 'Groceries');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget, reason: 'editor closed');
    final notes = await manager.getAllNoteInCloud();
    expect(notes.single.title, 'Groceries');
  });

  testWidgets('saves shortly after typing stops, without leaving',
      (tester) async {
    await openEditor(tester);

    await tester.enterText(titleField(), 'Draft');
    await tester.pump(const Duration(milliseconds: 500));
    expect(await manager.getAllNoteInCloud(), isEmpty);

    await tester.pump(const Duration(milliseconds: 600));
    expect((await manager.getAllNoteInCloud()).single.title, 'Draft');
  });

  testWidgets('saves when the app goes to the background', (tester) async {
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));
    await openEditor(tester);

    await tester.enterText(titleField(), 'Before the call');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    expect((await manager.getAllNoteInCloud()).single.title,
        'Before the call');
  });

  testWidgets('does not write when an opened note is left unchanged',
      (tester) async {
    final lastEdit = DateTime(2025, 1, 1);
    final note = NoteModel(
      id: 'note-1',
      title: 'Untouched',
      text: 'Body',
      creationTime: lastEdit,
      modificationTime: lastEdit,
    );
    await manager.addNoteInCloud(note: note);
    await openEditor(tester, note: note);

    await tester.tap(find.byTooltip('Done'));
    await tester.pumpAndSettle();

    final saved = await manager.getNoteInCloud(noteId: 'note-1');
    expect(saved!.modificationTime, lastEdit);
  });

  testWidgets('does not create a note that was left empty', (tester) async {
    await openEditor(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(await manager.getAllNoteInCloud(), isEmpty);
  });
}
