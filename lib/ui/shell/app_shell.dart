import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/ui/calendar/widgets/calendar_page.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/widgets/background_ui.dart';
import 'package:knote/ui/notes/widgets/archived_notes_page.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/ui/notes/widgets/trash_page.dart';
import 'package:knote/ui/settings/widgets/settings_page.dart';
import 'package:knote/ui/tasks/widgets/tasks_page.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  /// Path of the page shown in the shell; selects the bottom bar tab.
  final String location;

  /// Whether the app runs in a browser; only the web shows the side drawer.
  final bool isWeb;

  const AppShell({
    super.key,
    required this.child,
    this.location = '',
    this.isWeb = kIsWeb,
  });

  /// Smallest window width, in logical pixels, at which the web shows the
  /// side drawer instead of the bottom bar.
  static const sideNavigationMinWidth = 840.0;

  /// Whether the shell shows the side drawer: on the web, in a wide window.
  /// Phones, and narrow browser windows, keep the bottom bar.
  static bool showsSideNavigation({
    required bool isWeb,
    required double width,
  }) =>
      isWeb && width >= sideNavigationMinWidth;

  /// Whether the shell around [context] shows the side drawer, so pages can
  /// leave out the entries it already has.
  static bool usesSideNavigationOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_SideNavigationScope>()
          ?.enabled ??
      false;

  /// Route names of the side drawer entries, in display order.
  static const sideRouteNames = [
    NotesPage.routeName,
    TasksPage.routeName,
    CalendarPage.routeName,
    ArchivedNotesPage.routeName,
    TrashPage.routeName,
    SettingsPage.routeName,
  ];

  /// The side drawer entry for [location]. Settings sub-pages without an
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
        final sideNavigation = AppShell.showsSideNavigation(
          isWeb: widget.isWeb,
          width: constraints.maxWidth,
        );
        return _SideNavigationScope(
          enabled: sideNavigation,
          child: sideNavigation
              ? _buildWideShell(context)
              : _buildShell(context, tabIndex),
        );
      }),
    );
  }

  Widget _buildWideShell(BuildContext context) {
    return BackgroundUI(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            _SideNavigation(
              selectedIndex: AppShell.sideIndexFor(widget.location),
              onSelected: (index) =>
                  GoRouter.of(context).goNamed(AppShell.sideRouteNames[index]),
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
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.only(),
          child: widget.child,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: tabIndex,
          color: AppColors.of(context).navigationBar,
          backgroundColor: Colors.transparent,
          iconPadding: 20.00,
          items: [
            CurvedNavigationBarItem(
              child: const Icon(Icons.file_copy_outlined),
              label: context.l10n.navNotes,
            ),
            CurvedNavigationBarItem(
              child: const Icon(Icons.task),
              label: context.l10n.navTasks,
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
              child: const Icon(Icons.perm_identity),
              label: context.l10n.navYou,
            ),
          ],
          // go, not push: switching tabs replaces the page instead of
          // stacking it, so back doesn't walk through previous tabs.
          onTap: (index) {
            if (index == tabIndex) return;
            GoRouter.of(context).goNamed(AppShell.tabRouteNames[index]);
          },
        ),
      ),
    );
  }
}

/// Tells the pages inside [AppShell] whether the side drawer is shown.
class _SideNavigationScope extends InheritedWidget {
  const _SideNavigationScope({required this.enabled, required super.child});

  final bool enabled;

  @override
  bool updateShouldNotify(_SideNavigationScope oldWidget) =>
      enabled != oldWidget.enabled;
}

/// The permanent drawer on the left of the wide web layout.
class _SideNavigation extends StatelessWidget {
  const _SideNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const double _width = 264;

  // NavigationDrawer's default 12 dp tile padding on each side.
  static const double _tileWidth = _width - 24;

  // What the destination row leaves for the label: 16 dp of padding, the
  // 24 dp icon and a 12 dp gap.
  static const double _labelWidth = _tileWidth - 52;

  /// A label that fits the drawer, cut with an ellipsis if too long.
  static Widget _label(String text) => SizedBox(
        width: _labelWidth,
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DrawerTheme(
      data: DrawerTheme.of(context).copyWith(
        width: _width,
        shape: const RoundedRectangleBorder(),
      ),
      child: NavigationDrawerTheme(
        data: NavigationDrawerTheme.of(context).copyWith(
          indicatorSize: const Size(_tileWidth, 56),
        ),
        child: NavigationDrawer(
          backgroundColor: AppColors.of(context).navigationBar,
          elevation: 0,
          selectedIndex: selectedIndex,
          // go, not push, as with the bottom bar.
          onDestinationSelected: (index) {
            if (index != selectedIndex) onSelected(index);
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
              child: Text(
                'K.Note',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.file_copy_outlined),
              label: _label(l10n.navNotes),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.task_outlined),
              selectedIcon: const Icon(Icons.task),
              label: _label(l10n.navTasks),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              label: _label(l10n.calendar),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.archive_outlined),
              label: _label(l10n.archiveTitle),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.delete_outline),
              label: _label(l10n.binTitle),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              child: Divider(),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.perm_identity),
              label: _label(l10n.navProfile),
            ),
          ],
        ),
      ),
    );
  }
}
