import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/widgets/app_icons.dart';
import 'package:knote/ui/core/widgets/responsive.dart';
import 'package:knote/ui/notes/widgets/note_folders.dart';
import 'package:knote/utils/autosave.dart';
import 'package:knote/utils/save_in_background.dart';

class NoteEditorPage extends StatefulWidget {
  static const routeName = "editor";

  /// Query parameter naming the folder of a new note.
  static const folderParam = 'folder';

  final QuillController? controller;
  final NoteModel? note;

  /// The folder a new note goes in ([note] is null); ignored otherwise.
  final String? folderId;

  /// Defaults to the signed-in user's [FirestoreService]; tests pass a fake.
  final FirestoreService? firebaseManager;

  const NoteEditorPage({
    super.key,
    this.note,
    this.controller,
    this.firebaseManager,
    this.folderId,
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
          folderId: widget.folderId,
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

  /// Reading mode: the note can't be edited and the toolbar is hidden, so
  /// scrolling or tapping a checkbox never brings up the keyboard.
  bool _readOnly = false;

  void _toggleReadOnly() {
    FocusScope.of(context).unfocus();
    setState(() {
      _readOnly = !_readOnly;
      _quillController.readOnly = _readOnly;
    });
  }

  void _setColor(Color color) {
    setState(() => _noteModel.colorValue = color.toARGB32());
    // Saved now, with the current title and text: the write replaces the
    // note.
    _syncModel();
    _autosave.markSaved();
    final note = _noteModel;
    saveInBackground(() => _firebaseManager.addNoteInCloud(note: note),
        failureMessage: _l10n.noteColorSaveFailed, canRetry: false);
    isNoteInCloud = true;
  }

  /// Files the note in the folder the user picks. A note not saved yet
  /// takes its folder with its first save.
  Future<void> _moveToFolder() async {
    final current = _noteModel.folderId;
    final folderId = await moveNoteToPickedFolder(
      context,
      service: _firebaseManager,
      noteId: _noteModel.id,
      title: _titleController.text,
      currentFolderId: current,
      saveNow: false,
    );
    if (folderId == current) return;
    _noteModel.folderId = folderId;
    if (isNoteInCloud) {
      final noteId = _noteModel.id;
      saveInBackground(
          () => _firebaseManager.moveNoteToFolder(
              noteId: noteId, folderId: folderId),
          failureMessage: _l10n.noteMoveFailed);
    }
  }

  Future<void> _pickColor() async {
    const colors = [
      Colors.cyan,
      Colors.black,
      Colors.yellow,
      Colors.grey,
      Colors.deepPurpleAccent,
      Colors.red,
    ];
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.editorColorTitle),
        content: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in colors)
              InkWell(
                onTap: () => Navigator.pop(context, color),
                customBorder: const CircleBorder(),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.of(context).stroke,
                      width: color.toARGB32() == _noteModel.colorValue ? 3 : 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (color != null && mounted) _setColor(color);
  }

  /// Archives the note or moves it to the bin, then closes the editor.
  void _leaveNote({required bool archive}) {
    _autosave.flush();
    final navigator = Navigator.of(context);
    if (isNoteInCloud) {
      final noteId = _noteModel.id as String;
      if (archive) {
        saveInBackground(
            () => _firebaseManager.archiveNote(noteId: noteId, archived: true),
            failureMessage: _l10n.noteArchiveFailed);
      } else {
        saveInBackground(() => _firebaseManager.deleteNote(noteId: noteId),
            failureMessage: _l10n.noteMoveToBinFailed);
      }
    }
    navigator.maybePop();
  }

  void _insertDateTime() {
    final now = DateTime.now();
    final text =
        '${DateFormat.yMMMd(_l10n.localeName).format(now)} ${DateFormat.Hm(_l10n.localeName).format(now)}';
    final selection = _quillController.selection;
    final index = selection.isValid
        ? selection.start
        : _quillController.document.length - 1;
    final length = selection.isValid ? selection.end - selection.start : 0;
    _quillController.replaceText(index, length, text,
        TextSelection.collapsed(offset: index + text.length));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final noteColor = Color(_noteModel.colorValue);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0.0,
        titleSpacing: 0,
        shape: Border(bottom: BorderSide(color: colors.stroke)),
        leading: IconButton(
          tooltip: l10n.editorDone,
          icon: const AppIcon(AppIcons.back),
          // Leaving the page saves (see dispose).
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // The title is edited in place, as in a notebook.
        title: TextField(
          key: const Key('__editor_title__'),
          autofocus: widget.note == null,
          readOnly: _readOnly,
          cursorColor: noteColor,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          controller: _titleController,
          onChanged: (_) => _autosave.changed(),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration.collapsed(
            hintText: l10n.titleHint,
            hintStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
            ),
          ),
        ),
        actions: [
          IconButton(
            key: const Key('__editor_readMode__'),
            tooltip: _readOnly ? l10n.editorEditMode : l10n.editorReadMode,
            isSelected: _readOnly,
            icon: AppIcon(_readOnly ? AppIcons.edit : AppIcons.book),
            onPressed: _toggleReadOnly,
          ),
          if (!_readOnly)
            PopupMenuButton<VoidCallback>(
              key: const Key('__editor_insert__'),
              tooltip: l10n.editorInsert,
              icon: const AppIcon(AppIcons.add),
              onSelected: (action) => action(),
              itemBuilder: (context) => [
                _menuItem(AppIcons.checklist, l10n.editorChecklist,
                    () => _toggleBlock(Attribute.unchecked)),
                _menuItem(AppIcons.listBullets, l10n.editorBulletedList,
                    () => _toggleBlock(Attribute.ul)),
                _menuItem(AppIcons.listNumbers, l10n.editorNumberedList,
                    () => _toggleBlock(Attribute.ol)),
                _menuItem(AppIcons.quote, l10n.editorQuote,
                    () => _toggleBlock(Attribute.blockQuote)),
                _menuItem(AppIcons.clock, l10n.editorDateTime, _insertDateTime),
              ],
            ),
          PopupMenuButton<VoidCallback>(
            key: const Key('__editor_more__'),
            tooltip: l10n.moreOptions,
            icon: const AppIcon(AppIcons.more),
            onSelected: (action) => action(),
            itemBuilder: (context) => [
              _menuItem(AppIcons.palette, l10n.editorColor, _pickColor,
                  iconColor: noteColor),
              _menuItem(AppIcons.folder, l10n.noteMoveToFolder, _moveToFolder),
              _menuItem(AppIcons.archive, l10n.noteArchive,
                  () => _leaveNote(archive: true)),
              _menuItem(AppIcons.trash, l10n.noteMoveToBin,
                  () => _leaveNote(archive: false)),
            ],
          ),
        ],
      ),
      // A column of text as wide as a desktop window is hard to read.
      body: Column(
        children: [
          Expanded(
            child: CenteredContent(
              maxWidth: ContentWidths.editor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: QuillEditor.basic(
                  controller: _quillController,
                  config: QuillEditorConfig(
                    expands: true,
                    placeholder: _readOnly ? null : l10n.editorPlaceholder,
                  ),
                ),
              ),
            ),
          ),
          if (!_readOnly)
            _EditorToolbar(controller: _quillController, accent: noteColor),
        ],
      ),
    );
  }

  void _toggleBlock(Attribute attribute) =>
      _EditorToolbar.toggle(_quillController, attribute);

  PopupMenuItem<VoidCallback> _menuItem(
      AppIcons icon, String label, VoidCallback action,
      {Color? iconColor}) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          AppIcon(icon, size: 20, color: iconColor),
          const SizedBox(width: 16),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}

/// The formatting bar at the bottom of the editor, above the keyboard:
/// checklist, text style, paragraph, heading, font size, undo and redo.
class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({required this.controller, required this.accent});

  final QuillController controller;

  /// Highlights the active formats, in the note's color.
  final Color accent;

  /// Font sizes offered, in logical pixels; the editor's default is 16.
  static const fontSizes = [12, 14, 16, 18, 20, 24, 28, 32];
  static const defaultFontSize = 16;

  /// Turns [attribute] on for the selection, or off when it already is.
  static void toggle(QuillController controller, Attribute attribute) {
    final current =
        controller.getSelectionStyle().attributes[attribute.key]?.value;
    final isOn = attribute.key == Attribute.list.key
        // A checked item is still a checklist item.
        ? (attribute.value == Attribute.unchecked.value
            ? current == Attribute.unchecked.value ||
                current == Attribute.checked.value
            : current == attribute.value)
        : current == attribute.value;
    controller
        .formatSelection(isOn ? Attribute.clone(attribute, null) : attribute);
  }

  static bool _has(QuillController controller, Attribute attribute) =>
      controller.getSelectionStyle().attributes[attribute.key]?.value ==
      attribute.value;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.stroke)),
          ),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final attributes = controller.getSelectionStyle().attributes;
              final list = attributes[Attribute.list.key]?.value;
              final header = attributes[Attribute.header.key]?.value;
              final size =
                  num.tryParse('${attributes[Attribute.size.key]?.value ?? ''}')
                      ?.round();
              Color? on(bool active) => active ? accent : null;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.sizeOf(context).width),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        key: const Key('__editor_checklist__'),
                        tooltip: l10n.editorChecklist,
                        icon: AppIcon(AppIcons.checklist,
                            color: on(list == Attribute.unchecked.value ||
                                list == Attribute.checked.value)),
                        onPressed: () =>
                            toggle(controller, Attribute.unchecked),
                      ),
                      _menu(
                        key: const Key('__editor_textStyle__'),
                        tooltip: l10n.editorTextStyle,
                        child: AppIcon(AppIcons.text,
                            color: on([
                              Attribute.bold,
                              Attribute.italic,
                              Attribute.underline,
                              Attribute.strikeThrough
                            ].any((a) => _has(controller, a)))),
                        items: [
                          for (final (attribute, icon, label)
                              in <(Attribute, AppIcons, String)>[
                            (Attribute.bold, AppIcons.bold, l10n.editorBold),
                            (
                              Attribute.italic,
                              AppIcons.italic,
                              l10n.editorItalic
                            ),
                            (
                              Attribute.underline,
                              AppIcons.underline,
                              l10n.editorUnderline
                            ),
                            (
                              Attribute.strikeThrough,
                              AppIcons.strikethrough,
                              l10n.editorStrikethrough
                            ),
                          ])
                            _item(
                              icon,
                              label,
                              selected: _has(controller, attribute),
                              onTap: () => toggle(controller, attribute),
                            ),
                        ],
                      ),
                      _menu(
                        key: const Key('__editor_paragraph__'),
                        tooltip: l10n.editorParagraph,
                        child: AppIcon(AppIcons.textBox,
                            color: on(list == Attribute.ul.value ||
                                list == Attribute.ol.value ||
                                _has(controller, Attribute.blockQuote))),
                        items: [
                          for (final (attribute, icon, label)
                              in <(Attribute, AppIcons, String)>[
                            (
                              Attribute.ul,
                              AppIcons.listBullets,
                              l10n.editorBulletedList
                            ),
                            (
                              Attribute.ol,
                              AppIcons.listNumbers,
                              l10n.editorNumberedList
                            ),
                            (
                              Attribute.blockQuote,
                              AppIcons.quote,
                              l10n.editorQuote
                            ),
                          ])
                            _item(
                              icon,
                              label,
                              selected: _has(controller, attribute),
                              onTap: () => toggle(controller, attribute),
                            ),
                        ],
                      ),
                      _menu(
                        key: const Key('__editor_heading__'),
                        tooltip: l10n.editorParagraphStyle,
                        child: _DropdownLabel('Aa', color: on(header != null)),
                        items: [
                          for (final (attribute, label, fontSize)
                              in <(Attribute, String, double)>[
                            (Attribute.header, l10n.editorStyleBody, 16.0),
                            (Attribute.h1, l10n.editorStyleTitle, 24.0),
                            (Attribute.h2, l10n.editorStyleSubtitle, 20.0),
                            (Attribute.h3, l10n.editorStyleHeading, 18.0),
                          ])
                            _item(
                              null,
                              label,
                              fontSize: fontSize,
                              selected: header == attribute.value,
                              onTap: () => controller.formatSelection(
                                  attribute.value == null
                                      ? Attribute.clone(Attribute.header, null)
                                      : attribute),
                            ),
                        ],
                      ),
                      _menu(
                        key: const Key('__editor_fontSize__'),
                        tooltip: l10n.editorFontSize,
                        child: _DropdownLabel('${size ?? defaultFontSize}',
                            color: on(size != null)),
                        items: [
                          for (final fontSize in fontSizes)
                            _item(
                              null,
                              '$fontSize',
                              selected: (size ?? defaultFontSize) == fontSize,
                              onTap: () => controller.formatSelection(
                                  fontSize == defaultFontSize
                                      ? Attribute.clone(Attribute.size, null)
                                      : Attribute.fromKeyValue(
                                          Attribute.size.key, fontSize)!),
                            ),
                        ],
                      ),
                      IconButton(
                        key: const Key('__editor_undo__'),
                        tooltip: l10n.undo,
                        icon: const AppIcon(AppIcons.undo),
                        onPressed: controller.hasUndo ? controller.undo : null,
                      ),
                      IconButton(
                        key: const Key('__editor_redo__'),
                        tooltip: l10n.editorRedo,
                        icon: const AppIcon(AppIcons.redo),
                        onPressed: controller.hasRedo ? controller.redo : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _menu({
    required Key key,
    required String tooltip,
    required Widget child,
    required List<PopupMenuEntry<VoidCallback>> items,
  }) {
    return PopupMenuButton<VoidCallback>(
      key: key,
      tooltip: tooltip,
      position: PopupMenuPosition.over,
      onSelected: (action) => action(),
      itemBuilder: (_) => items,
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(child: child),
        ),
      ),
    );
  }

  PopupMenuItem<VoidCallback> _item(
    AppIcons? icon,
    String label, {
    required bool selected,
    required VoidCallback onTap,
    double? fontSize,
  }) {
    return PopupMenuItem(
      value: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            AppIcon(icon, size: 20, color: selected ? accent : null),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: selected ? accent : null,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
          ),
          if (selected) AppIcon(AppIcons.check, size: 18, color: accent),
        ],
      ),
    );
  }
}

/// A toolbar label with a small arrow, for the buttons that open a list
/// ("Aa ▾", "16 ▾").
class _DropdownLabel extends StatelessWidget {
  const _DropdownLabel(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? AppColors.of(context).text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: TextStyle(fontSize: 20, color: color)),
        AppIcon(AppIcons.chevronDown, size: 16, color: color),
      ],
    );
  }
}
