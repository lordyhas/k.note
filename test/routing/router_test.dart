import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/routing/router.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/notes/widgets/archived_notes_page.dart';
import 'package:knote/ui/notes/widgets/note_editor_page.dart';
import 'package:knote/ui/notes/widgets/notes_page.dart';
import 'package:knote/ui/notes/widgets/trash_page.dart';
import 'package:knote/ui/settings/widgets/about_page.dart';
import 'package:knote/ui/settings/widgets/feedback_page.dart';
import 'package:knote/ui/settings/widgets/settings_page.dart';
import 'package:knote/ui/tasks/widgets/task_editor_page.dart';
import 'package:knote/ui/tasks/widgets/tasks_page.dart';

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
          childNames(NotesPage.routeName),
          containsAll([
            NoteEditorPage.routeName,
            TasksPage.routeName,
            TaskEditorPage.routeName,
          ]));
      expect(
          childNames(SettingsPage.routeName),
          containsAll([
            TrashPage.routeName,
            AboutPage.settingsRouteName,
            FeedbackPage.routeName,
            ArchivedNotesPage.routeName,
          ]));
      router.dispose();
    });
  });

  group('redirectForEmailVerification', () {
    final unverified =
        AuthState.authenticated(_testUser.copyWith(isCheckMail: false));
    final verified =
        AuthState.authenticated(_testUser.copyWith(isCheckMail: true));
    const signedOut = AuthState.unauthenticated();

    test('keeps an unverified user on the verification page', () {
      for (final location in ['/home', '/user/trash', '/login', '/']) {
        expect(
            redirectForEmailVerification(unverified, location), '/verify-email',
            reason: location);
      }
      expect(redirectForEmailVerification(unverified, '/verify-email'), isNull);
    });

    test('sends verified and signed-out users away from the page', () {
      expect(redirectForEmailVerification(verified, '/verify-email'), '/home');
      expect(
          redirectForEmailVerification(signedOut, '/verify-email'), '/login');
    });

    test('leaves other routes to the route redirects', () {
      expect(redirectForEmailVerification(verified, '/home'), isNull);
      expect(redirectForEmailVerification(signedOut, '/home'), isNull);
      // Users built without a verification state are not held back.
      expect(
          redirectForEmailVerification(
              const AuthState.authenticated(_testUser), '/home'),
          isNull);
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
