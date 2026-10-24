import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/utils/autosave.dart';
import 'package:knote/utils/save_in_background.dart';

class NoteEditorPage extends StatefulWidget {
  static const routeName = "editor";
  final QuillController? controller;
  final NoteModel? note;

  /// Defaults to the signed-in user's [FirestoreService]; tests pass a fake.
  final FirestoreService? firebaseManager;

  const NoteEditorPage({
    super.key,
    this.note,
    this.controller,
    this.firebaseManager,
  });

  static Route route({NoteModel? note}) {
    return MaterialPageRoute<void>(builder: (_) => NoteEditorPage(note: note));
  }

  factory NoteEditorPage.quill({
    Key? key,
    required QuillController controller,
    NoteModel? note,
  }) {
    return NoteEditorPage(
      key: key,
      controller: controller,
      note: note,
    );
  }

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage>
    with WidgetsBindingObserver {
  late final QuillController _quillController;
  late NoteModel _noteModel;
  late TextEditingController _titleController;
  late final User user;
  late final FirestoreService _firebaseManager;
  late final Autosave _autosave;
  late final StreamSubscription<DocChange> _documentChanges;
  bool isNoteInCloud = false;

  /// Kept for [_saveNote], which also runs from [dispose] where the context
  /// can no longer be used.
  late AppLocalizations _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = context.l10n;
  }

  @override
  void initState() {
    super.initState();
    _firebaseManager = widget.firebaseManager ??
        FirestoreService.user(
            BlocProvider.of<AuthenticationBloc>(context).state.user);
    user = _firebaseManager.user;

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

    // Saved a moment after the user stops typing, and in any case when the
    // page is left (dispose) or the app goes to the background, so no edit
    // depends on pressing the done button.
    _autosave = Autosave(_saveNote);
    _documentChanges =
        _quillController.document.changes.listen((_) => _autosave.changed());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The app may be killed while in the background without notice.
    if (state != AppLifecycleState.resumed) _autosave.flush();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _documentChanges.cancel();
    _autosave.dispose();
    _titleController.dispose();
    if (widget.controller == null) _quillController.dispose();
    super.dispose();
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

  /// Copies the title and body being edited into [_noteModel].
  String _syncModel() {
    final String contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());
    _noteModel.title = _titleController.text;
    _noteModel.text = contentJson;
    _noteModel.modificationTime = DateTime.now();
    return contentJson;
  }

  /// Called by [_autosave]; also runs from [dispose], so it must not use
  /// the widget's context or call setState.
  void _saveNote() {
    // Prevent saving empty new notes until there's content to save
    if (!isNoteInCloud &&
        _titleController.text.isEmpty &&
        _quillController.document.isEmpty()) {
      return;
    }

    final contentJson = _syncModel();

    // No Retry: an old save could overwrite newer edits, and the next
    // autosave writes the latest content anyway.
    if (!isNoteInCloud) {
      final note = _noteModel;
      saveInBackground(() => _firebaseManager.addNoteInCloud(note: note),
          failureMessage: _l10n.noteSaveFailed, canRetry: false);
      isNoteInCloud = true;
    } else {
      final noteId = _noteModel.id;
      final title = _titleController.text;
      saveInBackground(
          () => _firebaseManager.updateNoteContent(
              noteId: noteId, title: title, text: contentJson),
          failureMessage: _l10n.noteSaveFailed,
          canRetry: false);
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
            tooltip: context.l10n.editorDone,
            icon: const Icon(Icons.done),
            // Leaving the page saves (see dispose).
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            IconButton(
              tooltip: context.l10n.editorColor,
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
                                  child: Text(
                                    context.l10n.editorColorTitle,
                                    style: const TextStyle(
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
                                                    color.toARGB32();
                                              });
                                              // Save color immediately, with
                                              // the current title and text:
                                              // the write replaces the note.
                                              _syncModel();
                                              _autosave.markSaved();
                                              final note = _noteModel;
                                              saveInBackground(
                                                  () => _firebaseManager
                                                      .addNoteInCloud(
                                                          note: note),
                                                  failureMessage:
                                                      _l10n.noteColorSaveFailed,
                                                  canRetry: false);
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
              tooltip: context.l10n.moreOptions,
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
                onChanged: (_) => _autosave.changed(),
                decoration:
                    InputDecoration.collapsed(hintText: context.l10n.titleHint),
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
