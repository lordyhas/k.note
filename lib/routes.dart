import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:knote/navigation_home_screen.dart';
import 'package:knote/src/backgound_ui.dart';
import 'package:knote/src/pages/about_page.dart';
import 'package:knote/src/pages/login/signup_and_login.dart';
import 'package:knote/src/pages/screens.dart';
import 'package:knote/src/pages/trash_can.dart';
import 'package:knote/widgets.dart';

import 'on_error_page.dart';

class AppRouter {
  //final GlobalKey<NavigatorState> key;

  static GoRouter routes({required GlobalKey<NavigatorState> key}) => GoRouter(
          navigatorKey: key,
          errorBuilder: (context, state) => OnErrorPage(error: state.error),
          initialLocation: HomeScreen.routeName,
          routes: <RouteBase>[
            ShellRoute(
              navigatorKey: GlobalKey<NavigatorState>(),
              builder: (context, state, screen) => NavigationHomeScreen(child: screen),
              routes: <RouteBase>[
                _homeGoRoute(parentKey: key),
              ],
            ),

            GoRoute(
              parentNavigatorKey: key,
              name: LoginPage.routeName,
              path: LoginPage.routeUrl,
              builder: (context, state) => const LoginPage(),
            ),
          ],
        );

  static _homeGoRoute({required GlobalKey<NavigatorState> parentKey}) =>
      GoRoute(
        name: HomeScreen.routeName,
        path: HomeScreen.routeName,
        /*redirect: (_,state) {
          if(BlocProvider.of<AuthenticationBloc>(_).state.isAuthenticated){
            return null;
          }
          return null; //LoginPage.routeUrl;
        },*/
        builder: (context, state) {
          return const HomeScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            name: '--user',
            path: 'user',
            builder: (context, state) {
              return const SizedBox();
            },
            routes: [
              GoRoute(
                //parentNavigatorKey: parentKey,
                name: 'table',
                path: "product-table",
                builder: (context, state) => const SizedBox(),
              ),
            ]
          ),
          /*GoRoute(
            parentNavigatorKey: parentKey,
            name: HelpScreen.routeName,
            path: HelpScreen.routeName,
            builder: (context, state) => BackgroundUI(child: const HelpScreen()),
          ),*/
          GoRoute(
            name: "rate",
            path: "rate",
            builder: (context, state) => BackgroundUI(
              index: 2,
              child: Column(
                children: [
                  const Spacer(),
                  ComingSoon(),
                  const Spacer(),
                ],
              ),
            ),
          ),

          GoRoute(
            name: AboutPage.routeName,
            path: AboutPage.routeName,
            builder: (context, state) => BackgroundUI(
              index: 0,
              child: const AboutPage(),
            )
          ),

          GoRoute(
            name: InviteFriend.routeName,
            path: InviteFriend.routeName,
            builder: (context, state) =>  BackgroundUI(
                child: const InviteFriend()
            ),
          ),

          GoRoute(
            name: HelpScreen.routeName,
            path: HelpScreen.routeName,
            builder: (context, state) => BackgroundUI(
              child: const HelpScreen(),
            ),
          ),

          GoRoute(
            name: FeedbackScreen.routeName,
            path: FeedbackScreen.routeName,
            builder: (context, state) => const FeedbackScreen(),
          ),

          GoRoute(
            name: ArchivedScreen.routeName,
            path: ArchivedScreen.routeName,
            builder: (context, state) => BackgroundUI(
                index: 2,
                child: const ArchivedScreen()
            ),
          ),

          GoRoute(
            name: OfflineScreen.routeName,
            path: OfflineScreen.routeName,
            builder: (context, state) => BackgroundUI(
                index: 2,
                child: const OfflineScreen()
            ),
          ),

        ],
      );
}

