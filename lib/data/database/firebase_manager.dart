import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_bloc/auth_repository/user.dart';
import 'model/note_model.dart';

/// Reads and writes the signed-in [user]'s data in Cloud Firestore.
///
/// Everything lives under `K_NOTE/general_data/USERS/{user.id}`. Access
/// control is enforced server side by `firestore.rules`, which only lets a
/// user touch the subtree whose id matches their Firebase Auth uid; nothing
/// in this class is a security boundary.
///
/// Errors (network, permission denied, ...) are not swallowed: every method
/// returns the Firestore future so callers can await it and react.
class FirebaseManager {
  final User user;
  final FirebaseFirestore _firestore;

  FirebaseManager._(this.user, [FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;
  FirebaseManager.empty([FirebaseFirestore? firestore])
      : this._(User.empty, firestore);
  FirebaseManager.user(User user, [FirebaseFirestore? firestore])
      : this._(user, firestore);

  factory FirebaseManager.init([User? user, FirebaseFirestore? firestore]) {
    return user == null
        ? FirebaseManager.empty(firestore)
        : FirebaseManager.user(user, firestore);
  }

  void close() {}

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('K_NOTE').doc('general_data').collection('USERS');

  DocumentReference<Map<String, dynamic>> get _userDoc => _users.doc(user.id);

  CollectionReference<Map<String, dynamic>> get _notes =>
      _userDoc.collection('notes');

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _userDoc.collection('tasks');

  /// U S E R   P R O F I L E

  /// Creates or refreshes the user's profile document from their auth data.
  ///
  /// Only descriptive fields are written (see [User.asMap]). Account status,
  /// such as being blocked, is managed by an admin in Firebase Auth and is
  /// never stored where the client can write it.
  Future<void> saveUserProfile() {
    return _userDoc.set(user.asMap(), SetOptions(merge: true));
  }

  /// N O T E S   M E T H O D S

  Future<NoteModel?> getNoteInCloud({required String noteId}) async {
    final data = (await _notes.doc(noteId).get()).data();
    return data == null ? null : NoteModel.fromMap(data);
  }

  /// Notes that are neither in the trash nor archived.
  Future<List<NoteModel>> getAllNoteInCloud() =>
      _queryNotes(isDeleted: false, isArchived: false);

  Future<List<NoteModel>> getAllArchivedNoteInCloud() =>
      _queryNotes(isDeleted: false, isArchived: true);

  /// Notes in the trash.
  Future<List<NoteModel>> getAllDeletedNoteInCloud() =>
      _queryNotes(isDeleted: true, isArchived: false);

  Future<List<NoteModel>> _queryNotes({
    required bool isDeleted,
    required bool isArchived,
  }) async {
    final snapshot = await _notes
        .where('is_deleted', isEqualTo: isDeleted)
        .where('is_archived', isEqualTo: isArchived)
        .get();
    return snapshot.docs.map((doc) => NoteModel.fromMap(doc.data())).toList();
  }

  /// Creates [note], or replaces it entirely if it already exists.
  Future<void> addNoteInCloud({required NoteModel note}) {
    return _notes.doc(note.id).set(note.asMap());
  }

  /// Saves the editable content of a note in a single write.
  Future<void> updateNoteContent({
    required String noteId,
    required String? title,
    required String text,
  }) {
    return _notes.doc(noteId).update({
      'title': title,
      'text': text,
      'last_time': DateTime.now(),
    });
  }

  Future<void> permanentlyDeleteNote({required String noteId}) {
    return _notes.doc(noteId).delete();
  }

  /// Moves a note to the trash.
  Future<void> deleteNote({required String noteId}) {
    return _notes.doc(noteId).update({'is_deleted': true});
  }

  Future<void> restoreDeletedNote({required String noteId}) {
    return _notes.doc(noteId).update({'is_deleted': false});
  }

  Future<void> archiveNote({required String noteId, required bool archived}) {
    return _notes.doc(noteId).update({'is_archived': archived});
  }

  /// T A S K S   M E T H O D S

  /// The user's tasks, emitted again whenever one is added, changed or
  /// deleted (on this device or another one).
  Stream<List<CheckList>> watchTasks() {
    return _tasks.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CheckList.fromMap(doc.data())).toList());
  }

  Future<List<CheckList>> getTasksInCloud() async {
    final snapshot = await _tasks.get();
    return snapshot.docs.map((doc) => CheckList.fromMap(doc.data())).toList();
  }

  Future<void> addTaskInCloud({required CheckList task}) {
    return _tasks.doc(task.id).set(task.asMap());
  }

  Future<void> updateTaskInCloud({required CheckList task}) {
    return _tasks.doc(task.id).update(task.asMap());
  }

  Future<void> deleteTask({required String taskId}) {
    return _tasks.doc(taskId).delete();
  }
}
