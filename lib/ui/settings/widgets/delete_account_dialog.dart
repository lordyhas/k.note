import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/ui/auth/widgets/auth_error_text.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/settings/bloc/delete_account_cubit.dart';

/// Asks the user to confirm, then deletes their account and all their data
/// (see [DeleteAccountCubit]).
Future<void> showDeleteAccountDialog(
  BuildContext context, {
  required FirestoreService firestoreService,
  Future<void> Function()? beforeAccountDeleted,
}) {
  final authRepository = context.read<AuthRepository>();
  final usesPassword = authRepository.signedInWithPassword;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider(
      create: (_) => DeleteAccountCubit(
        authRepository,
        firestoreService,
        beforeAccountDeleted: beforeAccountDeleted,
      ),
      child: _DeleteAccountDialog(usesPassword: usesPassword),
    ),
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.usesPassword});

  /// Whether the user confirms with their password (otherwise with Google).
  final bool usesPassword;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _delete() {
    context.read<DeleteAccountCubit>().deleteAccount(
          password: widget.usesPassword ? _password.text : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == DeleteAccountStatus.deleted) {
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.deleteAccountDone)));
        }
      },
      builder: (context, state) {
        final inProgress = state.status == DeleteAccountStatus.inProgress;
        final String? errorText = state.status == DeleteAccountStatus.failure
            ? (state.error == AuthError.unknown
                ? l10n.deleteAccountFailed
                : authErrorText(l10n, state.error))
            : null;
        return AlertDialog(
          title: Text(l10n.deleteAccountTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.deleteAccountBody),
              const SizedBox(height: 16),
              if (widget.usesPassword)
                TextField(
                  key: const Key('__deleteAccount_password__'),
                  controller: _password,
                  obscureText: true,
                  autofocus: true,
                  enabled: !inProgress,
                  autofillHints: const [AutofillHints.password],
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) {
                    if (_password.text.isNotEmpty) _delete();
                  },
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    helperText: l10n.deleteAccountPasswordHint,
                    errorText: errorText,
                    errorMaxLines: 3,
                  ),
                )
              else ...[
                Text(l10n.deleteAccountGoogleHint),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child:
                        Text(errorText, style: TextStyle(color: colors.danger)),
                  ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: inProgress ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              key: const Key('__deleteAccount_confirm__'),
              style: FilledButton.styleFrom(backgroundColor: colors.danger),
              onPressed:
                  inProgress || (widget.usesPassword && _password.text.isEmpty)
                      ? null
                      : _delete,
              child: inProgress
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.deleteAccountConfirm),
            ),
          ],
        );
      },
    );
  }
}
