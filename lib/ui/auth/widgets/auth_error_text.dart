import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/core/localization/l10n.dart';

/// The translated message for an auth failure. [error] is null when the
/// failure was unexpected; [isSignUp] picks the matching generic message.
String authErrorText(
  AppLocalizations l10n,
  AuthError? error, {
  bool isSignUp = false,
}) {
  return switch (error) {
    AuthError.invalidEmail => l10n.authErrorInvalidEmail,
    AuthError.userDisabled => l10n.authErrorUserDisabled,
    AuthError.emailAlreadyInUse => l10n.authErrorEmailInUse,
    AuthError.operationNotAllowed => l10n.authErrorNotAllowed,
    AuthError.weakPassword => l10n.authErrorWeakPassword,
    AuthError.userNotFound => l10n.authErrorUserNotFound,
    AuthError.wrongPassword => l10n.authErrorWrongPassword,
    AuthError.invalidCredential => l10n.authErrorInvalidCredential,
    AuthError.expiredCredential => l10n.authErrorExpiredCredential,
    AuthError.tooManyRequests => l10n.authErrorTooManyRequests,
    AuthError.network => l10n.authErrorNetwork,
    AuthError.googleNotConfigured => l10n.authErrorGoogleNotConfigured,
    AuthError.accountExistsWithDifferentCredential =>
      l10n.authErrorDifferentCredential,
    AuthError.invalidVerification => l10n.authErrorInvalidVerification,
    AuthError.unknown ||
    null =>
      isSignUp ? l10n.authErrorSignUp : l10n.authErrorSignIn,
  };
}
