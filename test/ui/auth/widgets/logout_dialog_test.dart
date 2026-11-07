import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/auth/widgets/logout_dialog.dart';
import 'package:knote/ui/core/themes/app_theme.dart';

import '../../../helpers/localized_app.dart';

class MockAuthenticationBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthenticationBloc {}

void main() {
  late AuthenticationBloc authBloc;

  setUp(() {
    authBloc = MockAuthenticationBloc();
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
  });

  Future<void> openDialog(WidgetTester tester,
      {Locale locale = const Locale('en')}) async {
    await tester.pumpWidget(Theme(
      data: AppTheme.dark,
      child: BlocProvider.value(
        value: authBloc,
        child: localizedApp(
          locale: locale,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => confirmLogout(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('Cancel closes the dialog and keeps the session', (tester) async {
    await openDialog(tester);
    expect(find.text('Log out?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    verifyNever(() => authBloc.logout());
  });

  testWidgets('confirming closes the dialog, then logs out once',
      (tester) async {
    await openDialog(tester);

    await tester.tap(find.byKey(const Key('__logout_confirm__')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    verify(() => authBloc.logout()).called(1);
    expect(find.text("You're logged out."), findsOneWidget);
  });

  testWidgets('is translated into French', (tester) async {
    await openDialog(tester, locale: const Locale('fr'));

    expect(find.text('Se déconnecter ?'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);
  });
}
