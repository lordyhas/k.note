import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:utils_component/utils_component.dart';

import 'package:knote/config/assets.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/note.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/themes/dimens.dart';
import 'package:knote/ui/core/themes/styles.dart';
import 'package:knote/ui/core/widgets/coming_soon.dart';
import 'package:knote/ui/notes/widgets/note_card.dart';
import 'package:knote/ui/notes/widgets/note_editor_page.dart';
import 'package:knote/utils/save_in_background.dart';

class NotesPage extends StatefulWidget {
  static const routeName = "home";

  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  late List<Widget> homeList; //= HomeList.homeList;

  late AnimationController _animCtrl;
  bool multiple = false;
  late final FirestoreService _firebaseManager;
  bool searching = false;

  final TextEditingController _searchController = TextEditingController();

  final StreamController<String> _searchStreamController =
      StreamController.broadcast();

  Stream<String> get searchStream => _searchStreamController.stream;

  /// Toggles search UI. Must not be invoked from [build] (e.g. as a [FutureBuilder.future]).
  void _toggleSearch() {
    setState(() {
      searching = !searching;
    });
  }

  Future<void> findNote(String data) async {
    _searchStreamController.sink.add(data);
    //_searchController.s//.addListener(() { })
    //return;
  }

  // void _defaultOnTapComingSoon() {
  //   Log.i('++++++++++ SnackBar ++++++++++');
  //   ScaffoldMessenger.of(context)
  //     ..hideCurrentSnackBar()
  //     ..showSnackBar(const SnackBar(
  //         behavior: SnackBarBehavior.fixed,
  //         content: Text('En développment | Soon :) ')));
  // }

  @override
  void initState() {
    super.initState();

    _firebaseManager = FirestoreService.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user);

    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    //_uploadUserInCloud();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.clear();
    _searchStreamController.close();
    super.dispose();
  }

  Future<List<Widget>> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return homeList;
  }

  Future<bool> waitForAnimation() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: StyleAppTheme.white,
      // bottomNavigationBar: SizedBox(
      //   height: 70,
      // ),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        leading: const Icon(
          CupertinoIcons.home,
          color: Colors.white,
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
            icon: Icon(
              multiple ? Icons.dashboard : Icons.view_agenda,
              color: Colors.white,
            ),
            onPressed: () => setState(() {
              multiple = !multiple;
            }),
          ),
          // InkWell(
          //   borderRadius: BorderRadius.circular(AppBar().preferredSize.height),
          //   child: Icon(
          //     multiple ? Icons.dashboard : Icons.view_agenda,
          //     color: Colors.white,
          //   ),
          //   onTap: () {
          //     setState(() {
          //       multiple = !multiple;
          //     });
          //   },
          // ),
        ],
        bottom: PreferredSize(
          preferredSize: AppBar().preferredSize,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              //color: Colors.grey.shade700,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.,
                children: [
                  IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _toggleSearch,
                      ),
                  Expanded(
                    child: TextField(
                        controller: _searchController,
                        key: const Key('homePage_search_textField'),
                        onChanged: (query) {},
                        onTap: _toggleSearch,
                        decoration: const InputDecoration.collapsed(
                            hintText: 'Find a documents')),
                  ),
                  IconButton(
                      //icon: Icon(Icons.notifications_none_rounded),
                      icon: const Icon(Icons.notifications_none_rounded),
                      onPressed: () {} //Scaffold.of(context).openEndDrawer,
                      )
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
          //return true;
        },
        ifTrue: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              GoRouter.of(context).pushNamed(NoteEditorPage.routeName);
            },
          ),
        ),
        ifFalse: const SizedBox.shrink(),
      ),
      body: FutureBuilder<bool>(
        future: waitForAnimation(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //appBar(),
                  const SizedBox(
                    height: 4.0,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Expanded(
                    child: searching
                        ? StreamBuilder<Object>(
                            stream: searchStream,
                            builder: (context, snapshot) {
                              return Column(
                                children: [
                                  const Spacer(),
                                  Text(
                                    _searchController.text.toString(),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  ComingSoon(),
                                  const Spacer(),
                                ],
                              );
                            },
                          )
                        : NoteListView(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  //ignore: non_constant_identifier_names
  Widget NoteListView() {
    return FutureBuilder<List<NoteModel>>(
      future: _firebaseManager.getAllNoteInCloud(),
      //_firebaseManager.getAllNoteInCloud(user.email),
      builder: (context, snapshot) {
        //print('=================== ${snapshot.data} ==================');
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
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
                    Text('No notes found')
                  ],
                ),
              ),
            );
          } else {
            var data = snapshot.data!.map((note) => note).toList();
            return GridView(
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
                snapshot.data!.length,
                (int index) {
                  final count = snapshot.data!.length;
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
                    changeRatio: multiple,
                    animation: animation,
                    animationController: _animCtrl,
                    listData: NoteCard(
                      color: Color(data[index].colorValue),
                      changeInList: !multiple,
                      note: data[index],
                    ),
                    //snapshot.data![index],
                    onLongPress: () => showModalBottomSheet(
                      constraints: BoxConstraints(
                        maxHeight: 400.toDouble(),
                        minHeight: 300.toDouble(),
                      ),
                      backgroundColor: Colors.transparent,
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
          }
          //return const CircularProgressMultiBar();
        } else if (snapshot.hasError) {
          //debugPrint("++++++++++++++++++++++\n$snapshot\n++++++++++++++++++++++");
          return const Center(
            child: SizedBox(
              height: 200,
              child: Column(
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 100,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text('Something went wrong'),
                ],
              ),
            ),
          );
        } else {
          return const CircularProgressMultiBar();
        }
      },
    );
  }

  Container _buildBottomMenu(NoteModel doc) {
    NoteModel note = doc;
    /*if(doc is NoteModel){
      note = doc;
    }
    else {}*/
    return Container(
      //height: 300,
      padding: const EdgeInsets.only(bottom: 64.0),
      //padding: const EdgeInsets.only(bottom: kBottomMarginValue,),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18.0),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(
              AppAssets.logo_1,
              height: 30,
            ),
            title: Text(
              "${note.title}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Divider(color: Colors.white),
          ListTile(
            leading: Icon(
              Icons.archive_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: const Text("Move in archive"),
            onTap: () {
              saveInBackground(
                  () => _firebaseManager.archiveNote(
                      noteId: note.id, archived: true),
                  failureMessage: "The note couldn't be archived");
              Navigator.of(context).pop();
              setState(() {});
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.white,
                  content: Text(
                    '${note.title} note archived ✔',
                    style: const TextStyle(color: Colors.black),
                  ),
                  //dismissDirection: DismissDirection.up,
                ));
            },
          ),
          ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).iconTheme.color,
              ),
              title: const Text("Delete (Move in bin)"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    // title: const Text("Option"),
                    content: SizedBox(
                      //height: 20,
                      child: Text("Do you want to delete this note? \n"
                          "named : ${note.title}"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          saveInBackground(
                              () =>
                                  _firebaseManager.deleteNote(noteId: note.id),
                              failureMessage:
                                  "The note couldn't be moved to the bin");
                          Navigator.of(context).pop();
                          setState(() {});
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.white,
                              content: Text(
                                '${note.title} note moved in bin',
                                style: const TextStyle(color: Colors.black),
                              ),
                              //dismissDirection: DismissDirection.up,
                            ));
                        },
                      ),
                    ],
                  ),
                );

                Navigator.of(context).pop();
              }),
          ListTile(
            leading: Icon(
              Icons.color_lens_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: const Text("Change color"),
            onTap: () {},
          ),
          const Divider(
            indent: 42.0,
            color: Colors.white,
          ),
          ListTile(
            leading: Icon(
              Icons.save_alt_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            title: const Text("Saving mode"),
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
