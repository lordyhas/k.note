


import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:knote/data/app_database.dart';
import 'package:utils_component/utils_component.dart';


class TextEditor extends StatefulWidget {
  final NoteModel
  ? note;
  final bool isNewNote;

  const TextEditor({
    this.note,
    this.isNewNote = false,
    Key? key
  }) : super(key: key);


  //const TextEditor({this.note, this.isNewNote = false});

  static Route route({NoteModel? note}) {
    return MaterialPageRoute<void>(builder: (_) => TextEditor(note:note));
  }
  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor>  {

  late NoteModel _noteModel;
  late TextEditingController _textController;
  late TextEditingController _titleController;
  final FirebaseManager _firebaseManager =  FirebaseManager();
  late final user;

  bool isNoteInCloud = false;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final String unique = now.microsecondsSinceEpoch.toString();
    user = BlocProvider.of<AuthenticationBloc>(context).state.user;
    if(widget.note != null) {
      _noteModel = widget.note!;
      //print('(${_noteModel.text})#########');
      _textController = TextEditingController(text: _noteModel.text);
      _titleController = TextEditingController(text: _noteModel.title );
      isNoteInCloud = true;
    }
    else{
      _textController = TextEditingController();
      _titleController = TextEditingController();

      _noteModel = NoteModel(
          id:  unique,
          email: user.email,
          creationTime: DateTime.now(),
          modificationTime: DateTime.now(),
      );


      Log.i('initState() #########');
    }

    //_noteModel = _firebaseManager.getNoteInCloud(noteId)

    ///WidgetsBinding.instance!.addObserver(this);

  }

  setNote(title,text){
    if(!isNoteInCloud) return;
    setState(() {
      _noteModel.title = title ;
      _noteModel.text = text ;
      _noteModel.modificationTime = DateTime.now();
    });

    _firebaseManager.updateNoteTitle(
        userId: user.id,
        id: _noteModel.id,
        value: _noteModel.title!
    );

    _firebaseManager.updateNoteText(
        userId: user.id,
        id: _noteModel.id,
        value: _noteModel.text!
    );

    _firebaseManager.updateLastModificationTime(
        docId: _noteModel.id
    );

  }

  /*@override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        Log.i('++++++++++++ resumed ++++++++++++');
        break;
      case AppLifecycleState.inactive:
        Log.i('++++++++++++ inactive ++++++++++++');
        break;
      case AppLifecycleState.paused:
        Log.i('++++++++++++ paused ++++++++++++');
        setNote(_titleController.text,_textController.text);

        //print('=== ${_noteModel.text} ===');
        break;
      case AppLifecycleState.detached:

        Log.i('++++++++++++ detached ++++++++++++');
        break;
    }
  }*/

  @override
  void dispose() {
    //setNote(_titleController.text,_textController.text);

    //WidgetsBinding.instance!.removeObserver(this);
    super.dispose();

  }


  //void addNote() async {}

  @override
  Widget build(BuildContext context) {
    const List<Color> colors = [
      Colors.cyan,
      Colors.black,
      Colors.yellow,
      Colors.grey,
      Colors.deepPurpleAccent,
      Colors.red,
    ];
    int count = 0;
    int countTitle = 0;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.done),
          onPressed: (){
            setNote(_titleController.text,_textController.text);
            //FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.style, color: Color(_noteModel.colorValue),),
            onPressed: (){
              showDialog(context: context,
                  builder: (ctx) => Dialog(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: 200,
                      height: 250,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: const Text('Change the note color',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          const Spacer(),
                          Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            spacing: 2,
                            children: colors.map((color) => InkWell(
                              onTap: (){
                                _firebaseManager.addNoteInCloud(
                                    userId: user.id,
                                    note: _noteModel..colorValue = color.value,
                                );
                                setState(() {
                                  _noteModel.colorValue = color.value;
                                });
                                Navigator.pop(context);

                              },
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                height: 75,
                                width: 75,
                                color: color,
                              ),
                            )).toList(),

                          ),
                          const Spacer(),
                        ],
                      ),

                    ),
                  ));
            },
          ),

          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: (){},
          ),

        ],
        /*title: TextField(
          autofocus: widget.note == null,
          cursorColor: Colors.white,
          controller: _titleController,
          onChanged: (t){
            if(countTitle > 5){
              setNote(_titleController.text,_textController.text);
              countTitle = 0;
            }
            countTitle++;

          },
          decoration: const InputDecoration.collapsed(hintText: ""),
        ),*/
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0)
                .copyWith(bottom: 8.0),
            child: TextField(
              autofocus: widget.note == null,
              cursorColor: Color(_noteModel.colorValue),
              style: const TextStyle(fontSize: 26),
              controller: _titleController,
              onChanged: (t){
                if(countTitle > 5){
                  setNote(_titleController.text,_textController.text);
                  countTitle = 0;
                }
                countTitle++;
              },
              onTap: (){},
              onEditingComplete: (){
                if(!isNoteInCloud) {
                  _firebaseManager.addNoteInCloud(userId: user.id, note: _noteModel);
                  isNoteInCloud = true;
                }
                Log.i('onEditingComplete(edit: title) #### ###');
              },
              decoration: const InputDecoration.collapsed(hintText: "Title"),
            ),
          ),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _textController,
              style: const TextStyle(fontSize: 18),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 60,
              cursorColor: Color(_noteModel.colorValue),

              decoration:  InputDecoration.collapsed(
                fillColor: Color(_noteModel.colorValue),
                hintText: '',

              ),
              onChanged: (text){
                if(count > 10){
                  count = 0;
                  setNote(_titleController.text,_textController.text);
                  Log.i('onChanged(\n$text\n) ====');
                  return;
                }
                count ++;

              },
              onTap: (){
                if(!isNoteInCloud) {
                  _firebaseManager.addNoteInCloud(userId: user.id, note: _noteModel);
                  isNoteInCloud = true;
                }
                Log.i('onEditTap(edit: text) #### ### ON_TAP - TEXT');

              },
              onEditingComplete: (){
                if(!isNoteInCloud) {
                  _firebaseManager.addNoteInCloud(userId: user.id, note: _noteModel);
                  isNoteInCloud = true;
                }
                Log.i('onEditingComplete(edit: text) #### ### TEXT');
              },
            ),
          )),
        ],
      ),
    );
  }
}



