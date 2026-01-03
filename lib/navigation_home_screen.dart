import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/src/pages/setting_page.dart';

import './src/backgound_ui.dart';
import './src/pages/screens.dart';



class NavigationHomeScreen extends StatefulWidget {
  final Widget child;
  const NavigationHomeScreen({super.key, required this.child});

  static Route route() {
    return MaterialPageRoute(
        builder: (_) => const NavigationHomeScreen(
              child: SizedBox(),
            ));
  }

  @override
  State<NavigationHomeScreen> createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  //late final FirebaseManager _firebaseManager;

  final screenColor = Colors.black;

  @override
  void initState() {
    // _firebaseManager = FirebaseManager.user(
    //     BlocProvider.of<AuthenticationBloc>(context).state.user);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //todo: clean way to create  user in cloud

  // Future<void> _uploadUserInCloud() async {
  //   if (BlocProvider.of<AuthenticationBloc>(context).state.isAuthenticated) {
  //     User user = BlocProvider.of<AuthenticationBloc>(context).state.user;
  //     Log.out('AuthenticationBloc(context.state.user)', '$user ==== ====');

  //     if (true /*user.photoMail != null*/) {
  //       Log.i('Write Report => FirebaseManager.uploadUserInCloud(context)'
  //           ' : write document in Firestore');
  //       _firebaseManager.addUserInCloud(user: user);
  //     }

  //     ///Future.delayed(Duration(seconds: 2));

  //     User userUploaded =
  //         await _firebaseManager.getUserInCloud(userId: user.id);

  //     //context.read<AuthenticationBloc>().updateUser(userUploaded);
  //     if (userUploaded != User.empty) {
  //       Log.i('Read Report => FirebaseManager.uploadUserInCloud(context)'
  //           ' : read doc in Firestore ');

  //       ///BlocProvider.of<AuthenticationBloc>(context).updateUser(userUploaded);
  //       //context.read<AuthenticationBloc>().updateUser(userUploaded)
  //     }
  //   }
  // }



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
        // floatingActionButton: BooleanBuilder(
        //   condition: () {
        //     return _currentIndex != 1;
        //     // BlocProvider.of<AuthenticationBloc>(context)
        //     //     .state
        //     //     .isAuthenticated;
        //     //return true;
        //   },
        //   ifTrue: FloatingActionButton(
        //     child: const Icon(Icons.add),
        //     onPressed: () {
        //       showDialog(
        //         context: context,
        //         builder: (context) {
        //           return AlertDialog(
        //             title: const Text(
        //               "Choissisez un editeur",
        //               style: TextStyle(
        //                 fontWeight: FontWeight.w600,
        //               ),
        //             ),
        //             content: SizedBox(
        //               height: 120,
        //               child: Column(
        //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                 children: [
        //                   ListTile(
        //                     shape: RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.circular(10),
        //                         side: const BorderSide(
        //                           color: Colors.white,
        //                           width: 1,
        //                         )),
        //                     onTap: () {
        //                       GoRouter.of(context)
        //                           .pushNamed(TextEditor.routeName);
        //                       Navigator.of(context).pop();
        //                     },
        //                     title: const Text("Quill TextEditor"),
        //                   ),
        //                   ListTile(
        //                     shape: RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.circular(10),
        //                         side: const BorderSide(
        //                           color: Colors.white,
        //                           width: 1,
        //                         )),
        //                     onTap: () {
        //                       GoRouter.of(context)
        //                           .pushNamed(OldTextEditor.routeName);
        //                       Navigator.of(context).pop();
        //                     },
        //                     title: const Text("Classic TextEditor"),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //             actions: [
        //               ElevatedButton(
        //                   onPressed: Navigator.of(context).pop,
        //                   child: const Text("Annulé")),
        //             ],
        //           );
        //         },
        //       );
        //     },
        //   ),
        //   ifFalse: FloatingActionButton(
        //     onPressed: () async {
        //       await Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => const TaskEditor()),
        //       );
        //       setState(() {});
        //     },
        //     child: const Icon(Icons.task),
        //   ),
        // ),
        bottomNavigationBar: CurvedNavigationBar(
          color: Colors.grey.shade900,
          backgroundColor: Colors.transparent,
          items: const [
            CurvedNavigationBarItem(
              child: Icon(Icons.file_copy_outlined),
              label: 'Notes',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.task),
              label: 'Tasks',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.search),
              label: 'Search',
            ),

            /*CurvedNavigationBarItem(
              child: Icon(Icons.newspaper),
              label: 'Feeds',
            ),*/
            CurvedNavigationBarItem(
              child: Icon(Icons.perm_identity),
              label: 'You',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              GoRouter.of(context).pushNamed(HomeScreen.routeName);
            } else if (index == 1) {
              GoRouter.of(context).pushNamed(TaskScreen.routeName);
            } else if (index == 2) {
              GoRouter.of(context).pushNamed(OfflineScreen.routeName);
            } else if (index == 3) {
              GoRouter.of(context).pushNamed(SettingProfileScreen.routeName);
            }
          },
        ),
      ),
    );
  }
}

