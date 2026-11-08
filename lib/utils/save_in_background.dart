import 'package:flutter/material.dart';

import 'package:knote/ui/core/localization/l10n.dart';

/// App-wide messenger, so a write that fails after its page was closed can
/// still be reported. Set on [MaterialApp.router] in `main.dart`.
final appMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Starts a Firestore [write] without waiting for it, and tells the user if
/// it fails.
///
/// Firestore applies a write to its local cache at once (so live lists show
/// it) but only completes the future once the server accepts it, which never
/// happens while offline. Awaiting it would block the UI offline, so callers
/// fire and forget, and a rejection (e.g. permission denied) is reported
/// here instead of being lost.
///
/// [onFailure] can handle the failure itself and return true, e.g. to show
/// it inside a bottom sheet that would hide a snack bar. Otherwise a snack
/// bar shows [failureMessage], with a Retry action when [canRetry].
void saveInBackground(
  Future<void> Function() write, {
  required String failureMessage,
  bool canRetry = true,
  bool Function()? onFailure,
}) {
  write().catchError((Object error) {
    debugPrint('$failureMessage: $error');
    if (onFailure?.call() ?? false) return;
    appMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(failureMessage),
        action: canRetry
            ? SnackBarAction(
                label: _retryLabel(),
                onPressed: () => saveInBackground(write,
                    failureMessage: failureMessage, onFailure: onFailure),
              )
            : null,
      ));
  });
}

/// The messenger sits below the app's [Localizations], so its context can
/// translate.
String _retryLabel() {
  final context = appMessengerKey.currentContext;
  return context == null ? 'Retry' : context.l10n.retry;
}
