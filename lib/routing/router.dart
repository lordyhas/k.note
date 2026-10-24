import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:knote/domain/models/note.dart';
import 'package:knote/domain/models/task.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/auth/widgets/login_page.dart';
import 'package:knote/ui/core/widgets/error_page.dart';
import 'package:knote/ui/notes/widgets/archived_notes_page.dart';
import 'package:knote/ui/notes/widgets/note_editor_page.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/ui/notes/widgets/offline_notes_page.dart';
import 'package:knote/ui/notes/widgets/trash_page.dart';
import 'package:knote/ui/settings/widgets/about_page.dart';
import 'package:knote/ui/settings/widgets/feedback_page.dart';
import 'package:knote/ui/settings/widgets/help_page.dart';
import 'package:knote/ui/settings/widgets/invite_friend_page.dart';
import 'package:knote/ui/settings/widgets/settings_page.dart';
import 'package:knote/ui/shell/app_shell.dart';
import 'package:knote/ui/tasks/widgets/task_editor_page.dart';
import 'package:knote/ui/tasks/widgets/tasks_page.dart';

class AppRouter {
  //const AppRouter._();

  /// Builds the root [GoRouter] tree and wires route refresh to authentication
  /// state changes.
  ///
  /// The `/` route redirects authenticated users to the main shell and
  /// unauthenticated users to the login page.
  static GoRouter routes({
    required GlobalKey<NavigatorState> key,
    required AuthenticationBloc authBloc,
  }) =>
      GoRouter(
        navigatorKey: key,
        refreshListenable: GoRouterRefreshStream(authBloc.stream),
        errorBuilder: (context, state) => ErrorPage(error: state.error),
        redirectLimit: 1,
        //initialLocation: NotesPage.routeName,
        //initialLocation: "/${SettingsPage.routeName}",
        routes: <RouteBase>[
          GoRoute(
            /// [Redirect to home screen or login page]
            name: "/",
            path: "/",
            redirect: (ctx, state) {
              if (authBloc.state.status == AuthenticationStatus.authenticated) {
                return "/${NotesPage.routeName}";
              } else {
                return "/${LoginPage.routeName}";
              }
            },
          ),

          GoRoute(
            /// [/]
            path: LogOut.routeName,
            name: "/${LogOut.routeName}",
            //pageBuilder: ,
            redirect: (ctx, state) {
              BlocProvider.of<AuthenticationBloc>(ctx).logout();
              return "/${LoginPage.routeName}";
            },
          ),

          ShellRoute(
            navigatorKey:
                GlobalKey<NavigatorState>(debugLabel: "__ShellRoute__"),
            builder: (context, state, screen) =>
                AppShell(location: state.uri.path, child: screen),
            routes: <RouteBase>[
              GoRoute(
                /// [NotesPage]
                name: NotesPage.routeName,
                path: "/${NotesPage.routeName}",
                builder: (context, state) => const NotesPage(),
                routes: <RouteBase>[
                  GoRoute(
                    name: OfflineNotesPage.routeName,
                    path: OfflineNotesPage.routeName,
                    builder: (context, state) => const OfflineNotesPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: key,
                    name: NoteEditorPage.routeName,
                    path: NoteEditorPage.routeName,
                    builder: (context, state) =>
                        NoteEditorPage(note: state.extra as NoteModel?),
                  ),
                  GoRoute(
                    name: TasksPage.routeName,
                    path: TasksPage.routeName,
                    builder: (context, state) => const TasksPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: key,
                    name: TaskEditorPage.routeName,
                    path: TaskEditorPage.routeName,
                    builder: (context, state) {
                      final task = state.extra as CheckList?;
                      return TaskEditorPage(task: task);
                    },
                  ),
                ],
              ),
              GoRoute(
                  /// [SettingsPage]
                  name: SettingsPage.routeName,
                  path: "/${SettingsPage.routeName}",
                  builder: (context, state) => const SettingsPage(),
                  routes: [
                    GoRoute(
                      //parentNavigatorKey: parentKey,
                      name: 'table',
                      path: "product-table",
                      builder: (context, state) => const SizedBox(),
                    ),
                    GoRoute(
                      //parentNavigatorKey: parentKey,
                      name: TrashPage.routeName,
                      path: TrashPage.routeName,
                      builder: (context, state) => const TrashPage(),
                    ),
                    GoRoute(
                      //parentNavigatorKey: parentKey,
                      name: AboutPage.settingsRouteName,
                      path: AboutPage.routeName,
                      builder: (context, state) => const AboutPage(),
                    ),
                    GoRoute(
                      /// [InvitedFriend]
                      name: InviteFriendPage.routeName,
                      path: InviteFriendPage.routeName,
                      builder: (context, state) => const InviteFriendPage(),
                    ),
                    GoRoute(
                      name: HelpPage.routeName,
                      path: HelpPage.routeName,
                      builder: (context, state) => const HelpPage(),
                    ),
                    GoRoute(
                      name: FeedbackPage.routeName,
                      path: FeedbackPage.routeName,
                      builder: (context, state) => const FeedbackPage(),
                    ),
                    GoRoute(
                      name: ArchivedNotesPage.routeName,
                      path: ArchivedNotesPage.routeName,
                      builder: (context, state) => const ArchivedNotesPage(),
                    ),
                  ]
              ),
            ],
          ),

          //_homeGoRoute(parentKey: key),

          GoRoute(
            /// Login router
            parentNavigatorKey: key,
            name: LoginPage.routeName,
            path: "/${LoginPage.routeName}",
            redirect: (ctx, state) {
              if (authBloc.state.status == AuthenticationStatus.authenticated) {
                return "/${NotesPage.routeName}";
              }
              return null;
            },
            builder: (context, state) => const LoginPage(),
          ),
        ],
      );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
