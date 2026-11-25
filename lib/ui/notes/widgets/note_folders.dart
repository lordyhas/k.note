import 'package:flutter/material.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/folder.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/widgets/app_icons.dart';
import 'package:knote/ui/core/widgets/responsive.dart';
import 'package:knote/ui/core/widgets/undo_snack_bar.dart';
import 'package:knote/utils/save_in_background.dart';

/// The folders above the notes: "All", one chip per folder and "New folder".
///
/// Tapping a folder shows only its notes; a long press (or a right click)
/// opens [onFolderMenu] to rename or delete it.
class FolderBar extends StatelessWidget {
  const FolderBar({
    super.key,
    required this.folders,
    required this.selectedId,
    required this.onSelected,
    required this.onCreate,
    required this.onFolderMenu,
  });

  final List<NoteFolder> folders;

  /// The folder shown, or null for all notes.
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final VoidCallback onCreate;
  final ValueChanged<NoteFolder> onFolderMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CenteredContent(
      maxWidth: ContentWidths.wide,
      child: SingleChildScrollView(
        key: const Key('notes_folderBar'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            if (folders.isNotEmpty) ...[
              ChoiceChip(
                label: Text(l10n.foldersAll),
                selected: selectedId == null,
                onSelected: (_) => onSelected(null),
              ),
              for (final folder in folders)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: GestureDetector(
                    onLongPress: () => onFolderMenu(folder),
                    onSecondaryTap: () => onFolderMenu(folder),
                    child: ChoiceChip(
                      key: ValueKey('folderChip_${folder.id}'),
                      avatar: const AppIcon(AppIcons.folder, size: 18),
                      label: Text(folder.name),
                      selected: selectedId == folder.id,
                      onSelected: (_) => onSelected(folder.id),
                    ),
                  ),
                ),
              const SizedBox(width: 8.0),
            ],
            ActionChip(
              key: const Key('notes_newFolder'),
              avatar: const AppIcon(AppIcons.folderPlus, size: 18),
              label: Text(l10n.folderNew),
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks for a folder name; null when cancelled. [initial] is the current
/// name when renaming.
Future<String?> showFolderNameDialog(BuildContext context, {String? initial}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _FolderNameDialog(initial: initial),
  );
}

class _FolderNameDialog extends StatefulWidget {
  const _FolderNameDialog({this.initial});

  final String? initial;

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  String get _name => _controller.text.trim();

  void _submit() {
    if (_name.isNotEmpty) Navigator.of(context).pop(_name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.initial == null ? l10n.folderNew : l10n.folderRename),
      content: TextField(
        key: const Key('folderName_textField'),
        controller: _controller,
        autofocus: true,
        maxLength: NoteFolder.maxNameLength,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: l10n.folderNameHint),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('folderName_save'),
          onPressed: _name.isEmpty ? null : _submit,
          child: Text(widget.initial == null ? l10n.folderCreate : l10n.save),
        ),
      ],
    );
  }
}

/// Creates a folder from a name the user types; returns it, or null when
/// cancelled. The write completes in the background.
Future<NoteFolder?> createFolder(
    BuildContext context, FirestoreService service) async {
  final l10n = context.l10n;
  final name = await showFolderNameDialog(context);
  if (name == null) return null;
  final folder = service.newFolder(name);
  saveInBackground(() => service.saveFolder(folder),
      failureMessage: l10n.folderSaveFailed);
  return folder;
}

/// The rename and delete menu of [folder]. Calls [onDeleted] once the user
/// confirmed the deletion.
Future<void> showFolderMenu(
  BuildContext context, {
  required FirestoreService service,
  required NoteFolder folder,
  VoidCallback? onDeleted,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const AppIcon(AppIcons.folder),
            title: Text(folder.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          ListTile(
            leading: const AppIcon(AppIcons.edit),
            title: Text(l10n.folderRename),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final name =
                  await showFolderNameDialog(context, initial: folder.name);
              if (name == null || name == folder.name) return;
              saveInBackground(
                  () => service.renameFolder(folderId: folder.id, name: name),
                  failureMessage: l10n.folderSaveFailed);
            },
          ),
          ListTile(
            leading: const AppIcon(AppIcons.trash),
            title: Text(l10n.folderDelete),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.folderDelete),
                  content: Text(l10n.folderDeleteBody(folder.name)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      key: const Key('folderDelete_confirm'),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(l10n.folderDelete),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              onDeleted?.call();
              saveInBackground(() => service.deleteFolder(folderId: folder.id),
                  failureMessage: l10n.folderDeleteFailed);
              appMessengerKey.currentState
                ?..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(l10n.folderDeleted(folder.name)),
                ));
            },
          ),
        ],
      ),
    ),
  );
}

/// What the user picked in [pickFolder]: a folder id, or null for none.
typedef FolderChoice = ({String? folderId, String? name});

/// Lets the user pick the folder of a note in [currentFolderId]: one of
/// theirs, "No folder" or a new one. Null when dismissed.
Future<FolderChoice?> pickFolder(
  BuildContext context, {
  required FirestoreService service,
  required String? currentFolderId,
}) async {
  final picked = await showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _FolderPicker(
      folders: service.watchFolders(),
      currentFolderId: currentFolderId,
    ),
  );
  if (picked == null || !context.mounted) return null;
  if (picked == _FolderPicker.newFolder) {
    final folder = await createFolder(context, service);
    return folder == null ? null : (folderId: folder.id, name: folder.name);
  }
  if (picked == _FolderPicker.noFolder) return (folderId: null, name: null);
  final folder = picked as NoteFolder;
  return (folderId: folder.id, name: folder.name);
}

class _FolderPicker extends StatelessWidget {
  const _FolderPicker({required this.folders, required this.currentFolderId});

  static const noFolder = 'noFolder';
  static const newFolder = 'newFolder';

  final Stream<List<NoteFolder>> folders;
  final String? currentFolderId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = AppColors.of(context).text;
    Widget? check(bool selected) =>
        selected ? AppIcon(AppIcons.check, color: accent) : null;
    return SafeArea(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: StreamBuilder<List<NoteFolder>>(
          stream: folders,
          builder: (context, snapshot) {
            final list = snapshot.data ?? const <NoteFolder>[];
            final known = list.any((f) => f.id == currentFolderId);
            return ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(l10n.noteMoveToFolder,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                ListTile(
                  key: const Key('folderPicker_none'),
                  leading: const AppIcon(AppIcons.notes),
                  title: Text(l10n.noteNoFolder),
                  trailing: check(currentFolderId == null || !known),
                  onTap: () => Navigator.of(context).pop(noFolder),
                ),
                for (final folder in list)
                  ListTile(
                    key: ValueKey('folderPicker_${folder.id}'),
                    leading: const AppIcon(AppIcons.folder),
                    title: Text(folder.name),
                    trailing: check(folder.id == currentFolderId),
                    onTap: () => Navigator.of(context).pop(folder),
                  ),
                ListTile(
                  key: const Key('folderPicker_new'),
                  leading: const AppIcon(AppIcons.folderPlus),
                  title: Text(l10n.folderNew),
                  onTap: () => Navigator.of(context).pop(newFolder),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Moves the note [noteId] to the folder the user picks, with Undo.
/// Returns the new folder id (null for none), or [currentFolderId] when the
/// user cancelled or kept the same folder.
Future<String?> moveNoteToPickedFolder(
  BuildContext context, {
  required FirestoreService service,
  required String noteId,
  required String title,
  required String? currentFolderId,
  bool saveNow = true,
}) async {
  final l10n = context.l10n;
  final choice = await pickFolder(context,
      service: service, currentFolderId: currentFolderId);
  if (choice == null || choice.folderId == currentFolderId) {
    return currentFolderId;
  }
  if (saveNow) {
    saveInBackground(
        () =>
            service.moveNoteToFolder(noteId: noteId, folderId: choice.folderId),
        failureMessage: l10n.noteMoveFailed);
    showUndoSnackBar(
      choice.folderId == null
          ? l10n.noteRemovedFromFolder(title)
          : l10n.noteMovedToFolder(title, choice.name!),
      onUndo: () => saveInBackground(
          () => service.moveNoteToFolder(
              noteId: noteId, folderId: currentFolderId),
          failureMessage: l10n.noteMoveFailed),
    );
  }
  return choice.folderId;
}
