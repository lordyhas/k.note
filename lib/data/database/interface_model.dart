import '../authentication_repository.dart';
import 'database_model.dart';

// todo: for commit
//add interface_model.dart & implementation of InterfaceNoteModel
//abstract class, NoteBoxManager class, ChecklistBoxManager class

abstract class InterfaceNoteModel {
  Future<List<NoteModel>> getAllNote();

  Future<List<NoteModel>?> getAllArchivedNote();

  Future<List<NoteModel>?> getAllDeletedNote();

  Future<NoteModel?> getNote({
    required String noteId,
    bool deleted = false,
    bool archived = true,});

  Future<void> addNote({required NoteModel note});

  Future<void> setNote({required NoteModel note});

  Future<void> permanentlyDeleteNote({required String noteId});

  Future<void> deleteNote({required String noteId});

  Future<void> restoreDeletedNote({required String noteId,});

  Future<void> archiveNote({required String noteId, required bool archived,});
}

abstract class InterfaceChecklistModel {
  Future<List<Checklist>> getAllChecklist();

  Future<Checklist?> getChecklist({required String id});

  Future<void> setChecklist({required Checklist checklist});

  Future<void> addChecklist({required Checklist checklist});

  Future<void> deleteChecklist({required String id});

  Future<void> restoreDeletedChecklist({required String id});

  Future<void> permanentlyDeleteChecklist({required String id});
}
