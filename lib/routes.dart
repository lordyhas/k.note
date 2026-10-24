import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:knote/navigation_home_screen.dart';
import 'package:knote/src/pages/new_text_editor_page.dart';
import 'package:knote/src/pages/setting_page.dart';
import 'package:knote/src/pages/about_page.dart';
import 'package:knote/src/pages/login/signup_and_login.dart';
import 'package:knote/src/pages/screens.dart';
import 'package:knote/src/pages/task_editor.dart';
import 'package:knote/src/pages/trash_can.dart'; 
import 'package:knote/data/database/database_model.dart';

import 'data/app_bloc/authentication/authentication_bloc.dart';
import 'on_error_page.dart';

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
        errorBuilder: (context, state) => OnErrorPage(error: state.error),
        redirectLimit: 1,
        //initialLocation: HomeScreen.routeName,
        //initialLocation: "/${SettingProfileScreen.routeName}",
        routes: <RouteBase>[
          GoRoute(
            /// [Redirect to home screen or login page]
            name: "/",
            path: "/",
            redirect: (ctx, state) {
              if (authBloc.state.status == AuthenticationStatus.authenticated) {
                return "/${HomeScreen.routeName}";
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
                NavigationHomeScreen(location: state.uri.path, child: screen),
            routes: <RouteBase>[
              GoRoute(
                /// [HomeScreen]
                name: HomeScreen.routeName,
                path: "/${HomeScreen.routeName}",
                builder: (context, state) => const HomeScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    name: OfflineScreen.routeName,
                    path: OfflineScreen.routeName,
                    builder: (context, state) => const OfflineScreen(),
                  ),
                  GoRoute(
                    parentNavigatorKey: key,
                    name: TextEditor.routeName,
                    path: TextEditor.routeName,
                    builder: (context, state) =>
                        TextEditor(note: state.extra as NoteModel?),
                  ),
                  GoRoute(
                    name: TaskScreen.routeName,
                    path: TaskScreen.routeName,
                    builder: (context, state) => const TaskScreen(),
                  ),
                  GoRoute(
                    parentNavigatorKey: key,
                    name: TaskEditor.routeName,
                    path: TaskEditor.routeName,
                    builder: (context, state) {
                      final task = state.extra as CheckList?;
                      return TaskEditor(task: task);
                    },
                  ),
                ],
              ),
              GoRoute(
                  /// [SettingProfileScreen]
                  name: SettingProfileScreen.routeName,
                  path: "/${SettingProfileScreen.routeName}",
                  builder: (context, state) => const SettingProfileScreen(),
                  routes: [
                    GoRoute(
                      //parentNavigatorKey: parentKey,
                      name: 'table',
                      path: "product-table",
                      builder: (context, state) => const SizedBox(),
                    ),
                    GoRoute(
                      //parentNavigatorKey: parentKey,
                      name: NoteTrash.routeName,
                      path: NoteTrash.routeName,
                      builder: (context, state) => const NoteTrash(),
                    ),
                    GoRoute(
                      //parentNavigatorKey: parentKey,
                      name: AboutPage.settingsRouteName,
                      path: AboutPage.routeName,
                      builder: (context, state) => const AboutPage(),
                    ),
                    GoRoute(
                      /// [InvitedFriend]
                      name: InviteFriend.routeName,
                      path: InviteFriend.routeName,
                      builder: (context, state) => const InviteFriend(),
                    ),
                    GoRoute(
                      name: HelpScreen.routeName,
                      path: HelpScreen.routeName,
                      builder: (context, state) => const HelpScreen(),
                    ),
                    GoRoute(
                      name: FeedbackScreen.routeName,
                      path: FeedbackScreen.routeName,
                      builder: (context, state) => const FeedbackScreen(),
                    ),
                    GoRoute(
                      name: ArchivedScreen.routeName,
                      path: ArchivedScreen.routeName,
                      builder: (context, state) => const ArchivedScreen(),
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
                return "/${HomeScreen.routeName}";
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
