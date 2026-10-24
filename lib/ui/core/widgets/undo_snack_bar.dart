import 'package:flutter/material.dart';

import 'package:knote/utils/save_in_background.dart';

/// Confirms a removal (trash, archive, delete) with an Undo action, so a
/// wrong tap or swipe is never final.
///
/// Uses the app-wide messenger, so the snack bar survives the bottom sheet
/// or dialog that triggered it being closed.
void showUndoSnackBar(String message, {required VoidCallback onUndo}) {
  appMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      // With an action, a snack bar otherwise stays until dismissed.
      persist: false,
      action: SnackBarAction(label: 'Undo', onPressed: onUndo),
    ));
}
