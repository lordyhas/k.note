import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../../data/app_bloc/auth_repository/user.dart';
import '../../data/app_bloc/authentication/authentication_bloc.dart';
import '../../data/database/database_model.dart';
import '../../data/database/firebase_manager.dart';
import 'dart:convert';

class TextEditor extends StatefulWidget {
  static const routeName = "editor";
  final QuillController? controller;
  final NoteModel? note;

  const TextEditor({super.key, this.note, this.controller});

  static Route route({NoteModel? note}) {
    return MaterialPageRoute<void>(builder: (_) => TextEditor(note: note));
  }

  factory TextEditor.quill({
    Key? key,
    required QuillController controller,
    NoteModel? note,
  }) {
    return TextEditor(
      key: key,
      controller: controller,
      note: note,
    );
  }

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  late final QuillController _quillController;
  late NoteModel _noteModel;
  late TextEditingController _titleController;
  late final User user;
  late final FirebaseManager _firebaseManager;
  bool isNoteInCloud = false;
  int _autoSaveCounterText = 0;
  int _autoSaveCounterTitle = 0;

  @override
  void initState() {
    super.initState();
    user = BlocProvider.of<AuthenticationBloc>(context).state.user;
    _firebaseManager = FirebaseManager.user(user);

    _noteModel = widget.note ??
        NoteModel(
          id: const Uuid().v4(),
          email: user.email,
          creationTime: DateTime.now(),
          modificationTime: DateTime.now(),
        );

    // Initialize controller with content
    if (widget.controller != null) {
      _quillController = widget.controller!;
    } else {
      _quillController = _loadContent(_noteModel.text);
    }

    _titleController = TextEditingController(text: _noteModel.title);

    if (widget.note != null) {
      isNoteInCloud = true;
    }

    // Autosave listeners
    _quillController.document.changes.listen((event) {
      _autoSaveCounterText++;
      if (_autoSaveCounterText > 10) {
        _autoSaveCounterText = 0;
        _saveNote();
      }
    });
  }

  QuillController _loadContent(String? content) {
    if (content == null || content.isEmpty) {
      return QuillController.basic();
    }
    try {
      final json = jsonDecode(content);
      return QuillController(
        document: Document.fromJson(json),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // Fallback for legacy plain text notes
      return QuillController(
        document: Document()..insert(0, content),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  void _saveNote() {
    // Prevent saving empty new notes until there's content to save
    if (!isNoteInCloud &&
        _titleController.text.isEmpty &&
        _quillController.document.isEmpty()) {
      return;
    }

    final String contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());

    setState(() {
      _noteModel.title = _titleController.text;
      _noteModel.text = contentJson;
      _noteModel.modificationTime = DateTime.now();
    });

    if (!isNoteInCloud) {
      _firebaseManager.addNoteInCloud(note: _noteModel);
      isNoteInCloud = true;
    } else {
      // Update logic
      _firebaseManager.updateNoteTitle(
          userId: user.id, id: _noteModel.id, value: _titleController.text);
      _firebaseManager.updateNoteText(
          userId: user.id, id: _noteModel.id, value: contentJson);
      _firebaseManager.updateNoteModificationTime(noteId: _noteModel.id);
    }
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

    return SizedBox(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              _saveNote();
              context.pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.style,
                color: Color(_noteModel.colorValue),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            width: 200,
                            height: 250,
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: const Text(
                                    'Change the note color',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  spacing: 2,
                                  children: colors
                                      .map((color) => InkWell(
                                            onTap: () {
                                              setState(() {
                                                _noteModel.colorValue =
                                                    color.value;
                                              });
                                              // Save color immediately
                                              _firebaseManager.addNoteInCloud(
                                                  note: _noteModel);
                                              if (!isNoteInCloud) {
                                                isNoteInCloud = true;
                                              }

                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.all(4.0),
                                              height: 75,
                                              width: 75,
                                              color: color,
                                            ),
                                          ))
                                      .toList(),
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
              onPressed: () {
                // Future cleanup or detailed menu
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0)
                  .copyWith(bottom: 8.0),
              child: TextField(
                autofocus: widget.note == null,
                cursorColor: Color(_noteModel.colorValue),
                style: const TextStyle(fontSize: 22),
                controller: _titleController,
                onChanged: (t) {
                  _autoSaveCounterTitle++;
                  if (_autoSaveCounterTitle > 5) {
                    _saveNote();
                    _autoSaveCounterTitle = 0;
                  }
                },
                decoration: const InputDecoration.collapsed(hintText: "Title"),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: QuillEditor.basic(
                controller: _quillController,
                config: const QuillEditorConfig(),
              ),
            )),
            SafeArea(
              child: QuillSimpleToolbar(
                controller: _quillController,
                config: const QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                  showCodeBlock: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showLineHeightButton: false,
                  showColorButton: false,
                  showInlineCode: false,
                  showBackgroundColorButton: false,
                  showHeaderStyle: false,
                  showListBullets: true,
                  showListNumbers: true,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
