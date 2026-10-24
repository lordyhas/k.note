import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/src/pages/setting_page.dart';

import './src/backgound_ui.dart';
import './src/pages/screens.dart';

class NavigationHomeScreen extends StatefulWidget {
  final Widget child;

  /// Path of the page shown in the shell; selects the bottom bar tab.
  final String location;

  const NavigationHomeScreen({
    super.key,
    required this.child,
    this.location = '',
  });

  static Route route() {
    return MaterialPageRoute(
        builder: (_) => const NavigationHomeScreen(
              child: SizedBox(),
            ));
  }

  /// Route names of the bottom bar tabs, in display order.
  static const tabRouteNames = [
    HomeScreen.routeName,
    TaskScreen.routeName,
    SettingProfileScreen.routeName,
  ];

  /// The bottom bar tab for [location], so the bar always matches the page
  /// shown, including after the system back button.
  static int tabIndexFor(String location) {
    if (location
        .startsWith('/${HomeScreen.routeName}/${TaskScreen.routeName}')) {
      return 1;
    }
    if (location.startsWith('/${SettingProfileScreen.routeName}')) return 2;
    return 0;
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
    final tabIndex = NavigationHomeScreen.tabIndexFor(widget.location);
    // Tasks sits under Notes, so back already returns there; You is a
    // top-level route where back would close the app, so send it to Notes.
    final isSettingsRoot =
        widget.location == '/${SettingProfileScreen.routeName}';
    return PopScope(
      canPop: !isSettingsRoot,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) GoRouter.of(context).goNamed(HomeScreen.routeName);
      },
      child: _buildShell(context, tabIndex),
    );
  }

  Widget _buildShell(BuildContext context, int tabIndex) {
    return BackgroundUI(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.only(),
          child: widget.child,
        ),

        bottomNavigationBar: CurvedNavigationBar(
          index: tabIndex,
          color: Colors.grey.shade900,
          backgroundColor: Colors.transparent,
          iconPadding: 20.00,
          items: const [
            CurvedNavigationBarItem(
              child: Icon(Icons.file_copy_outlined),
              label: 'Notes',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.task),
              label: 'Tasks',
            ),
            /*CurvedNavigationBarItem(
              child: Icon(Icons.search),
              label: 'Search',
            ),*/

            /*CurvedNavigationBarItem(
              child: Icon(Icons.newspaper),
              label: 'Feeds',
            ),*/
            CurvedNavigationBarItem(
              child: Icon(Icons.perm_identity),
              label: 'You',
            ),
          ],
          // go, not push: switching tabs replaces the page instead of
          // stacking it, so back doesn't walk through previous tabs.
          onTap: (index) {
            if (index == tabIndex) return;
            GoRouter.of(context)
                .goNamed(NavigationHomeScreen.tabRouteNames[index]);
          },
        ),
      ),
    );
  }
}
