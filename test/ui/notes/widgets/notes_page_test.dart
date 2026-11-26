import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/folder.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/domain/models/user_preferences.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/preferences_scope.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/utils/save_in_background.dart';

import '../../../helpers/localized_app.dart';

const _user = User(id: 'user-1', email: 'a@b.c', name: null, photoMail: null);

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late FirestoreService manager;
  late AuthenticationBloc authBloc;

  setUp(() async {
    final authRepository = MockAuthRepository();
    when(() => authRepository.currentUser).thenReturn(_user);
    when(() => authRepository.user).thenAnswer((_) => const Stream.empty());
    authBloc = AuthenticationBloc(authRepository: authRepository);

    manager = FirestoreService.user(_user, FakeFirebaseFirestore());
    await manager.addNoteInCloud(
        note: NoteModel(id: 'n1', title: 'Été à Paris', text: 'Le Louvre'));
    await manager.addNoteInCloud(
        note: NoteModel(id: 'n2', title: 'Groceries', text: 'Milk'));
  });

  tearDown(() => authBloc.close());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(BlocProvider.value(
      value: authBloc,
      child: localizedApp(
        scaffoldMessengerKey: appMessengerKey,
        home: NotesPage(firebaseManager: manager),
      ),
    ));
    await tester.pump(); // first snapshot
    await tester.pump(const Duration(seconds: 1)); // cards fade in
  }

  Finder searchField() => find.byKey(const Key('homePage_search_textField'));

  testWidgets('filters notes while typing, ignoring accents', (tester) async {
    await pumpPage(tester);
    expect(find.text('Groceries'), findsOneWidget);

    await tester.enterText(searchField(), 'ete');
    await tester.pump();

    expect(find.text('Été à Paris'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
  });

  testWidgets('says when nothing matches, and clears the search',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(searchField(), 'zzz');
    await tester.pump();
    expect(find.text('No notes match "zzz"'), findsOneWidget);

    await tester.tap(find.byKey(const Key('homePage_search_clear')));
    await tester.pump();
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Été à Paris'), findsOneWidget);
  });

  testWidgets('back clears the search before leaving', (tester) async {
    await pumpPage(tester);

    await tester.enterText(searchField(), 'milk');
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('Été à Paris'), findsOneWidget);
    expect(find.byType(NotesPage), findsOneWidget);
  });

  testWidgets('a note moved to the bin can be restored with Undo',
      (tester) async {
    await pumpPage(tester);

    // The card's InkWell is stacked over its text and takes the gesture.
    await tester.longPress(find.text('Groceries'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to bin'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsNothing);
    expect(find.text('"Groceries" moved to the bin'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(await manager.getAllDeletedNoteInCloud(), isEmpty);
  });

  testWidgets('follows the layout preference, and the toggle saves it',
      (tester) async {
    final saved = <UserPreferences>[];
    await tester.pumpWidget(PreferencesScope(
      preferences: const UserPreferences(notesLayout: NotesLayout.grid),
      onChanged: (preferences) async => saved.add(preferences),
      child: BlocProvider.value(
        value: authBloc,
        child: localizedApp(
          scaffoldMessengerKey: appMessengerKey,
          home: NotesPage(firebaseManager: manager),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // In a grid, the toggle offers the list.
    expect(find.byTooltip('List view'), findsOneWidget);
    await tester.tap(find.byTooltip('List view'));
    await tester.pump();

    expect(saved.single.notesLayout, NotesLayout.list);
    expect(find.byTooltip('Grid view'), findsOneWidget);
  });

  group('folders', () {
    setUp(() async {
      await manager.saveFolder(const NoteFolder(id: 'f1', name: 'Travel'));
      await manager.moveNoteToFolder(noteId: 'n1', folderId: 'f1');
    });

    testWidgets('a folder shows only its notes', (tester) async {
      await pumpPage(tester);
      expect(find.text('Groceries'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('folderChip_f1')));
      await tester.pump();
      expect(find.text('Été à Paris'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);

      await tester.tap(find.text('All'));
      await tester.pump();
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('a note can be moved to a folder, with Undo', (tester) async {
      await pumpPage(tester);

      await tester.longPress(find.text('Groceries'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('noteMenu_moveToFolder')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('folderPicker_f1')));
      await tester.pumpAndSettle();

      expect(find.text('"Groceries" moved to Travel'), findsOneWidget);
      expect((await manager.getNoteInCloud(noteId: 'n2'))!.folderId, 'f1');

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect((await manager.getNoteInCloud(noteId: 'n2'))!.folderId, isNull);
    });

    testWidgets('a new folder is created and selected', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('notes_newFolder')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('folderName_textField')), '  Recipes ');
      await tester.pump(); // enables Save
      await tester.tap(find.byKey(const Key('folderName_save')));
      await tester.pumpAndSettle();

      final folders = await manager.watchFolders().first;
      expect(folders.map((f) => f.name), ['Recipes', 'Travel']);
      // The new folder is shown, and it is empty.
      expect(find.text('No notes in this folder yet.'), findsOneWidget);
    });

    testWidgets('deleting a folder keeps its notes and shows all notes',
        (tester) async {
      await pumpPage(tester);
      await tester.tap(find.byKey(const ValueKey('folderChip_f1')));
      await tester.pump();

      await tester.longPress(find.byKey(const ValueKey('folderChip_f1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete folder'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('folderDelete_confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('folderChip_f1')), findsNothing);
      expect(find.text('Été à Paris'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect((await manager.getNoteInCloud(noteId: 'n1'))!.folderId, isNull);
    });
  });
}
