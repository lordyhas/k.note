import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knote/data/app_bloc/auth_repository/user.dart';
import 'package:knote/data/database/firebase_manager.dart';
import 'package:knote/data/database/model/note_model.dart';

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
  late FirebaseManager manager;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    manager = FirebaseManager.user(_testUser, fakeFirestore);
  });

  group('FirebaseManager - Notes', () {
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

    test(
        'getAllArchivedNoteInCloud returns only archived non-deleted notes',
        () async {
      await manager.addNoteInCloud(note: _makeNote(id: 'note-1'));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'note-2', isArchived: true));
      await manager.addNoteInCloud(
          note: _makeNote(id: 'note-3', isArchived: true, isDeleted: true));

      final notes = await manager.getAllArchivedNoteInCloud();

      expect(notes, isNotNull);
      expect(notes!.length, 1);
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

      expect(notes, isNotNull);
      expect(notes!.length, 1);
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

    test('permanentlyDeleteNote removes note so it no longer appears', () async {
      final note = _makeNote();
      await manager.addNoteInCloud(note: note);

      await manager.permanentlyDeleteNote(noteId: note.id);

      final notes = await manager.getAllNoteInCloud();
      expect(notes, isEmpty);
    });

    test('updateNoteTitle changes the title', () async {
      final note = _makeNote();
      await manager.addNoteInCloud(note: note);

      await manager.updateNoteTitle(
          userId: _testUser.id, id: note.id, value: 'New Title');

      final retrieved = await manager.getNoteInCloud(noteId: note.id);
      expect(retrieved!.title, 'New Title');
    });

    test('updateNoteText changes the text', () async {
      final note = _makeNote();
      await manager.addNoteInCloud(note: note);

      await manager.updateNoteText(
          userId: _testUser.id, id: note.id, value: 'New text body');

      final retrieved = await manager.getNoteInCloud(noteId: note.id);
      expect(retrieved!.text, 'New text body');
    });
  });

  group('FirebaseManager - Tasks', () {
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
      await manager.addTaskInCloud(task: _makeTask(id: 'task-1', title: 'Task 1'));
      await manager.addTaskInCloud(task: _makeTask(id: 'task-2', title: 'Task 2'));

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
