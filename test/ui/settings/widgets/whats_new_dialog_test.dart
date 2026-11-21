import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:knote/data/services/whats_new_service.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/ui/settings/widgets/whats_new_dialog.dart';
import 'package:knote/ui/shell/app_shell.dart';

import '../../../helpers/localized_app.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('lists the changes of the release, in French too',
      (tester) async {
    await tester.pumpWidget(localizedApp(
      locale: const Locale('fr'),
      home: const WhatsNewDialog(version: '0.7.0'),
    ));

    expect(find.text('Quoi de neuf'), findsOneWidget);
    expect(find.text('Version 0.7.0'), findsOneWidget);
    expect(find.text('Un nouvel éditeur de notes'), findsOneWidget);
  });

  group('after an update', () {
    Future<void> pumpShell(WidgetTester tester, WhatsNewService service) {
      final router = GoRouter(
        initialLocation: '/${NotesPage.routeName}',
        routes: [
          ShellRoute(
            builder: (context, state, child) => AppShell(
                location: state.uri.path, whatsNew: service, child: child),
            routes: [
              GoRoute(
                name: NotesPage.routeName,
                path: '/${NotesPage.routeName}',
                builder: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      return tester.pumpWidget(localizedRouterApp(routerConfig: router));
    }

    WhatsNewService service(String version) => WhatsNewService(
        currentVersion: () async => version,
        preferences: SharedPreferencesAsync());

    testWidgets('the shell shows "What\'s new" once per version',
        (tester) async {
      await pumpShell(tester, service('0.7.0'));
      await tester.pumpAndSettle();

      expect(find.byType(WhatsNewDialog), findsOneWidget);
      await tester.tap(find.byKey(const Key('__whatsNew_continue__')));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsNewDialog), findsNothing);

      // Next launch of the same version.
      await tester.pumpWidget(const SizedBox());
      await pumpShell(tester, service('0.7.0'));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsNewDialog), findsNothing);
    });
  });
}
