import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
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
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(note.title?.isNotEmpty == true ? note.title! : l10n.untitled),
        content: Text(l10n.binDialogContent),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: AppColors.of(context).danger),
            child: Text(l10n.binDeleteForever),
            onPressed: () {
              saveInBackground(() => fbm.permanentlyDeleteNote(noteId: note.id),
                  failureMessage: l10n.noteDeleteFailed);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(l10n.binRestore),
            onPressed: () {
              saveInBackground(() => fbm.restoreDeletedNote(noteId: note.id),
                  failureMessage: l10n.noteRestoreFailed);
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
        title: Text(context.l10n.binTitle),
      ),
      body: StreamBuilder<List<NoteModel>>(
          stream: _notes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(context.l10n.binLoadError));
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final notes = snapshot.data!;
            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      size: 100,
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Text(context.l10n.binEmpty)
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
                    color: AppColors.of(context).tile,
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
