import 'package:bloc/bloc.dart';
import 'package:knote/data/app_database.dart';
import 'package:knote/data/database/interface_model.dart';
import '../../authentication_repository.dart';

part 'note_recorder_state.dart';

class NoteRecorderBloc extends Cubit<NoteRecorderState>
    implements InterfaceNoteModel {

  NoteRecorderBloc() : super(NoteRecorderState.init());

  //User get _user => state.firebaseManager.user;
  bool get isStateReady => state.ready;

  @override
  Future<void> addNote({required NoteModel note}) async {
    switch(state.savingMode){
      case SavingMode.cloud:
         await state.firebaseManager.addNote(note: note);
         break;
      case SavingMode.local:
        await state.noteBoxManager.addNote(note: note);
        break;
      case SavingMode.cloudAndLocal:
        await state.firebaseManager.addNote(note: note);
        await state.noteBoxManager.addNote(note: note);
        break;
    }
  }

  @override
  Future<void> archiveNote({
    required String noteId,
    required bool archived
  }) async {
    switch(state.savingMode){
      case SavingMode.cloud:
        await state.firebaseManager.archiveNote(
            noteId: noteId, archived: archived,
        );
        break;

      case SavingMode.local:
        await state.noteBoxManager.archiveNote(
            noteId: noteId, archived: archived,
        );
        break;
      case SavingMode.cloudAndLocal:
        await state.firebaseManager.archiveNote(
            noteId: noteId, archived: archived,
        );
        await state.noteBoxManager.archiveNote(
            noteId: noteId, archived: archived,
        );
        break;
    }

  }

  @override
  Future<List<NoteModel>?> getAllArchivedNote({
    SavingMode savingMode = SavingMode.local
  }) async {
    switch(state.savingMode){
      case SavingMode.cloud:
        return await state.firebaseManager.getAllArchivedNote();

      case SavingMode.local:
        return state.noteBoxManager.getAllArchivedNote();
      case SavingMode.cloudAndLocal:
         var fbn = (await state.firebaseManager.getAllArchivedNote());
         var nbn = (await state.noteBoxManager.getAllArchivedNote());
         List<NoteModel> list = [];
         return list..addAll(fbn!)..addAll(nbn!);

    }
  }

  @override
  Future<List<NoteModel>?> getAllDeletedNote() async {
    switch(state.savingMode){
      case SavingMode.cloud:
        return await state.firebaseManager.getAllDeletedNote();

      case SavingMode.local:
        return await state.noteBoxManager.getAllDeletedNote();
      case SavingMode.cloudAndLocal:
        var fbn = (await state.firebaseManager.getAllDeletedNote());
        var nbn = (await state.noteBoxManager.getAllDeletedNote());
        List<NoteModel> list = [];
        return list..addAll(fbn??[])..addAll(nbn??[]);

    }
  }

  @override
  Future<List<NoteModel>> getAllNote() async {
    switch(state.savingMode){
      case SavingMode.cloud:
        return (await state.firebaseManager.getAllNote());
      case SavingMode.local:
        return (await state.noteBoxManager.getAllNote());
      case SavingMode.cloudAndLocal:
        var fbn = (await state.firebaseManager.getAllNote());
        var nbn = (await state.noteBoxManager.getAllNote());
        List<NoteModel> list = [];
        return list..addAll(fbn)..addAll(nbn);

    }
  }

  @override
  Future<NoteModel?> getNote({
    required String noteId,
    bool deleted = false,
    bool archived = true}) async {
    switch(state.savingMode){
      case SavingMode.cloud:
        return (await state.firebaseManager.getNote(
          noteId: noteId,
          deleted: deleted,
          archived: archived,
        ));
      case SavingMode.local:
        return (await state.noteBoxManager.getNote(
          noteId: noteId,
          deleted: deleted,
          archived: archived,
        )) ;
      case SavingMode.cloudAndLocal:
        /*var fbn = (await state.firebaseManager.getNote(
          noteId: noteId,
          deleted: deleted,
          archived: archived,
        ));*/
        var nbn = (await state.noteBoxManager.getNote(
          noteId: noteId,
          deleted: deleted,
          archived: archived,
        ));
        //List<NoteModel> list = [];
        return nbn;

    }
  }

  @override
  Future<void> deleteNote({required String noteId}) async {
    switch(state.savingMode){
      case SavingMode.cloud:
        await state.firebaseManager.deleteNote(noteId: noteId);
        break;

      case SavingMode.local:
        await state.noteBoxManager.deleteNote(noteId: noteId);
        break;
      case SavingMode.cloudAndLocal:
        await state.firebaseManager.deleteNote(noteId: noteId);
        await state.noteBoxManager.deleteNote(noteId: noteId);
        break;
    }
  }

  @override
  Future<void> permanentlyDeleteNote({required String noteId}) async {
    switch(state.savingMode){
      case SavingMode.cloud:
        await state.firebaseManager.permanentlyDeleteNote(noteId: noteId);
        break;

      case SavingMode.local:
        await state.noteBoxManager.permanentlyDeleteNote(noteId: noteId);
        break;
      case SavingMode.cloudAndLocal:
        await state.firebaseManager.permanentlyDeleteNote(noteId: noteId);
        await state.noteBoxManager.permanentlyDeleteNote(noteId: noteId);
        break;
    }
  }

  @override
  Future<void> restoreDeletedNote({required String noteId}) async {
    switch(state.savingMode){
      case SavingMode.cloud:
        await state.firebaseManager.restoreDeletedNote(noteId: noteId);
        break;

      case SavingMode.local:
        await state.noteBoxManager.restoreDeletedNote(noteId: noteId);
        break;
      case SavingMode.cloudAndLocal:
        await state.firebaseManager.restoreDeletedNote(noteId: noteId);
        await state.noteBoxManager.restoreDeletedNote(noteId: noteId);
        break;
    }
  }

  @override
  Future<void> setNote({required NoteModel note}) async {
    switch(state.savingMode){
      case SavingMode.cloud:
        await state.firebaseManager.setNote(note: note);
        break;

      case SavingMode.local:
        await state.noteBoxManager.setNote(note: note);
        break;
      case SavingMode.cloudAndLocal:
        await state.firebaseManager.setNote(note: note);
        await state.noteBoxManager.setNote(note: note);
        break;
    }
  }
}
