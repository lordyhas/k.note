import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/auth/widgets/auth_error_text.dart';
import 'package:knote/ui/core/localization/l10n.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fr = lookupAppLocalizations(const Locale('fr'));

  test('every auth error has its own message', () {
    final messages = {
      for (final error in AuthError.values)
        if (error != AuthError.unknown) authErrorText(en, error),
    };
    expect(messages, hasLength(AuthError.values.length - 1));
  });

  test('messages follow the app language', () {
    expect(authErrorText(fr, AuthError.network),
        'Pas de connexion internet. Vérifiez votre réseau et réessayez.');
    expect(authErrorText(en, AuthError.wrongPassword),
        'Incorrect password, please try again.');
  });

  test('unexpected failures get a generic sign-in or sign-up message', () {
    expect(authErrorText(en, null), en.authErrorSignIn);
    expect(authErrorText(en, AuthError.unknown, isSignUp: true),
        en.authErrorSignUp);
  });

  test('failures built from Firebase codes carry the matching error', () {
    expect(LogInWithEmailAndPasswordFailure.fromCode('wrong-password').error,
        AuthError.wrongPassword);
    expect(SignUpWithEmailAndPasswordFailure.fromCode('weak-password').error,
        AuthError.weakPassword);
    expect(LogInWithGoogleFailure.fromCode('network-request-failed').error,
        AuthError.network);
    expect(LogInWithGoogleFailure.fromCode('invalid-credential').error,
        AuthError.expiredCredential);
    expect(LogInWithEmailAndPasswordFailure.fromCode('???').error,
        AuthError.unknown);
  });
}
