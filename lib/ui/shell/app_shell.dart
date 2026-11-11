import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/ui/calendar/widgets/calendar_page.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/widgets/background_ui.dart';
import 'package:knote/ui/core/widgets/responsive.dart';
import 'package:knote/ui/notes/widgets/archived_notes_page.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/ui/notes/widgets/trash_page.dart';
import 'package:knote/ui/settings/widgets/settings_page.dart';
import 'package:knote/ui/shell/side_navigation_pane.dart';
import 'package:knote/ui/shell/side_navigation_scope.dart';
import 'package:knote/ui/tasks/widgets/tasks_page.dart';

/// Where the shell puts its navigation, depending on the window width.
enum ShellNavigation {
  /// A bar under the page: phones in portrait and narrow windows.
  bottomBar,

  /// A rail of icons on the left: phones in landscape, small tablets.
  rail,

  /// A pane with icons and labels on the left: tablets and desktop windows.
  pane,
}

class AppShell extends StatefulWidget {
  final Widget child;

  /// Path of the page shown in the shell; selects the navigation entry.
  final String location;

  const AppShell({
    super.key,
    required this.child,
    this.location = '',
  });

  /// The navigation for a window [width] logical pixels wide, on every
  /// platform (see [Breakpoints]).
  static ShellNavigation navigationFor(double width) {
    if (width >= Breakpoints.expanded) return ShellNavigation.pane;
    if (width >= Breakpoints.medium) return ShellNavigation.rail;
    return ShellNavigation.bottomBar;
  }

  /// Route names of the side navigation entries, in display order.
  static const sideRouteNames = [
    NotesPage.routeName,
    TasksPage.routeName,
    CalendarPage.routeName,
    ArchivedNotesPage.routeName,
    TrashPage.routeName,
    SettingsPage.routeName,
  ];

  /// The side navigation entry for [location]. Settings sub-pages without an
  /// entry of their own (about, help...) select Profile & settings.
  static int sideIndexFor(String location) {
    const settings = '/${SettingsPage.routeName}';
    if (location.startsWith('/${NotesPage.routeName}/${TasksPage.routeName}')) {
      return 1;
    }
    if (location.startsWith('$settings/${CalendarPage.routeName}')) return 2;
    if (location.startsWith('$settings/${ArchivedNotesPage.routeName}')) {
      return 3;
    }
    if (location.startsWith('$settings/${TrashPage.routeName}')) return 4;
    if (location.startsWith(settings)) return 5;
    return 0;
  }

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
    if (location.startsWith('/${NotesPage.routeName}/${TasksPage.routeName}')) {
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
    final isSettingsRoot = widget.location == '/${SettingsPage.routeName}';
    return PopScope(
      canPop: !isSettingsRoot,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) GoRouter.of(context).goNamed(NotesPage.routeName);
      },
      child: LayoutBuilder(builder: (context, constraints) {
        final navigation = AppShell.navigationFor(constraints.maxWidth);
        final sideNavigation = navigation != ShellNavigation.bottomBar;
        return SideNavigationScope(
          enabled: sideNavigation,
          child: sideNavigation
              ? _buildWideShell(context,
                  expanded: navigation == ShellNavigation.pane)
              : _buildShell(context, tabIndex),
        );
      }),
    );
  }

  Widget _buildWideShell(BuildContext context, {required bool expanded}) {
    final l10n = context.l10n;
    return BackgroundUI(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            SideNavigationPane(
              expanded: expanded,
              title: 'K.Note',
              selectedIndex: AppShell.sideIndexFor(widget.location),
              // go, not push, as with the bottom bar.
              onSelected: (index) =>
                  GoRouter.of(context).goNamed(AppShell.sideRouteNames[index]),
              // Profile & settings sits apart, under a divider.
              footerCount: 1,
              destinations: [
                SideNavigationDestination(
                  icon: Icons.file_copy_outlined,
                  selectedIcon: Icons.file_copy,
                  label: l10n.navNotes,
                ),
                SideNavigationDestination(
                  icon: Icons.task_outlined,
                  selectedIcon: Icons.task,
                  label: l10n.navTasks,
                ),
                SideNavigationDestination(
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today,
                  label: l10n.calendar,
                ),
                SideNavigationDestination(
                  icon: Icons.archive_outlined,
                  selectedIcon: Icons.archive,
                  label: l10n.archiveTitle,
                ),
                SideNavigationDestination(
                  icon: Icons.delete_outline,
                  selectedIcon: Icons.delete,
                  label: l10n.binTitle,
                ),
                SideNavigationDestination(
                  icon: Icons.perm_identity,
                  selectedIcon: Icons.person,
                  label: l10n.navProfile,
                ),
              ],
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }

  Widget _buildShell(BuildContext context, int tabIndex) {
    return BackgroundUI(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: tabIndex,
          // go, not push: switching tabs replaces the page instead of
          // stacking it, so back doesn't walk through previous tabs.
          onDestinationSelected: (index) {
            if (index == tabIndex) return;
            GoRouter.of(context).goNamed(AppShell.tabRouteNames[index]);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.file_copy_outlined),
              selectedIcon: const Icon(Icons.file_copy),
              label: context.l10n.navNotes,
            ),
            NavigationDestination(
              icon: const Icon(Icons.task_outlined),
              selectedIcon: const Icon(Icons.task),
              label: context.l10n.navTasks,
            ),
            NavigationDestination(
              icon: const Icon(Icons.perm_identity),
              selectedIcon: const Icon(Icons.person),
              label: context.l10n.navYou,
            ),
          ],
        ),
      ),
    );
  }
}
