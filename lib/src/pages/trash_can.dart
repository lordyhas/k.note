import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:knote/data/app_database.dart';

class NoteTrash extends StatefulWidget {
  const NoteTrash({Key? key}) : super(key: key);

  @override
  _NoteTrashState createState() => _NoteTrashState();
}

class _NoteTrashState extends State<NoteTrash> {
  late final FirebaseManager fbm;

  /*String troncate(String text){
    if(text.length > 150){
      return text.substring(start)
    }
  }*/

  @override
  void initState() {
    super.initState();
    fbm = FirebaseManager(
        BlocProvider.of<AuthenticationBloc>(context).state.user
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = BlocProvider.of<AuthenticationBloc>(context).state.user;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        //backgroundColor: Colors.cyan.withOpacity(opacity),
        title: const Text("Corbeille"),
      ),
      body: FutureBuilder<List<NoteModel>?>(
          future: fbm.getAllDeletedNoteInCloud(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  children: const [
                    Icon(
                      Icons.file_copy_outlined,
                      size: 100,
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text('No document deleted')
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) => SizedBox(
                  height: 120,
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    color: Colors.grey.shade700.withOpacity(0.7),
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

                      onTap: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text(""),
                          content: const SizedBox(
                            //height: 20,
                            child: Text(
                                "Do you want to permanently delete this note ?"
                                "(is an irreversible action) \n Or you want to restore from bin ? "),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Restore'),
                              onPressed: () {
                                fbm.restoreDeletedNote(
                                    noteId: snapshot.data![i].noteId,
                                    //userId: user.id!
                                );
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Delete forever'),
                              onPressed: () {
                                fbm.permanentlyDeleteNote(
                                    noteId: snapshot.data![i].noteId,
                                    //userId: user.id!
                                );
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      //onTap: (){},
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
