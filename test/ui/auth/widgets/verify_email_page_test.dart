import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/auth/widgets/verify_email_page.dart';

import '../../../helpers/localized_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _unverified = User(
  id: 'uid-1',
  email: 'new@example.com',
  name: null,
  photoMail: null,
  isCheckMail: false,
);

void main() {
  late AuthRepository authRepository;
  late StreamController<User> users;
  late AuthenticationBloc authBloc;

  setUp(() {
    authRepository = MockAuthRepository();
    users = StreamController<User>();
    when(() => authRepository.user).thenAnswer((_) => users.stream);
    when(() => authRepository.currentUser).thenReturn(_unverified);
    when(() => authRepository.logOut()).thenAnswer((_) async {});
    when(() => authRepository.sendEmailVerification()).thenAnswer((_) async {});
    when(() => authRepository.reloadUser())
        .thenAnswer((_) async => _unverified);
    authBloc = AuthenticationBloc(authRepository: authRepository);
  });

  tearDown(() async {
    await authBloc.close();
    await users.close();
  });

  Future<void> pumpPage(WidgetTester tester,
      {Locale locale = const Locale('en')}) async {
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: authRepository,
        child: BlocProvider.value(
          value: authBloc,
          child: localizedApp(home: const VerifyEmailPage(), locale: locale),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the address the link was sent to', (tester) async {
    await pumpPage(tester);

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.textContaining('new@example.com'), findsOneWidget);
  });

  testWidgets('resends the email and confirms it', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Resend the email'));
    await tester.pump();

    verify(() => authRepository.sendEmailVerification()).called(1);
    expect(find.text('Verification email sent.'), findsOneWidget);
  });

  testWidgets('says when the email is not verified yet', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text("I've verified my email"));
    await tester.pump();

    expect(
      find.text("Your email isn't verified yet. "
          'Open the link we sent, then try again.'),
      findsOneWidget,
    );
  });

  testWidgets('updates the session once the email is verified', (tester) async {
    final verified = _unverified.copyWith(isCheckMail: true);
    when(() => authRepository.reloadUser()).thenAnswer((_) async => verified);
    await pumpPage(tester);

    await tester.tap(find.text("I've verified my email"));
    await tester.pump();

    expect(authBloc.state.user, verified);
  });

  testWidgets('checks on its own every few seconds', (tester) async {
    await pumpPage(tester);

    await tester.pump(VerifyEmailPage.checkInterval);

    verify(() => authRepository.reloadUser()).called(1);
  });

  testWidgets('log out signs the user out', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Log out'));
    await tester.pump();

    verify(() => authRepository.logOut()).called(1);
  });

  testWidgets('is translated into French', (tester) async {
    await pumpPage(tester, locale: const Locale('fr'));

    expect(find.text('Vérifiez votre adresse e-mail'), findsOneWidget);
  });
}
