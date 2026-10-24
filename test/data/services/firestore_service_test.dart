import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/domain/models/user.dart';

const _testUser = User(
  id: 'user-123',
  email: 'test@example.com',
  name: 'Test User',
  photoMail: null,
);

NoteModel _makeNote({
  String id = 'note-1',
  String? title = 'Test Note',
  String? text = 'Test content',
  bool isDeleted = false,
  bool isArchived = false,
  bool isLocked = false,
}) =>
    NoteModel(
      id: id,
      title: title,
      text: text,
      isDeleted: isDeleted,
      isArchived: isArchived,
      isLocked: isLocked,
      email: 'test@example.com',
      creationTime: DateTime(2025, 1, 1),
    );

CheckList _makeTask({String id = 'task-1', String title = 'Test Task'}) =>
    CheckList(
      id: id,
      title: title,
      list: const [TodoItem(text: 'Item 1', isDone: false)],
      creationTime: DateTime(2025, 1, 1),
    );

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService manager;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    manager = FirestoreService.user(_testUser, fakeFirestore);
  });

  group('FirestoreService - Notes', () {
    test('addNoteInCloud then getNoteInCloud returns the note', () async {
      final note = _makeNote();
      await manager.addNoteInCloud(note: note);

      final retrieved = await manager.getNoteInCloud(noteId: note.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, note.id);
      expect(retrieved.title, note.title);
      expect(retrieved.text, note.text);
      expect(retrieved.isDeleted, isFalse);
      expect(retrieved.isArchived, isFalse);
    });

    test('getAllNoteInCloud returns only non-deleted, non-archived notes',
        () async {
      await manager.addNoteInCloud(note: _makeNote(id: 'note-1'));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'note-2', isDeleted: true));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'note-3', isArchived: true));

      final notes = await manager.getAllNoteInCloud();

      expect(notes.length, 1);
      expect(notes.first.id, 'note-1');
    });

    test('getAllNoteInCloud returns empty list when no active notes', () async {
      await manager.addNoteInCloud(
          note: _makeNote(id: 'note-1', isDeleted: true));

      final notes = await manager.getAllNoteInCloud();

      expect(notes, isEmpty);
    });

    test('getAllArchivedNoteInCloud returns only archived non-deleted notes',
        () async {
      await manager.addNoteInCloud(note: _makeNote(id: 'note-1'));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'note-2', isArchived: true));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'note-3', isArchived: true, isDeleted: true));

      final notes = await manager.getAllArchivedNoteInCloud();

      expect(notes.length, 1);
      expect(notes.first.id, 'note-2');
    });

    test('getAllDeletedNoteInCloud returns only deleted non-archived notes',
        () async {
      await manager.addNoteInCloud(note: _makeNote(id: 'note-1'));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'note-2', isDeleted: true));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'note-3', isDeleted: true, isArchived: true));

      final notes = await manager.getAllDeletedNoteInCloud();

      expect(notes.length, 1);
      expect(notes.first.id, 'note-2');
    });

    test('deleteNote marks note as deleted', () async {
      final note = _makeNote();
      await manager.addNoteInCloud(note: note);

      await manager.deleteNote(noteId: note.id);

      final retrieved = await manager.getNoteInCloud(noteId: note.id);
      expect(retrieved!.isDeleted, isTrue);
    });

    test('restoreDeletedNote marks note as not deleted', () async {
      final note = _makeNote(isDeleted: true);
      await manager.addNoteInCloud(note: note);

      await manager.restoreDeletedNote(noteId: note.id);

      final retrieved = await manager.getNoteInCloud(noteId: note.id);
      expect(retrieved!.isDeleted, isFalse);
    });

    test('archiveNote sets isArchived to true', () async {
      final note = _makeNote();
      await manager.addNoteInCloud(note: note);

      await manager.archiveNote(noteId: note.id, archived: true);

      final retrieved = await manager.getNoteInCloud(noteId: note.id);
      expect(retrieved!.isArchived, isTrue);
    });

    test('archiveNote sets isArchived to false', () async {
      final note = _makeNote(isArchived: true);
      await manager.addNoteInCloud(note: note);

      await manager.archiveNote(noteId: note.id, archived: false);

      final retrieved = await manager.getNoteInCloud(noteId: note.id);
      expect(retrieved!.isArchived, isFalse);
    });

    test('permanentlyDeleteNote removes note so it no longer appears',
        () async {
      final note = _makeNote();
      await manager.addNoteInCloud(note: note);

      await manager.permanentlyDeleteNote(noteId: note.id);

      final notes = await manager.getAllNoteInCloud();
      expect(notes, isEmpty);
    });

    test('updateNoteContent saves title, text and modification time', () async {
      final note = _makeNote();
      await manager.addNoteInCloud(note: note);

      await manager.updateNoteContent(
          noteId: note.id, title: 'New Title', text: 'New text body');

      final retrieved = await manager.getNoteInCloud(noteId: note.id);
      expect(retrieved!.title, 'New Title');
      expect(retrieved.text, 'New text body');
      expect(retrieved.modificationTime, isNotNull);
    });

    test('getNoteInCloud returns null for a missing note', () async {
      expect(await manager.getNoteInCloud(noteId: 'missing'), isNull);
    });

    test('archived and trashed notes do not depend on the stored email',
        () async {
      await manager.addNoteInCloud(
          note: NoteModel(id: 'legacy', isArchived: true));
      await manager.addNoteInCloud(
          note: NoteModel(id: 'trashed', isDeleted: true));

      expect((await manager.getAllArchivedNoteInCloud()).single.id, 'legacy');
      expect((await manager.getAllDeletedNoteInCloud()).single.id, 'trashed');
    });

    test("only reads the signed-in user's notes", () async {
      const other = User(
          id: 'user-456', email: 'o@example.com', name: null, photoMail: null);
      await FirestoreService.user(other, fakeFirestore)
          .addNoteInCloud(note: _makeNote(id: 'other-note'));
      await manager.addNoteInCloud(note: _makeNote(id: 'my-note'));

      final notes = await manager.getAllNoteInCloud();

      expect(notes.map((n) => n.id), ['my-note']);
    });

    test('write errors are propagated instead of swallowed', () async {
      await expectLater(
        manager.deleteNote(noteId: 'does-not-exist'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('FirestoreService - live notes', () {
    test('watchNotes emits active notes, most recently modified first',
        () async {
      await manager.addNoteInCloud(
          note: _makeNote(id: 'old')..modificationTime = DateTime(2025, 1, 1));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'new')..modificationTime = DateTime(2025, 6, 1));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'trashed', isDeleted: true));

      final notes = await manager.watchNotes().first;

      expect(notes.map((n) => n.id), ['new', 'old']);
    });

    test('watchNotes emits again when a note moves to the trash', () async {
      await manager.addNoteInCloud(note: _makeNote(id: 'note-1'));

      final emitted = manager.watchNotes().map((notes) => notes.length);
      final expectation = expectLater(emitted, emitsInOrder([1, 0]));
      await Future<void>.delayed(Duration.zero);
      await manager.deleteNote(noteId: 'note-1');

      await expectation;
    });

    test('watchArchivedNotes and watchDeletedNotes filter like their getters',
        () async {
      await manager.addNoteInCloud(note: _makeNote(id: 'active'));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'archived', isArchived: true));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'trashed', isDeleted: true));

      expect((await manager.watchArchivedNotes().first).single.id, 'archived');
      expect((await manager.watchDeletedNotes().first).single.id, 'trashed');
    });
  });

  group('FirestoreService - Profile', () {
    test('saveUserProfile writes only the allowed profile fields', () async {
      await manager.saveUserProfile();

      final doc = await fakeFirestore.doc('users/${_testUser.id}').get();
      expect(doc.data()!.keys, unorderedEquals(_testUser.asMap().keys));
      expect(doc.data()!['email'], _testUser.email);
    });

    test('saveUserProfile keeps the notes of an existing user', () async {
      await manager.addNoteInCloud(note: _makeNote());

      await manager.saveUserProfile();
      await manager.saveUserProfile();

      expect(await manager.getAllNoteInCloud(), hasLength(1));
    });
  });

  group('FirestoreService - Tasks', () {
    test('watchTasks emits again when tasks are added, updated and deleted',
        () async {
      final emissions = <List<String>>[];
      final sub = manager
          .watchTasks()
          .listen((tasks) => emissions.add(tasks.map((t) => t.title).toList()));
      Future<void> settle() => Future<void>.delayed(Duration.zero);

      await settle();
      final task = _makeTask(title: 'First');
      await manager.addTaskInCloud(task: task);
      await settle();
      task.title = 'Renamed';
      await manager.updateTaskInCloud(task: task);
      await settle();
      await manager.deleteTask(taskId: task.id);
      await settle();
      await sub.cancel();

      expect(emissions, [
        <String>[],
        ['First'],
        ['Renamed'],
        <String>[],
      ]);
    });

    test('addTaskInCloud then getTasksInCloud returns the task', () async {
      final task = _makeTask();
      await manager.addTaskInCloud(task: task);

      final tasks = await manager.getTasksInCloud();

      expect(tasks.length, 1);
      expect(tasks.first.id, task.id);
      expect(tasks.first.title, task.title);
      expect(tasks.first.list.length, 1);
      expect(tasks.first.list.first.text, 'Item 1');
    });

    test('getTasksInCloud returns all added tasks', () async {
      await manager.addTaskInCloud(
          task: _makeTask(id: 'task-1', title: 'Task 1'));
      await manager.addTaskInCloud(
          task: _makeTask(id: 'task-2', title: 'Task 2'));

      final tasks = await manager.getTasksInCloud();

      expect(tasks.length, 2);
    });

    test('getTasksInCloud returns empty list when no tasks', () async {
      final tasks = await manager.getTasksInCloud();

      expect(tasks, isEmpty);
    });

    test('updateTaskInCloud updates the task title', () async {
      final task = _makeTask();
      await manager.addTaskInCloud(task: task);

      task.title = 'Updated Title';
      await manager.updateTaskInCloud(task: task);

      final tasks = await manager.getTasksInCloud();
      expect(tasks.first.title, 'Updated Title');
    });

    test('deleteTask removes the task', () async {
      final task = _makeTask();
      await manager.addTaskInCloud(task: task);

      await manager.deleteTask(taskId: task.id);

      final tasks = await manager.getTasksInCloud();
      expect(tasks, isEmpty);
    });

    test('deleteTask only removes the specified task', () async {
      await manager.addTaskInCloud(task: _makeTask(id: 'task-1'));
      await manager.addTaskInCloud(task: _makeTask(id: 'task-2'));

      await manager.deleteTask(taskId: 'task-1');

      final tasks = await manager.getTasksInCloud();
      expect(tasks.length, 1);
      expect(tasks.first.id, 'task-2');
    });
  });
}
