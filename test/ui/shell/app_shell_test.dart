import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/ui/calendar/widgets/calendar_page.dart';
import 'package:knote/ui/notes/widgets/archived_notes_page.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/ui/notes/widgets/trash_page.dart';
import 'package:knote/ui/settings/widgets/settings_page.dart';
import 'package:knote/ui/shell/app_shell.dart';
import 'package:knote/ui/shell/side_navigation_scope.dart';
import 'package:knote/ui/tasks/widgets/tasks_page.dart';

import '../../helpers/localized_app.dart';

void main() {
  group('AppShell.tabIndexFor', () {
    test('maps each section to its tab', () {
      expect(AppShell.tabIndexFor('/home'), 0);
      expect(AppShell.tabIndexFor('/home/offline'), 0);
      expect(AppShell.tabIndexFor('/home/tasks'), 1);
      expect(AppShell.tabIndexFor('/user'), 2);
      expect(AppShell.tabIndexFor('/user/about'), 2);
      expect(AppShell.tabIndexFor('/user/calendar'), 2);
    });
  });

  group('AppShell.sideIndexFor', () {
    test('maps each section to its drawer entry', () {
      expect(AppShell.sideIndexFor('/home'), 0);
      expect(AppShell.sideIndexFor('/home/offline'), 0);
      expect(AppShell.sideIndexFor('/home/tasks'), 1);
      expect(AppShell.sideIndexFor('/user/calendar'), 2);
      expect(AppShell.sideIndexFor('/user/archived'), 3);
      expect(AppShell.sideIndexFor('/user/trash'), 4);
      expect(AppShell.sideIndexFor('/user'), 5);
      expect(AppShell.sideIndexFor('/user/about'), 5);
    });

    test('has one route name per entry', () {
      expect(AppShell.sideRouteNames, hasLength(6));
      expect(AppShell.sideRouteNames[AppShell.sideIndexFor('/user/trash')],
          TrashPage.routeName);
    });
  });

  group('AppShell.showsSideNavigation', () {
    test('only on the web, in a wide window', () {
      expect(AppShell.showsSideNavigation(isWeb: true, width: 1280), isTrue);
      expect(AppShell.showsSideNavigation(isWeb: true, width: 840), isTrue);
      expect(AppShell.showsSideNavigation(isWeb: true, width: 400), isFalse);
      expect(AppShell.showsSideNavigation(isWeb: false, width: 1280), isFalse);
    });
  });

  group('web side drawer', () {
    late GoRouter router;

    // A page that shows what SideNavigationScope.of returns.
    Widget page(String name) => Builder(
          builder: (context) => Center(
            child: Text('page:$name side:${SideNavigationScope.of(context)}'),
          ),
        );

    setUp(() {
      router = GoRouter(
        initialLocation: '/${NotesPage.routeName}',
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                AppShell(location: state.uri.path, isWeb: true, child: child),
            routes: [
              GoRoute(
                name: NotesPage.routeName,
                path: '/${NotesPage.routeName}',
                builder: (_, __) => page('notes'),
                routes: [
                  GoRoute(
                    name: TasksPage.routeName,
                    path: TasksPage.routeName,
                    builder: (_, __) => page('tasks'),
                  ),
                ],
              ),
              GoRoute(
                name: SettingsPage.routeName,
                path: '/${SettingsPage.routeName}',
                builder: (_, __) => page('you'),
                routes: [
                  GoRoute(
                    name: CalendarPage.routeName,
                    path: CalendarPage.routeName,
                    builder: (_, __) => page('calendar'),
                  ),
                  GoRoute(
                    name: ArchivedNotesPage.routeName,
                    path: ArchivedNotesPage.routeName,
                    builder: (_, __) => page('archived'),
                  ),
                  GoRoute(
                    name: TrashPage.routeName,
                    path: TrashPage.routeName,
                    builder: (_, __) => page('trash'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });

    tearDown(() => router.dispose());

    Future<void> pumpApp(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(localizedRouterApp(routerConfig: router));
      await tester.pumpAndSettle();
    }

    int drawerIndex(WidgetTester tester) => tester
        .widget<NavigationDrawer>(find.byType(NavigationDrawer))
        .selectedIndex!;

    testWidgets('a wide window shows the drawer, not the bottom bar',
        (tester) async {
      await pumpApp(tester, const Size(1280, 800));

      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(find.byType(CurvedNavigationBar), findsNothing);
      expect(find.text('page:notes side:true'), findsOneWidget);
      for (final label in [
        'Notes',
        'Tasks',
        'Calendar',
        'Archived notes',
        'Bin',
        'Profile & settings',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('a narrow window keeps the bottom bar', (tester) async {
      await pumpApp(tester, const Size(400, 800));

      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(CurvedNavigationBar), findsOneWidget);
      expect(find.text('page:notes side:false'), findsOneWidget);
    });

    testWidgets('drawer entries open their page and stay selected',
        (tester) async {
      await pumpApp(tester, const Size(1280, 800));

      for (final (label, name, index) in [
        ('Tasks', 'tasks', 1),
        ('Calendar', 'calendar', 2),
        ('Archived notes', 'archived', 3),
        ('Bin', 'trash', 4),
        ('Profile & settings', 'you', 5),
        ('Notes', 'notes', 0),
      ]) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.text('page:$name side:true'), findsOneWidget,
            reason: label);
        expect(drawerIndex(tester), index, reason: label);
      }
    });
  });

  group('bottom bar navigation', () {
    late GoRouter router;

    // Same shape as AppRouter's shell, with placeholder pages.
    setUp(() {
      Widget page(String name) => Center(child: Text('page:$name'));
      router = GoRouter(
        initialLocation: '/${NotesPage.routeName}',
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                AppShell(location: state.uri.path, child: child),
            routes: [
              GoRoute(
                name: NotesPage.routeName,
                path: '/${NotesPage.routeName}',
                builder: (_, __) => page('notes'),
                routes: [
                  GoRoute(
                    name: TasksPage.routeName,
                    path: TasksPage.routeName,
                    builder: (_, __) => page('tasks'),
                  ),
                ],
              ),
              GoRoute(
                name: SettingsPage.routeName,
                path: '/${SettingsPage.routeName}',
                builder: (_, __) => page('you'),
              ),
            ],
          ),
        ],
      );
    });

    tearDown(() => router.dispose());

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(localizedRouterApp(routerConfig: router));
      await tester.pumpAndSettle();
    }

    int barIndex(WidgetTester tester) => tester
        .widget<CurvedNavigationBar>(find.byType(CurvedNavigationBar))
        .index;

    Future<bool> pressBack(WidgetTester tester) async {
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      return handled;
    }

    testWidgets('back from Tasks returns to Notes and moves the bar',
        (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.text('page:tasks'), findsOneWidget);
      expect(barIndex(tester), 1);

      expect(await pressBack(tester), isTrue);

      expect(find.text('page:notes'), findsOneWidget);
      expect(barIndex(tester), 0);
    });

    testWidgets('back from You returns to Notes instead of closing the app',
        (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      expect(barIndex(tester), 2);

      expect(await pressBack(tester), isTrue);

      expect(find.text('page:notes'), findsOneWidget);
      expect(barIndex(tester), 0);
    });

    testWidgets('switching tabs does not stack them', (tester) async {
      await pumpApp(tester);
      for (final tab in ['Tasks', 'You', 'Tasks']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
      }
      expect(barIndex(tester), 1);

      await pressBack(tester);

      expect(find.text('page:notes'), findsOneWidget,
          reason: 'not back to You, the previous tab');
      expect(barIndex(tester), 0);
    });

    testWidgets('the bar follows navigation done in code', (tester) async {
      await pumpApp(tester);

      router.goNamed(SettingsPage.routeName);
      await tester.pumpAndSettle();

      expect(barIndex(tester), 2);
    });
  });
}
