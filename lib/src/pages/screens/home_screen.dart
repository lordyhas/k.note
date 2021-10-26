import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:knote/data/app_database.dart';
import 'package:knote/data/authentication_repository.dart';
import 'package:knote/data/values.dart';
import 'package:knote/objectbox.g.dart';
import 'package:knote/src/pages/text_editor_page.dart';
import 'package:utils_component/src/widget/custom_circular_bar.dart';
import 'package:utils_component/utils_component.dart';

import '../../../res.dart';
import '../../../widgets.dart';
import '../../backgound_ui.dart';
import 'package:flutter/material.dart';

part 'homelist.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static Route route() {
    //if(kIsWeb) return MaterialPageRoute<void>(builder: (_) => HomePage());
    return MaterialPageRoute<void>(builder: (_) => const HomeScreen());
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<Widget> homeList; //= HomeList.homeList;

  late AnimationController animationController;
  bool multiple = false;
  late final FirebaseManager _firebaseManager;
  late final User user;
  bool searching = false;

  final TextEditingController _searchController = TextEditingController();

  final StreamController<String> _searchStreamController =
      StreamController.broadcast();

  Stream<String> get searchStream => _searchStreamController.stream;



  Future<void> findNote(String data) async {
    _searchStreamController.sink.add(data);
    //_searchController.s//.addListener(() { })
    //return;
  }

  _defaultOnTapComingSoon() {
    Log.i('++++++++++ SnackBar ++++++++++');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('En développment | Soon :) ')));
  }

  @override
  void initState() {
    super.initState();
    user = BlocProvider.of<AuthenticationBloc>(context).state.user;
    _firebaseManager = FirebaseManager(user);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    //_uploadUserInCloud();
  }

  @override
  void dispose() {
    animationController.dispose();
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
    /*final DateTime now = DateTime.now();
    final String unique = "${now.year}${now.month}${now.day}"
        "${now.hour}${now.minute}${now.second}${now.millisecond}"
        "${now.microsecond}";
    _firebaseManager.addNoteInCloud(note: new NoteModel(
      id:  unique,
      email: user.email,
      creationTime: new DateTime.now(),
      modificationTime: new DateTime.now(),
    ));*/

    /*homeList = [
      HomeList(
        imagePath: 'assets/hotel/hotel_booking.png',
        navigateScreen: HotelHomeScreen(),
      ),
      HomeList(
        imagePath: 'assets/fitness_app/fitness_app.png',
        navigateScreen: FitnessAppHomeScreen(),
      ),
      HomeList(
        imagePath: 'assets/design_course/design_course.png',
        navigateScreen: DesignCourseHomeScreen(),
      ),
    ];*/

    return Scaffold(
      //backgroundColor: StyleAppTheme.white,
      backgroundColor: Colors.transparent,
      //endDrawer: DrawerView(),
      //drawerEdgeDragWidth: 100, //MediaQuery.of(context).size.width,
      //endDrawerEnableOpenDragGesture: false,
      body: BackgroundUI(
        index: 2,
        child: FutureBuilder<bool>(
          future: waitForAnimation(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    appBar(),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.search),
                                onPressed:(){}
                                     // Scaffold.of(context).openEndDrawer,
                                ),
                            Expanded(
                              child: TextField(
                                  controller: _searchController,
                                  key:
                                  const Key('homePage_search_textField'),
                                  onChanged: (query) {},
                                  onTap: (){
                                    setState(() {
                                      searching = !searching;
                                    });
                                  },
                                  decoration:
                                  const InputDecoration.collapsed(
                                      hintText: 'Find a documents')),
                            ),
                            IconButton(
                              //icon: Icon(Icons.notifications_none_rounded),
                                icon: const Icon(
                                    Icons.notifications_none_rounded),
                                onPressed:
                                    () {} //Scaffold.of(context).openEndDrawer,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Expanded(
                      child: BooleanBuilder(
                          check: searching,
                          ifTrue: _buildSearchView(),
                          ifFalse: StreamBuilder<List<NoteModel>>(
                            stream: _firebaseManager
                                .getAllNoteInCloud()
                                .asStream(),
                            //_firebaseManager.getAllNoteInCloud(user.email),
                            builder: (context, snapshot) {
                              //print('=================== ${snapshot.data} ==================');
                              if (!snapshot.hasData) {
                                return const CircularProgressMultiBar();
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: SizedBox(
                                    height: 200,
                                    child: Column(
                                      children: const [
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
                              }
                              else if (snapshot.data!.isEmpty) {
                                return Center(
                                  child: SizedBox(
                                    height: 200,
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons
                                              .sentiment_dissatisfied_rounded,
                                          size: 100,
                                        ),
                                        SizedBox(
                                          height: 8.0,
                                        ),
                                        Text('No document found')
                                      ],
                                    ),
                                  ),
                                );
                              }
                              //if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

                              else {
                                var data = snapshot.data!.map((note) {
                                  //var map = document.data();
                                  //print('+++++++ \n $map \n ++++++++');
                                  return note; //NoteModel.fromMap(map);
                                }).toList();

                                //data = data.

                                return GridView(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 12, right: 12),
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  children: List<Widget>.generate(
                                    snapshot.data!.length,
                                        (int index) {
                                      final int count = snapshot.data!.length;
                                      final Animation<double> animation =
                                      Tween<double>(begin: 0.0, end: 1.0)
                                          .animate(
                                        CurvedAnimation(
                                          parent: animationController,
                                          curve: Interval(
                                              (1 / count) * index, 1.0,
                                              curve: Curves.fastOutSlowIn),
                                        ),
                                      );
                                      animationController.forward();
                                      print(data[index].toString()+"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                                      data[index].toDisplay();
                                      return HomeListView(
                                        changeRatio: multiple,
                                        animation: animation,
                                        animationController:
                                        animationController,
                                        listData: NoteCard(
                                          color: Color(data[index].colorValue),
                                          changeInList: !multiple,
                                          note: data[index],
                                        ),
                                        //snapshot.data![index],
                                        onLongPress: () => showModalBottomSheet(
                                          constraints: const BoxConstraints(
                                            maxHeight: 400,
                                            minHeight:300,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              _buildBottomMenu(data[index]),

                                        ),

                                        onTap: () => Navigator.push(
                                            context,
                                            TextEditor.route(
                                              note: data[index],
                                            )),
                                        /*Navigator.push<dynamic>(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) =>
                                                  homeList[index].navigateScreen,
                                            ),
                                          );*/
                                      );
                                    },
                                  ),
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: multiple ? 2 : 1,
                                    mainAxisSpacing: 4.0,
                                    crossAxisSpacing: 12.0,
                                    childAspectRatio: multiple ? 1.5 : 3,
                                  ),
                                );
                              }
                            },
                          )
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchView(){
    return StreamBuilder<Object>(
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
        });
  }

  Container _buildBottomMenu(NoteModel doc){
    NoteModel note =  doc;
    /*if(doc is NoteModel){
      note = doc;
    }
    else {}*/
    return Container(
      //height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(18.0),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(Res.logo_1, height: 30, ),
            title: Text("${note.title}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Divider(color: Colors.white),

          ListTile(
            leading: Icon(Icons.archive_outlined,
                color: Theme.of(context).iconTheme.color,
            ),
            title: const Text("Move in archive"),
            onTap: (){
              _firebaseManager.deleteNote(
                  noteId: note.noteId,
                  //userId: user.noteId
              );
              Navigator.of(context).pop();
              setState(() {});
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.white,
                  content: Text('${note.title} note archived ✔',
                  style: const TextStyle(
                    color: Colors.black
                  ),),
                  //dismissDirection: DismissDirection.up,
                )
              );

            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline,
              color: Theme.of(context).iconTheme.color,

            ),
            title: const Text("Delete (Move in bin)"),
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                    // title: const Text("Option"),
                    content:  SizedBox(
                      //height: 20,
                      child: Text("Do you want to delete this note? \n"
                          "named : ${note.title}"),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed:
                        Navigator.of(context).pop,
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          _firebaseManager.deleteNote(
                              noteId: note.noteId,
                              //userId: user.noteId
                          );
                          Navigator.of(context).pop();
                          setState(() {});
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.white,
                                  content: Text('${note.title} note moved in bin',
                                    style: const TextStyle(
                                        color: Colors.black
                                    ),),
                                  //dismissDirection: DismissDirection.up,
                                )
                            );
                        },
                      ),
                    ],
                  ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.color_lens_outlined,
              color: Theme.of(context).iconTheme.color,

            ),
            title: const Text("Change color"),
            onTap: (){},
          ),
          const Divider(indent: 42.0, color: Colors.white,),
          ListTile(
            leading: Icon(Icons.save_alt_rounded,
              color: Theme.of(context).iconTheme.color,

            ),
            title: const Text("Saving mode"),
            onTap: (){},
          ),

        ],
      ),
    );
  }

  Widget appBar({onTap, openDrawer}) {
    AppBar appBar = AppBar();
    return SizedBox(
      height: appBar.preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: SizedBox(
                //color: Colors.grey,
                width: appBar.preferredSize.height - 8,
                height: appBar.preferredSize.height - 8,
              ),
            ),
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'K22D',
                    style: TextStyle(
                      fontSize: 22,
                      color: StyleAppTheme.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: SizedBox(
                width: appBar.preferredSize.height - 8,
                height: appBar.preferredSize.height - 8,
                //color: Colors.white,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(AppBar().preferredSize.height),
                    child: Icon(
                      multiple ? Icons.dashboard : Icons.view_agenda,
                      //color: StyleAppTheme.dark_grey,
                    ),
                    onTap: () {
                      setState(() {
                        multiple = !multiple;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeListView extends StatelessWidget {
  const HomeListView(
      {Key? key,
      required this.listData,
      this.onTap,
      this.changeRatio = false,
      this.onLongPress,
      required this.animationController,
      required this.animation})
      : super(key: key);

  final listData;
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
                        splashColor: Colors.grey.withOpacity(0.2),
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
