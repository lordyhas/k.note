import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/themes/app_theme.dart';
import 'package:knote/ui/settings/widgets/profile_page.dart';

import '../../../helpers/localized_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthenticationBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthenticationBloc {}

final _user = User(
  id: 'uid-1',
  email: 'me@example.com',
  name: null,
  photoMail: null,
  isCheckMail: true,
  creationDate: DateTime(2025, 3, 14),
);

void main() {
  late AuthRepository authRepository;
  late AuthenticationBloc authBloc;

  setUp(() {
    authRepository = MockAuthRepository();
    authBloc = MockAuthenticationBloc();
    when(() => authBloc.state).thenReturn(AuthState.authenticated(_user));
    when(() => authRepository.signInMethods).thenReturn(['password']);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(Theme(
      data: AppTheme.dark,
      child: RepositoryProvider.value(
        value: authRepository,
        child: BlocProvider.value(
          value: authBloc,
          child: localizedApp(
            home: ProfilePage(
              firestore: (user) =>
                  FirestoreService.user(user, FakeFirebaseFirestore()),
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets('shows the initials, email, sign-in method and join date',
      (tester) async {
    await pumpPage(tester);

    expect(find.text('M'), findsOneWidget); // from the email
    expect(find.text('me@example.com'), findsOneWidget);
    expect(find.text('Email and password'), findsOneWidget);
    expect(find.text('March 14, 2025'), findsOneWidget);
  });

  testWidgets('saves a new name', (tester) async {
    final renamed = _user.copyWith(name: 'Hassan Kajila');
    when(() => authRepository.updateDisplayName(any()))
        .thenAnswer((_) async => renamed);
    await pumpPage(tester);

    FilledButton save() =>
        tester.widget(find.byKey(const Key('__profile_save__')));
    expect(save().onPressed, isNull);

    await tester.enterText(
        find.byKey(const Key('__profile_name__')), 'Hassan Kajila');
    await tester.pump();
    expect(save().onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('__profile_save__')));
    await tester.pumpAndSettle();

    verify(() => authRepository.updateDisplayName('Hassan Kajila')).called(1);
    verify(() => authBloc.updateUser(renamed)).called(1);
    expect(find.text('Profile saved'), findsOneWidget);
  });
}
