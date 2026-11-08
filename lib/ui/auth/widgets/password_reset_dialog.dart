import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/auth/bloc/password_reset_cubit.dart';
import 'package:knote/ui/auth/widgets/auth_error_text.dart';
import 'package:knote/ui/core/localization/l10n.dart';

/// Asks for the account's email address and sends it a link to choose a new
/// password. [email] prefills the field.
Future<void> showPasswordResetDialog(BuildContext context,
    {String email = ''}) {
  final authRepository = context.read<AuthRepository>();
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => PasswordResetCubit(authRepository, email: email),
      child: _PasswordResetDialog(initialEmail: email),
    ),
  );
}

class _PasswordResetDialog extends StatelessWidget {
  const _PasswordResetDialog({required this.initialEmail});

  final String initialEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == PasswordResetStatus.sent) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(l10n.resetPasswordSent(state.email.value))));
        }
      },
      builder: (context, state) {
        final cubit = context.read<PasswordResetCubit>();
        final sending = state.status == PasswordResetStatus.sending;
        final String? errorText;
        if (state.status == PasswordResetStatus.failure) {
          errorText = state.error == AuthError.unknown
              ? l10n.resetPasswordFailed
              : authErrorText(l10n, state.error);
        } else if (state.email.value.isNotEmpty && state.email.isNotValid) {
          errorText = l10n.invalidEmail;
        } else {
          errorText = null;
        }
        return AlertDialog(
          title: Text(l10n.resetPasswordTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.resetPasswordBody),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('__passwordReset_email__'),
                initialValue: initialEmail,
                autofocus: initialEmail.isEmpty,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                onChanged: cubit.emailChanged,
                onFieldSubmitted: (_) => cubit.send(),
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  errorText: errorText,
                  errorMaxLines: 3,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: sending || state.email.isNotValid ? null : cubit.send,
              child: sending
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.resetPasswordSend),
            ),
          ],
        );
      },
    );
  }
}
