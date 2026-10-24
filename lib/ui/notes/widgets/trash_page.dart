import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/notes/widgets/note_text.dart';
import 'package:knote/utils/save_in_background.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});
  static const routeName = "trash";

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  late final FirestoreService fbm;
  late final Stream<List<NoteModel>> _notes;

  @override
  void initState() {
    super.initState();
    fbm = FirestoreService.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user);
    _notes = fbm.watchDeletedNotes();
  }

  void _showActions(NoteModel note) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(note.title?.isNotEmpty == true ? note.title! : 'Untitled'),
        content: const Text(
            'Restore this note, or delete it forever? Deleting it forever '
            "can't be undone."),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete forever'),
            onPressed: () {
              saveInBackground(() => fbm.permanentlyDeleteNote(noteId: note.id),
                  failureMessage: "The note couldn't be deleted");
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Restore'),
            onPressed: () {
              saveInBackground(() => fbm.restoreDeletedNote(noteId: note.id),
                  failureMessage: "The note couldn't be restored");
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Corbeille"),
      ),
      body: StreamBuilder<List<NoteModel>>(
          stream: _notes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("The bin couldn't be loaded"));
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final notes = snapshot.data!;
            if (notes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 100,
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text('The bin is empty')
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16.0),
                itemCount: notes.length,
                itemBuilder: (context, i) => SizedBox(
                  height: 120,
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    color: Colors.grey.shade700.withValues(alpha: 0.7),
                    child: ListTile(
                      title: Text(
                        notes[i].title ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        notePlainText(notes[i].text),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _showActions(notes[i]),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
