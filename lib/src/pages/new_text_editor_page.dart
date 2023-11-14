
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../../data/app_bloc/auth_repository/user.dart';
import '../../data/app_bloc/authentication/authentication_bloc.dart';
import '../../data/database/database_model.dart';

class TextEditor extends StatefulWidget {
  static const routeName = "editor";
  final QuillController? controller;
  final NoteModel? note;

  const TextEditor._({super.key, this.note, this.controller});

  factory TextEditor({Key? key}) => TextEditor._(key: key,);
  factory TextEditor.quill(){
    return const TextEditor._();
  }

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  late final QuillController _controller;
  late NoteModel _noteModel;
  //late TextEditingController _textController;
  late TextEditingController _titleController;
  late final User user;

  @override
  void initState() {
    super.initState();
    /*var myJSON = jsonDecode(r'{"insert":"hello\n"}');
    _controller = QuillController(
      document: Document.fromJson(myJSON),
      selection: TextSelection.collapsed(offset: 0),
    );*/
    user = BlocProvider.of<AuthenticationBloc>(context).state.user;
    _controller  = widget.controller ?? QuillController.basic();
    _noteModel = widget.note ?? NoteModel(
      id: const Uuid().v4(),
      email: user.email,
      creationTime: DateTime.now(),
      modificationTime: DateTime.now(),
    );
    //_textController = TextEditingController(text: _noteModel.text);
    _titleController = TextEditingController(text: _noteModel.title);
  }

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

    return QuillProvider(
      configurations: QuillConfigurations(
        controller: _controller,
        sharedConfigurations: const QuillSharedConfigurations(
          //locale: Locale('de'),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.done),
            onPressed: (){
              //setNote(_titleController.text,_textController.text);
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
                                  /*_firebaseManager.addNoteInCloud(
                                    note: _noteModel..colorValue = color.value,
                                  );*/
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
                    //setNote(_titleController.text,_textController.text);
                    countTitle = 0;
                  }
                  countTitle++;
                },
                onTap: (){},

                onEditingComplete: (){},
                decoration: const InputDecoration.collapsed(hintText: "Title"),
              ),
            ),
            Expanded(
                child: QuillEditor.basic(
                  configurations: const QuillEditorConfigurations(
                    readOnly: false,
                  ),
                )
            ),
          ],
        ),
        bottomNavigationBar: const QuillToolbar(),
      ),
    );
  }
}
