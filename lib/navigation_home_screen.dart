import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/src/pages/setting_profile_screen.dart';
import 'package:knote/src/pages/custom_drawer/home_drawer.dart';

import 'data/database/firebase_manager.dart';


import 'package:flutter/cupertino.dart';

import 'package:knote/src/pages/old_text_editor_page.dart';
import 'package:knote/src/pages/screens/calendar_screen.dart';
import 'package:knote/widgets.dart';
import 'package:utils_component/utils_component.dart';

import './src/backgound_ui.dart';
import './src/pages/screens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/app_bloc.dart';
import 'data/authentication_repository.dart';

import 'src/pages/custom_drawer/drawer_user_controller.dart';


import 'src/pages/about_page.dart';

import 'src/pages/trash_can.dart';

class NavigationHomeScreen extends StatefulWidget {
  final Widget child;
  const NavigationHomeScreen({Key? key, required this.child}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(builder: (_) => const NavigationHomeScreen(child: SizedBox(),));
  }

  @override
  State<NavigationHomeScreen> createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {

  late final FirebaseManager _firebaseManager;

  final screenColor =  Colors.black;

  @override
  void initState() {
    _firebaseManager = FirebaseManager.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _uploadUserInCloud() async {
    if (BlocProvider.of<AuthenticationBloc>(context).state.isAuthenticated) {

      User user = BlocProvider.of<AuthenticationBloc>(context).state.user;
      Log.out('AuthenticationBloc(context.state.user)','$user ==== ====');

      if ( true/*user.photoMail != null*/) {
        Log.i('Write Report => FirebaseManager.uploadUserInCloud(context)'
            ' : write document in Firestore');
        _firebaseManager.addUserInCloud(user: user);

      }

      ///Future.delayed(Duration(seconds: 2));

      User userUploaded = await _firebaseManager.getUserInCloud(userId: user.id);

      //context.read<AuthenticationBloc>().updateUser(userUploaded);
      if (userUploaded != User.empty) {
        Log.i('Read Report => FirebaseManager.uploadUserInCloud(context)'
            ' : read doc in Firestore ');
        ///BlocProvider.of<AuthenticationBloc>(context).updateUser(userUploaded);
        //context.read<AuthenticationBloc>().updateUser(userUploaded)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundUI(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.only(),
          child: widget.child,
        ),

        bottomNavigationBar: CurvedNavigationBar(
          color: Colors.grey.shade900,
          backgroundColor: Colors.transparent,
          items: const [
            CurvedNavigationBarItem(
              child: Icon(Icons.file_copy_outlined),
              label: 'Notes',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.search),
              label: 'Search',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.chat_bubble_outline),
              label: 'Message',
            ),
            /*CurvedNavigationBarItem(
              child: Icon(Icons.newspaper),
              label: 'Feeds',
            ),*/
            CurvedNavigationBarItem(
              child: Icon(Icons.perm_identity),
              label: 'User',
            ),
          ],
          onTap: (index) {

            if(index == 0){
              GoRouter.of(context).pushNamed(HomeScreen.routeName);
            }
            else if(index == 1){
              GoRouter.of(context).pushNamed(OfflineScreen.routeName);
            }else if(index == 2){
              GoRouter.of(context).pushNamed(OfflineScreen.routeName);
            }
            else if(index == 3){
              GoRouter.of(context).pushNamed(SettingProfileScreen.routeName);
            }
          },
        ),

      ),
    );
  }

}


class NvHs extends StatefulWidget {
  const NvHs({Key? key}) : super(key: key);

  @override
  State<NvHs> createState() => _NvHsState();
}

class _NvHsState extends State<NvHs> {


  late final FirebaseManager _firebaseManager;
  Widget? screenView;
  DrawerIndex? drawerIndex;
  //Map<String, String>? text;


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



  @override
  Widget build(BuildContext context) {
    //_uploadUserInCloud();


    //text = BlocProvider.of<LanguageBloc>(context).state.strings;
    return WillPopScope(
      onWillPop: _willPopDialog,
      child: Container(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            //backgroundColor: StyleAppTheme.nearlyWhite,
            floatingActionButton: BlocBuilder<AuthenticationBloc,AuthState>(
              builder: (context, state) {
                switch(state.status){
                  case AuthenticationStatus.authenticated:
                    return FloatingActionButton(
                      tooltip: 'add new note',
                      onPressed: () => Navigator.push(context, OldTextEditor.route()),
                      child: const Icon(CupertinoIcons.add), //Icons.post_add
                    );

                  default:
                    return Container();
                }

              },
            ),
            //floatingActionButtonAnimator: FloatingActionButtonAnimator,
            body: DrawerUserControllerView(
              screenIndex: drawerIndex,
              drawerWidth: MediaQuery.of(context).size.width * 0.75,
              onDrawerCall: (DrawerIndex drawerIndexData) {
                changeIndex(drawerIndexData);
                //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
              },
              //todo : add screen here
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
              child: const AboutPage(),
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
            screenView = const FeedbackScreen();
          });
          break;

        case DrawerIndex.NoteTrash:
          setState(() {
            screenView = BackgroundUI(index: 2, child: const NoteTrash());
          });
          break;

        case DrawerIndex.Calendar:

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
                child: const ArchivedScreen()
            );
          });
          break;

        case DrawerIndex.Offline:
          setState(() {
            screenView = BackgroundUI(
                index: 2,
                child: const OfflineScreen()
            );
          });
          break;
      }

    }
  }
}

