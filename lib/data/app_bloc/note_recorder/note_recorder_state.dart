part of 'note_recorder_bloc.dart';


class NoteRecorderState {
  final FirebaseManager firebaseManager;
  final SavingMode savingMode;
  final NoteBoxManager noteBoxManager;

  const NoteRecorderState({
    required this.firebaseManager,
    required this.savingMode,
    required this.noteBoxManager,
    dynamic tag
  });

  factory NoteRecorderState.init() =>  NoteRecorderState(
    firebaseManager: FirebaseManager.user(user: User.empty),
    noteBoxManager: const NoteBoxManager(),
    savingMode: SavingMode.cloudAndLocal,
    tag: null,
  );

  bool get ready => firebaseManager.user == User.empty;
}


