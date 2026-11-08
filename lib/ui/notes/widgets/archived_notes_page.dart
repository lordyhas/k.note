import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/notes/widgets/note_editor_page.dart';
import 'package:knote/ui/notes/widgets/note_text.dart';

class ArchivedNotesPage extends StatefulWidget {
  static const routeName = "archived";
  const ArchivedNotesPage({super.key});

  @override
  State<ArchivedNotesPage> createState() => _ArchivedNotesPageState();
}

class _ArchivedNotesPageState extends State<ArchivedNotesPage> {
  late final FirestoreService fbm;
  late final Stream<List<NoteModel>> _notes;

  @override
  void initState() {
    super.initState();
    fbm = FirestoreService.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user);
    _notes = fbm.watchArchivedNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(context.l10n.archiveTitle),
      ),
      body: StreamBuilder<List<NoteModel>>(
          stream: _notes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(context.l10n.archiveLoadError));
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
                      Icons.archive_outlined,
                      size: 100,
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Text(context.l10n.archiveEmpty)
                  ],
                ),
              );
            }
            return ListView.builder(
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
                          onTap: () {
                            GoRouter.of(context).pushNamed(
                                NoteEditorPage.routeName,
                                extra: notes[i]);
                          },
                        ),
                      ),
                    ));
          }),
    );
  }
}
