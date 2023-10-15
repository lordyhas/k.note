import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:knote/src/pages/login/signup_and_login.dart';
import 'package:knote/src/pages/screens.dart';

import 'on_error_page.dart';

class AppRouter extends GoRouter {
  final GlobalKey<NavigatorState> key;
  AppRouter({
    required this.key,
  }) : super(
          navigatorKey: key,
          errorBuilder: (context, state) => OnErrorPage(error: state.error),
          initialLocation: "/",
          routes: <RouteBase>[
            GoRoute(
              parentNavigatorKey: key,
              path: "/index",
              redirect: (_,state) {
                return null;
              },
            ),

            ShellRoute(
              // navigatorKey: shellNavigatorKey,
              builder: (context, state, screen) => Container(child: screen),
              routes: <RouteBase>[
                _homeGoRoute(parentKey: key),
              ],
            ),

            GoRoute(
              parentNavigatorKey: key,
              name: LoginPage.routeName,
              path: LoginPage.routeName,
              builder: (context, state) => const LoginPage(),
            ),
          ],
        );

  static _homeGoRoute({required GlobalKey<NavigatorState> parentKey}) =>
      GoRoute(
        name: HomeScreen.routeName,
        path: HomeScreen.routeName,
        redirect: (_,state) {
          if(BlocProvider.of<AuthenticationBloc>(_).state.isAuthenticated){
            return null;
          }
          return LoginPage.routeUrl;
        },
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
          GoRoute(
            //parentNavigatorKey: parentKey,
            name: "fil",
            path: "filter-item",
            builder: (context, state) => const SizedBox(),
          ),

        ],
      );
}

