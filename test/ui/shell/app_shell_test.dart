import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/ui/settings/widgets/settings_page.dart';
import 'package:knote/ui/shell/app_shell.dart';
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
