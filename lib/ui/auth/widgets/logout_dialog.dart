import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';

/// Asks the user to confirm, then logs them out.
///
/// The dialog only answers yes or no and is closed before anything happens.
/// It does not navigate: once Firebase reports the sign-out, the router's
/// redirect (`redirectForAuth`) sends the user to the login page, wherever
/// they are.
Future<void> confirmLogout(BuildContext context) async {
  final authBloc = context.read<AuthenticationBloc>();
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => const _LogoutDialog(),
  );
  if (confirmed != true) return;
  authBloc.logout();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.loggedOut)));
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    return AlertDialog(
      icon: Icon(Icons.logout_rounded, color: colors.danger),
      title: Text(l10n.logOutTitle),
      content: Text(l10n.logOutBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('__logout_confirm__'),
          style: FilledButton.styleFrom(backgroundColor: colors.danger),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.logOut),
        ),
      ],
    );
  }
}
