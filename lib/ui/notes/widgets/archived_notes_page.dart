import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/notes/widgets/note_editor_page.dart';

class ArchivedNotesPage extends StatefulWidget {
  static const routeName = "archived";
  const ArchivedNotesPage({super.key});

  @override
  State<ArchivedNotesPage> createState() => _ArchivedNotesPageState();
}

class _ArchivedNotesPageState extends State<ArchivedNotesPage> {
  late final FirestoreService fbm;

  @override
  void initState() {
    super.initState();
    fbm = FirestoreService.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<NoteModel>?>(
          future: fbm.getAllArchivedNoteInCloud(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data!.isEmpty) {
              return const Center(
                child: SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied_rounded,
                        size: 100,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text('No document archived')
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) => SizedBox(
                      height: 120,
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        color: Colors.grey.shade700.withValues(alpha: 0.7),
                        child: ListTile(
                            //leading: const Icon(Icons.delete_sweep_outlined, size: 42,),
                            title: Text(
                              "${snapshot.data![i].title}",
                              style: const TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              "${snapshot.data![i].text}",
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              GoRouter.of(context).pushNamed(NoteEditorPage.routeName, extra: snapshot.data![i]);
                             },
                            ),
                      ),
                    ));
          }),
    );
  }
}
