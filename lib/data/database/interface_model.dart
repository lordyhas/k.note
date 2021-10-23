

import '../authentication_repository.dart';
import 'database_model.dart';

abstract class InterfaceNoteModel {


  Future<NoteModel?> getNote({
    required String userId,
    required String noteId
  }) ;

  Future<List<NoteModel>> getAllNote({required User user});

  Future<List<NoteModel>?> getAllArchivedNote({required User user});

  Future<List<NoteModel>?> getAllDeletedNote({required User user});

  Future<void> addNote({
    required NoteModel note,
    required String userId
  });

  Future<void> setNote({required String userId, required NoteModel note});

  Future<void> permanentlyDeleteNote({required String userId, required String noteId});

  Future<void> deleteNote({required String userId, required String noteId});

  Future<void> restoreDeletedNote({
    required String userId,
    required String noteId,
  }) ;

  Future<void> archiveNote({
    required String userId,
    required String noteId,
    required bool archived,
  }) ;
}

abstract class InterfaceChecklistModel{

  Future<List<Checklist>> getAllChecklist({User user});

  Future<Checklist> getChecklist({String userId, required String docId});

  Future<void> setChecklist({String userId, required String docId});

  Future<void> addChecklist({String userId, required String docId});

  Future<void> deleteChecklist({String userId, required String docId});

  Future<void> restoreDeletedChecklist({String userId, required String docId});

  Future<void> permanentlyDeleteChecklist({String userId, String docId});


}