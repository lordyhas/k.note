
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:knote/data/app_bloc/auth_repository/repository.dart';
import 'package:knote/data/app_bloc/auth_repository/repository.dart';
import 'package:knote/data/database/firebase_manager.dart';
import 'package:knote/src/pages/text_editor_page.dart';
import 'package:knote/src/pages/screens/calendar_screen.dart';
import 'package:knote/widgets.dart';
import 'package:utils_component/utils_component.dart';

import './data/theme_and_language_cubit.dart';
import './src/backgound_ui.dart';
import './src/pages/screens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/app_bloc.dart';
import 'data/authentication_repository.dart';
import 'data/values.dart';
import 'src/pages/custom_drawer/drawer_user_controller.dart';
import 'src/pages/custom_drawer/home_drawer.dart';
//import 'feedback_screen.dart';
//import 'help_screen.dart';
//import 'home_screen.dart';
//import 'invite_friend_screen.dart';
import 'package:flutter/material.dart';

import 'src/pages/custom_drawer/home_drawer.dart';
import 'data/value/styles.dart';
import 'src/pages/screens/home_screen.dart';

import 'src/pages/about_page.dart';
import 'src/pages/screens.dart';
import 'src/pages/trash_can.dart';

class NavigationHomeScreen extends StatefulWidget {
  const NavigationHomeScreen({Key? key}) : super(key: key);


  static Route route() {
    //if(kIsWeb) return MaterialPageRoute<void>(builder: (_) => HomePage());
    return MaterialPageRoute(builder: (_) => const NavigationHomeScreen());
  }

  @override
  State<NavigationHomeScreen> createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {

  late final FirebaseManager _firebaseManager;
  Widget? screenView;
  DrawerIndex? drawerIndex;
  var text;


  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const HomeScreen();
    _firebaseManager = FirebaseManager.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    //_firebaseManager.close();
  }


  Future<bool> _willPopDialog() async {
    if (drawerIndex != DrawerIndex.HOME) {
      changeIndex(DrawerIndex.HOME);
      return false;
    }
    else {
      return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Exit K.NOTE",
              style: Theme.of(context).textTheme.bodyText2,
            ),
            content: const Text("Do you want to exit K.NOTE ?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Quit"),
              ),
            ],
          ))) ?? false ;
    }

  }
  /*
  Future<bool> _willPopDialog() async {
    bool value = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      headerAnimationLoop: false,
      animType: AnimType.TOPSLIDE,
      title: 'Warning',
      desc: 'Are you sure you want to delete the item',
      //btnCancelColor: Theme.of(context).,
      btnCancelOnPress: () {
        setState(() {
          value = false;
        });
      },
      //() => Navigator.of(context).pop(false),
      btnOkColor: Theme.of(context).accentColor,
      btnOkOnPress: () {
        setState(() {
          value = true;
        });
      }, //() => Navigator.of(context).pop(true)
    ).show();
    return value;
    /*return (await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Are you sure",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text("Do you want to exit Exploress ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Yes"),
            ),
          ],
        ))) ?? false;*/
  }*/

  _uploadUserInCloud() async {
    if (BlocProvider.of<AuthenticationBloc>(context).state.status ==
        AuthenticationStatus.authenticated) {
      //User user = context.watch<AuthenticationBloc>().state.user;
      User user = BlocProvider.of<AuthenticationBloc>(context).state.user;
      Log.out('AuthenticationBloc(context.state.user)','$user ==== ====');


      if ( true/*user.photoMail != null*/) {
        /*var avatar = (await NetworkAssetBundle(Uri.parse(user.photoMail!))
            .load(user.photoMail!))
            .buffer
            .asUint8List();*/
        Log.i('Write Report => FirebaseManager.uploadUserInCloud(context)'
            ' : write document in Firestore');
        _firebaseManager.addUserInCloud(user: user);

        /*.copyWith(
            photoCloud: Blob(avatar),
          )*/
      }
      //else firebaseManager.addUserInCloud(user: user);
      //Future.delayed(Duration(seconds: 2));

      User userUploaded = await _firebaseManager.getUserInCloud(userId: user.id);

      //context.read<AuthenticationBloc>().updateUser(userUploaded);
      if (userUploaded != User.empty) {
        Log.i('Read Report => FirebaseManager.uploadUserInCloud(context)'
            ' : read doc in Firestore ');
        BlocProvider.of<AuthenticationBloc>(context).updateUser(userUploaded);
        //context.read<AuthenticationBloc>().updateUser(userUploaded);

      }

    }
  }



  @override
  Widget build(BuildContext context) {
    _uploadUserInCloud();


    text = BlocProvider.of<LanguageBloc>(context).state.strings;
    return WillPopScope(
      onWillPop: _willPopDialog,
      child: Container(
        //color: BlocProvider.of<StyleCubit>(context).state.nearlyWhite1,
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            //backgroundColor: StyleAppTheme.nearlyWhite,
            floatingActionButton: BlocBuilder<AuthenticationBloc,AuthenticationState>(
              builder: (context, state) {
                switch(state.status){
                  case AuthenticationStatus.authenticated:
                    return FloatingActionButton(
                      tooltip: 'add new note',
                      onPressed: () => Navigator.push(context, TextEditor.route()),
                      child: const Icon(CupertinoIcons.add), //Icons.post_add
                    );

                  default:
                    return Container();
                }

              },
            ),
            //floatingActionButtonAnimator: FloatingActionButtonAnimator,
            body: DrawerUserController(
              screenIndex: drawerIndex,
              drawerWidth: MediaQuery.of(context).size.width * 0.75,
              onDrawerCall: (DrawerIndex drawerIndexData) {
                changeIndex(drawerIndexData);
                //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
              },
              screenView: screenView,
              //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
            ),
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexData) {

    if (drawerIndex != drawerIndexData) {
      drawerIndex = drawerIndexData;

      switch(drawerIndexData){

        case DrawerIndex.HOME:
          setState(() {
            screenView = const HomeScreen();
          });
          break;



        case DrawerIndex.Help:
          //setState((){});
          setState(() {
            screenView = BackgroundUI(child: HelpScreen());
          });
          break;

        case DrawerIndex.Rate:

          setState(() {
            screenView = BackgroundUI(
              index: 2,
              child: Column(
                children: [
                  const Spacer(),
                  ComingSoon(),
                  const Spacer(),
                ],
              ),
            );

          });
          break;

        case DrawerIndex.About:
          setState(() {
            screenView = BackgroundUI(
              index: 0,
              child: AboutPage(text: text,),
            );
          });
          break;

        case DrawerIndex.Invite:
          setState(() {
            screenView = BackgroundUI(
                child: const InviteFriend()
            );
          });
          break;

        case DrawerIndex.FeedBack:
          setState(() {
            screenView = FeedbackScreen();
          });
          break;

        case DrawerIndex.NoteTrash:
          setState(() {
            screenView = BackgroundUI(
                index: 2,
                child: const NoteTrash()
            );
          });
          break;

        case DrawerIndex.Calendar:
          CalendarScreen.calendar(context);
          /*setState(() {
            screenView = BackgroundUI(
                index: 2,
                child: CalendarScreen()
            );
          });*/
          break;

        case DrawerIndex.Archived:
          setState(() {
            screenView = BackgroundUI(
                index: 2,
                child: ArchivedScreen()
            );
          });
          break;

        case DrawerIndex.Offline:
          setState(() {
            screenView = BackgroundUI(
                index: 2,
                child: OfflineScreen()
            );
          });
          break;
      }

    }
  }
}
