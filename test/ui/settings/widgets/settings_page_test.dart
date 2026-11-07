import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/themes/app_theme.dart';
import 'package:knote/ui/settings/widgets/settings_page.dart';

import '../../../helpers/localized_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthenticationBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthenticationBloc {}

void main() {
  late AuthRepository authRepository;
  late AuthenticationBloc authBloc;

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'K.Note',
      packageName: 'com.kdynamic.k_note',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    authRepository = MockAuthRepository();
    authBloc = MockAuthenticationBloc();
    when(() => authRepository.signedInWithPassword).thenReturn(true);
  });

  Future<void> pumpPage(WidgetTester tester, User user) async {
    when(() => authBloc.state).thenReturn(AuthState.authenticated(user));
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(Theme(
      data: AppTheme.dark,
      child: RepositoryProvider.value(
        value: authRepository,
        child: BlocProvider.value(
          value: authBloc,
          child: localizedApp(
            home: SettingsPage(
              firebaseManager:
                  FirestoreService.user(user, FakeFirebaseFirestore()),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('an account without a name shows its initial, not "null"',
      (tester) async {
    await pumpPage(
        tester,
        const User(
            id: 'uid-1',
            email: 'me@example.com',
            name: null,
            photoMail: null,
            isCheckMail: true));

    expect(find.text('null'), findsNothing);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('Add your name'), findsOneWidget);
    expect(find.text('My profile'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
  });

  testWidgets('an account with a name shows it and its initials',
      (tester) async {
    await pumpPage(
        tester,
        const User(
            id: 'uid-1',
            email: 'me@example.com',
            name: 'Hassan Kajila',
            photoMail: null,
            isCheckMail: true));

    expect(find.text('Hassan Kajila'), findsOneWidget);
    expect(find.text('HK'), findsOneWidget);
    expect(find.text('Add your name'), findsNothing);
  });
}
