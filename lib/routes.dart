import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/navigation_home_screen.dart';
import 'package:knote/src/pages/new_text_editor_page.dart';
import 'package:knote/src/pages/setting_page.dart';
import 'package:knote/src/pages/about_page.dart';
import 'package:knote/src/pages/login/signup_and_login.dart';
import 'package:knote/src/pages/screens.dart';
import 'package:knote/src/pages/trash_can.dart';
import 'package:knote/widgets.dart';

import 'data/app_bloc/authentication/authentication_bloc.dart';
import 'on_error_page.dart';

class AppRouter {

  const AppRouter._();

  static GoRouter routes({required GlobalKey<NavigatorState> key}) =>
  GoRouter(
    navigatorKey: key,
    errorBuilder: (context, state) => OnErrorPage(error: state.error),
    redirect: (_,state) {
      switch(BlocProvider.of<AuthenticationBloc>(_).state.status){
        case AuthenticationStatus.authenticated:
          return null;
        case AuthenticationStatus.unauthenticated:
          return LoginPage.routeName;
      }
    },
    initialLocation: HomeScreen.routeName,
    routes: <RouteBase>[
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(debugLabel: "__ShellRoute__"),
        builder: (context, state, screen) => NavigationHomeScreen(child: screen),
        routes: <RouteBase>[
          _homeGoRoute(parentKey: key),
        ],
      ),

      GoRoute( /// Login router
        redirect: (_,state) {
          switch(BlocProvider.of<AuthenticationBloc>(_).state.status){
            case AuthenticationStatus.authenticated:
              return HomeScreen.routeName;
            case AuthenticationStatus.unauthenticated:
              return null;
          }
        },
        parentNavigatorKey: key,
        name: LoginPage.routeName,
        path: LoginPage.routeName,
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );

  static _homeGoRoute({required GlobalKey<NavigatorState> parentKey}) =>
      GoRoute( /// [HomeScreen]
        name: HomeScreen.routeName,
        path: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
        redirect: (_,state) {
          switch(BlocProvider.of<AuthenticationBloc>(_).state.status){
            case AuthenticationStatus.authenticated:
              return null;
            case AuthenticationStatus.unauthenticated:
              return LoginPage.routeName;
          }
        },
        routes: <RouteBase>[
          GoRoute( /// [SettingProfileScreen]
              name: SettingProfileScreen.routeName,
              path: SettingProfileScreen.routeName,
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
              ]
          ),

          GoRoute( /// []
            name: "rate",
            path: "rate",
            builder: (context, state) => Column(
              children: [
                const Spacer(),
                ComingSoon(),
                const Spacer(),
              ],
            ),
          ),

          GoRoute( /// [AboutPage]
              name: AboutPage.routeName,
              path: AboutPage.routeName,
              builder: (context, state) => const AboutPage()
          ),

          GoRoute( /// [InvitedFriend]
            name: InviteFriend.routeName,
            path: InviteFriend.routeName,
            builder: (context, state) =>  const InviteFriend(),
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

          GoRoute(
            name: OfflineScreen.routeName,
            path: OfflineScreen.routeName,
            builder: (context, state) => const OfflineScreen(),
          ),

          GoRoute(
            parentNavigatorKey: parentKey,
            name: TextEditor.routeName,
            path: TextEditor.routeName,
            builder: (context, state) => TextEditor(),
          ),

        ],
      );
}

