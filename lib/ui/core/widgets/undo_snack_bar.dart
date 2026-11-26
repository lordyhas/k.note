import 'package:flutter/material.dart';

import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/utils/save_in_background.dart';

/// Confirms a removal (trash, archive, delete) with an Undo action, so a
/// wrong tap or swipe is never final.
///
/// Uses the app-wide messenger, so the snack bar survives the bottom sheet
/// or dialog that triggered it being closed.
void showUndoSnackBar(String message, {required VoidCallback onUndo}) {
  final messenger = appMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      // With an action, a snack bar otherwise stays until dismissed.
      persist: false,
      action: SnackBarAction(
          label: messenger.context.l10n.undo, onPressed: onUndo),
    ));
}
