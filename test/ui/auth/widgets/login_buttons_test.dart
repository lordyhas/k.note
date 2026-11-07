import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/auth/bloc/login_cubit.dart';
import 'package:knote/ui/auth/widgets/login_buttons.dart';
import 'package:knote/ui/core/themes/app_theme.dart';

import '../../../helpers/localized_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('the login button turns on once the form is filled in',
      (tester) async {
    final cubit = LoginCubit(MockAuthRepository());
    addTearDown(cubit.close);
    await tester.pumpWidget(Theme(
      data: AppTheme.dark,
      child: localizedApp(
        home: BlocProvider.value(
          value: cubit,
          child: const Scaffold(
            body: Column(
              children: [EmailInput(), PasswordInput(), LoginButton()],
            ),
          ),
        ),
      ),
    ));

    ElevatedButton button() => tester.widget<ElevatedButton>(
        find.byKey(const Key('__loginForm_continue_raisedButton__')));
    expect(button().onPressed, isNull);

    await tester.enterText(
        find.byKey(const Key('__loginForm_emailInput_textField__')),
        'me@example.com ');
    await tester.enterText(
        find.byKey(const Key('__loginForm_passwordInput_textField__')),
        'p@ss!');
    await tester.pump();
    expect(button().onPressed, isNotNull);

    await tester.enterText(
        find.byKey(const Key('__loginForm_passwordInput_textField__')), '');
    await tester.pump();
    expect(button().onPressed, isNull);
  });

  testWidgets('Done on the keyboard logs in', (tester) async {
    final repository = MockAuthRepository();
    when(() => repository.logInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'))).thenAnswer((_) async {});
    final cubit = LoginCubit(repository);
    addTearDown(cubit.close);
    await tester.pumpWidget(Theme(
      data: AppTheme.dark,
      child: localizedApp(
        home: BlocProvider.value(
          value: cubit,
          child: const Scaffold(
            body: Column(children: [EmailInput(), PasswordInput()]),
          ),
        ),
      ),
    ));

    await tester.enterText(
        find.byKey(const Key('__loginForm_emailInput_textField__')),
        'me@example.com');
    await tester.enterText(
        find.byKey(const Key('__loginForm_passwordInput_textField__')),
        'p@ss!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(() => repository.logInWithEmailAndPassword(
        email: 'me@example.com', password: 'p@ss!')).called(1);
  });
}
