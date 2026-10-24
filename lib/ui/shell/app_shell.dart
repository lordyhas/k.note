import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/ui/core/widgets/background_ui.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/ui/settings/widgets/settings_page.dart';
import 'package:knote/ui/tasks/widgets/tasks_page.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  /// Path of the page shown in the shell; selects the bottom bar tab.
  final String location;

  const AppShell({
    super.key,
    required this.child,
    this.location = '',
  });

  static Route route() {
    return MaterialPageRoute(
        builder: (_) => const AppShell(
              child: SizedBox(),
            ));
  }

  /// Route names of the bottom bar tabs, in display order.
  static const tabRouteNames = [
    NotesPage.routeName,
    TasksPage.routeName,
    SettingsPage.routeName,
  ];

  /// The bottom bar tab for [location], so the bar always matches the page
  /// shown, including after the system back button.
  static int tabIndexFor(String location) {
    if (location
        .startsWith('/${NotesPage.routeName}/${TasksPage.routeName}')) {
      return 1;
    }
    if (location.startsWith('/${SettingsPage.routeName}')) return 2;
    return 0;
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  //late final FirestoreService _firebaseManager;

  final screenColor = Colors.black;

  @override
  void initState() {
    // _firebaseManager = FirestoreService.user(
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
  //       Log.i('Write Report => FirestoreService.uploadUserInCloud(context)'
  //           ' : write document in Firestore');
  //       _firebaseManager.addUserInCloud(user: user);
  //     }

  //     ///Future.delayed(Duration(seconds: 2));

  //     User userUploaded =
  //         await _firebaseManager.getUserInCloud(userId: user.id);

  //     //context.read<AuthenticationBloc>().updateUser(userUploaded);
  //     if (userUploaded != User.empty) {
  //       Log.i('Read Report => FirestoreService.uploadUserInCloud(context)'
  //           ' : read doc in Firestore ');

  //       ///BlocProvider.of<AuthenticationBloc>(context).updateUser(userUploaded);
  //       //context.read<AuthenticationBloc>().updateUser(userUploaded)
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final tabIndex = AppShell.tabIndexFor(widget.location);
    // Tasks sits under Notes, so back already returns there; You is a
    // top-level route where back would close the app, so send it to Notes.
    final isSettingsRoot =
        widget.location == '/${SettingsPage.routeName}';
    return PopScope(
      canPop: !isSettingsRoot,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) GoRouter.of(context).goNamed(NotesPage.routeName);
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
                .goNamed(AppShell.tabRouteNames[index]);
          },
        ),
      ),
    );
  }
}
