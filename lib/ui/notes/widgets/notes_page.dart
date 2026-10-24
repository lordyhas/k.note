import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:utils_component/utils_component.dart';

import 'package:knote/config/assets.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/themes/dimens.dart';
import 'package:knote/ui/core/themes/styles.dart';
import 'package:knote/ui/core/widgets/undo_snack_bar.dart';
import 'package:knote/ui/notes/widgets/note_card.dart';
import 'package:knote/ui/notes/widgets/note_editor_page.dart';
import 'package:knote/ui/notes/widgets/note_text.dart';
import 'package:knote/utils/save_in_background.dart';

class NotesPage extends StatefulWidget {
  static const routeName = "home";

  /// Defaults to the signed-in user's [FirestoreService]; tests pass a fake.
  final FirestoreService? firebaseManager;

  const NotesPage({super.key, this.firebaseManager});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool multiple = false;
  late final FirestoreService _firebaseManager;
  late final Stream<List<NoteModel>> _notes;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String get _query => _searchController.text.trim();

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _firebaseManager = widget.firebaseManager ??
        FirestoreService.user(
            BlocProvider.of<AuthenticationBloc>(context).state.user);
    _notes = _firebaseManager.watchNotes();

    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // While searching, back clears the search instead of leaving the app.
    return PopScope(
      canPop: _query.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _clearSearch();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          leading: Icon(
            CupertinoIcons.home,
            color: AppColors.of(context).text,
          ),
          title: const Text(
            'K.NOTE',
            style: TextStyle(
              fontSize: 22,
              color: StyleAppTheme.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              tooltip: multiple
                  ? context.l10n.notesListView
                  : context.l10n.notesGridView,
              icon: Icon(
                multiple ? Icons.dashboard : Icons.view_agenda,
                color: AppColors.of(context).text,
              ),
              onPressed: () => setState(() {
                multiple = !multiple;
              }),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: AppBar().preferredSize,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                child: Row(
                  children: [
                    IconButton(
                      tooltip: context.l10n.notesSearch,
                      icon: const Icon(Icons.search),
                      onPressed: _searchFocus.requestFocus,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        key: const Key('homePage_search_textField'),
                        textInputAction: TextInputAction.search,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration.collapsed(
                            hintText: context.l10n.notesSearchHint),
                      ),
                    ),
                    if (_query.isEmpty)
                      IconButton(
                        tooltip: context.l10n.notifications,
                        icon: const Icon(Icons.notifications_none_rounded),
                        onPressed: () {},
                      )
                    else
                      IconButton(
                        key: const Key('homePage_search_clear'),
                        tooltip: context.l10n.notesClearSearch,
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: BooleanBuilder(
          condition: () {
            return BlocProvider.of<AuthenticationBloc>(context)
                .state
                .isAuthenticated;
          },
          ifTrue: Padding(
            padding: const EdgeInsets.only(bottom: fabBottomPadding),
            child: FloatingActionButton(
              tooltip: context.l10n.notesNew,
              child: const Icon(Icons.add),
              onPressed: () {
                GoRouter.of(context).pushNamed(NoteEditorPage.routeName);
              },
            ),
          ),
          ifFalse: const SizedBox.shrink(),
        ),
        body: Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20.0),
          child: _buildNoteList(),
        ),
      ),
    );
  }

  Widget _buildNoteList() {
    return StreamBuilder<List<NoteModel>>(
      stream: _notes,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _Message(
            icon: Icons.error_outline,
            text: context.l10n.notesLoadError,
          );
        }
        if (!snapshot.hasData) return const CircularProgressMultiBar();

        final allNotes = snapshot.data!;
        if (allNotes.isEmpty) {
          return _Message(
            icon: Icons.note_add_outlined,
            text: context.l10n.notesEmpty,
          );
        }
        final data = searchNotes(allNotes, _query);
        if (data.isEmpty) {
          return _Message(
            icon: Icons.search_off,
            text: context.l10n.notesNoMatch(_query),
          );
        }
        return GridView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(
            top: 0,
            left: 12,
            right: 12,
            bottom: bottomMarginValue + 32,
          ),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: multiple ? 2 : 1,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: multiple ? 1.5 : 3,
          ),
          children: List<Widget>.generate(
            data.length,
            (int index) {
              final count = data.length;
              final animation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _animCtrl,
                  curve: Interval(
                    (1 / count) * index,
                    1.0,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
              );
              _animCtrl.forward();
              return HomeListView(
                key: ValueKey(data[index].id),
                changeRatio: multiple,
                animation: animation,
                animationController: _animCtrl,
                listData: NoteCard(
                  color: Color(data[index].colorValue),
                  changeInList: !multiple,
                  note: data[index],
                ),
                onLongPress: () => showModalBottomSheet(
                  // The sheet is the Material its ListTiles paint ink on.
                  backgroundColor:
                      Theme.of(context).cardColor.withValues(alpha: 0.8),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(18.0)),
                  ),
                  context: context,
                  builder: (context) => _buildBottomMenu(data[index]),
                ),
                onTap: () => GoRouter.of(context).pushNamed(
                  NoteEditorPage.routeName,
                  extra: data[index],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomMenu(NoteModel note) {
    final l10n = context.l10n;
    final title =
        note.title?.isNotEmpty == true ? note.title! : l10n.untitled;
    // Scrolls rather than overflowing on small screens; the bottom padding
    // keeps the last item above the navigation bar drawn over the sheet.
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 64.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Image.asset(
              AppAssets.logo_1,
              height: 30,
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Divider(color: AppColors.of(context).text),
          ListTile(
            leading: Icon(
              Icons.archive_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(l10n.noteArchive),
            onTap: () {
              saveInBackground(
                  () => _firebaseManager.archiveNote(
                      noteId: note.id, archived: true),
                  failureMessage: l10n.noteArchiveFailed);
              Navigator.of(context).pop();
              showUndoSnackBar(
                l10n.noteArchived(title),
                onUndo: () => saveInBackground(
                    () => _firebaseManager.archiveNote(
                        noteId: note.id, archived: false),
                    failureMessage: l10n.noteUnarchiveFailed),
              );
            },
          ),
          ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(l10n.noteMoveToBin),
              onTap: () {
                saveInBackground(
                    () => _firebaseManager.deleteNote(noteId: note.id),
                    failureMessage: l10n.noteMoveToBinFailed);
                Navigator.of(context).pop();
                showUndoSnackBar(
                  l10n.noteMovedToBin(title),
                  onUndo: () => saveInBackground(
                      () =>
                          _firebaseManager.restoreDeletedNote(noteId: note.id),
                      failureMessage: l10n.noteRestoreFailed),
                );
              }),
          ListTile(
            leading: Icon(
              Icons.color_lens_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(l10n.noteChangeColor),
            onTap: () {},
          ),
          Divider(
            indent: 42.0,
            color: AppColors.of(context).text,
          ),
          ListTile(
            leading: Icon(
              Icons.save_alt_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(l10n.noteSavingMode),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class HomeListView extends StatelessWidget {
  const HomeListView(
      {super.key,
      required this.listData,
      this.onTap,
      this.changeRatio = false,
      this.onLongPress,
      required this.animationController,
      required this.animation});

  final dynamic listData;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AnimationController animationController;
  final Animation<double> animation;
  final bool changeRatio;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: AspectRatio(
              aspectRatio: changeRatio ? 1 / 3 : 1.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    /*Image.asset(
                      listData.imagePath,
                      fit: BoxFit.cover,
                    ),*/
                    listData,
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.0),
                        onTap: onTap,
                        onLongPress: onLongPress,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A centered icon and sentence for empty, no-result and error states.
class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 80,
                color: AppColors.of(context).text.withValues(alpha: 0.54)),
            const SizedBox(height: 12.0),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
