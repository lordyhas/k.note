import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/data/app_bloc/authentication/authentication_bloc.dart';
import 'package:knote/data/authentication_repository.dart';
import 'package:knote/routes.dart';
import 'package:knote/src/pages/about_page.dart';
import 'package:knote/src/pages/new_text_editor_page.dart';
import 'package:knote/src/pages/screens.dart';
import 'package:knote/src/pages/setting_page.dart';
import 'package:knote/src/pages/task_editor.dart';
import 'package:knote/src/pages/trash_can.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _testUser = User(
  id: 'test-id',
  email: 'test@example.com',
  name: 'Test User',
  photoMail: null,
);

void main() {
  late AuthRepository authRepository;
  late StreamController<User> userStreamController;

  GoRouter buildRouter({required bool authenticated}) {
    when(() => authRepository.currentUser)
        .thenReturn(authenticated ? _testUser : User.empty);
    final authBloc = AuthenticationBloc(authRepository: authRepository);
    final navigatorKey = GlobalKey<NavigatorState>();
    return AppRouter.routes(key: navigatorKey, authBloc: authBloc);
  }

  setUp(() {
    authRepository = MockAuthRepository();
    userStreamController = StreamController<User>();
    when(() => authRepository.user)
        .thenAnswer((_) => userStreamController.stream);
    when(() => authRepository.logOut()).thenAnswer((_) async {});
  });

  tearDown(() {
    userStreamController.close();
  });

  group('AppRouter — configuration', () {
    test('router is created successfully when authenticated', () {
      final router = buildRouter(authenticated: true);
      expect(router, isNotNull);
      expect(router.configuration.routes, isNotEmpty);
      router.dispose();
    });

    test('router is created successfully when unauthenticated', () {
      final router = buildRouter(authenticated: false);
      expect(router, isNotNull);
      expect(router.configuration.routes, isNotEmpty);
      router.dispose();
    });

    test('router has at least 4 top-level routes', () {
      // Expected: "/", "/r/home", "/logout", ShellRoute, "/login"
      final router = buildRouter(authenticated: false);
      expect(router.configuration.routes.length, greaterThanOrEqualTo(4));
      router.dispose();
    });

    test('router contains a ShellRoute for navigation shell', () {
      final router = buildRouter(authenticated: false);
      final hasShellRoute =
          router.configuration.routes.any((r) => r is ShellRoute);
      expect(hasShellRoute, isTrue);
      router.dispose();
    });

    test('ShellRoute contains home and settings sub-routes', () {
      final router = buildRouter(authenticated: false);
      final shellRoute =
          router.configuration.routes.whereType<ShellRoute>().first;
      // ShellRoute should contain at least 2 routes (home branch + settings branch)
      expect(shellRoute.routes.length, greaterThanOrEqualTo(2));
      router.dispose();
    });

    test('home and settings routes have their feature sub-routes', () {
      final router = buildRouter(authenticated: false);
      final shellRoute =
          router.configuration.routes.whereType<ShellRoute>().first;
      Set<String?> childNames(String parentName) => shellRoute.routes
          .whereType<GoRoute>()
          .singleWhere((route) => route.name == parentName)
          .routes
          .whereType<GoRoute>()
          .map((route) => route.name)
          .toSet();

      expect(
          childNames(HomeScreen.routeName),
          containsAll([
            OfflineScreen.routeName,
            TextEditor.routeName,
            TaskScreen.routeName,
            TaskEditor.routeName,
          ]));
      expect(
          childNames(SettingProfileScreen.routeName),
          containsAll([
            NoteTrash.routeName,
            AboutPage.settingsRouteName,
            InviteFriend.routeName,
            HelpScreen.routeName,
            FeedbackScreen.routeName,
            ArchivedScreen.routeName,
          ]));
      router.dispose();
    });
  });

  group('GoRouterRefreshStream', () {
    test('notifies listeners when stream emits an event', () async {
      final controller = StreamController<dynamic>();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      var notified = false;
      refreshStream.addListener(() {
        notified = true;
      });

      controller.add('auth-changed');
      await Future.delayed(Duration.zero);

      expect(notified, isTrue);

      refreshStream.dispose();
      await controller.close();
    });

    test('can be disposed without error', () {
      final controller = StreamController<dynamic>();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      expect(() => refreshStream.dispose(), returnsNormally);
      controller.close();
    });

    test('handles multiple emissions', () async {
      final controller = StreamController<dynamic>();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      var count = 0;
      refreshStream.addListener(() {
        count++;
      });

      controller.add('event1');
      await Future.delayed(Duration.zero);
      controller.add('event2');
      await Future.delayed(Duration.zero);

      expect(count, 2);

      refreshStream.dispose();
      await controller.close();
    });
  });
}
