import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/auth/bloc/verify_email_cubit.dart';
import 'package:knote/ui/auth/widgets/auth_error_text.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';

/// Shown to users who signed up with an email address they have not
/// verified yet. The router keeps them here until they open the link sent by
/// Firebase, then sends them home.
class VerifyEmailPage extends StatelessWidget {
  static const routeName = "verify-email";

  /// How often the page asks Firebase whether the link was opened.
  static const checkInterval = Duration(seconds: 5);

  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerifyEmailCubit(
        context.read<AuthRepository>(),
        onUserReloaded: context.read<AuthenticationBloc>().updateUser,
      ),
      child: const _VerifyEmailView(),
    );
  }
}

class _VerifyEmailView extends StatefulWidget {
  const _VerifyEmailView();

  @override
  State<_VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<_VerifyEmailView> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // Leave the page on its own once the link is opened, even in another
    // tab or on another device.
    _timer = Timer.periodic(
      VerifyEmailPage.checkInterval,
      (_) => context.read<VerifyEmailCubit>().checkVerified(silent: true),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email =
        context.select((AuthenticationBloc bloc) => bloc.state.user.email);
    final mutedText = AppColors.of(context).text.withValues(alpha: 0.6);

    return BlocListener<VerifyEmailCubit, VerifyEmailState>(
      listener: (context, state) {
        switch (state.status) {
          case VerifyEmailStatus.sent:
            _showMessage(l10n.verifyEmailSent);
          case VerifyEmailStatus.notVerifiedYet:
            _showMessage(l10n.verifyEmailNotVerified);
          case VerifyEmailStatus.failure:
            _showMessage(authErrorText(l10n, state.error));
          default:
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
                  builder: (context, state) {
                    final cubit = context.read<VerifyEmailCubit>();
                    final checking = state.status == VerifyEmailStatus.checking;
                    final sending = state.status == VerifyEmailStatus.sending;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.mark_email_unread_outlined, size: 72),
                        const SizedBox(height: 24.0),
                        Text(
                          l10n.verifyEmailTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          l10n.verifyEmailBody(email),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          l10n.verifyEmailSpamHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: mutedText),
                        ),
                        const SizedBox(height: 32.0),
                        SizedBox(
                          height: 48.0,
                          child: FilledButton(
                            onPressed: checking ? null : cubit.checkVerified,
                            child: checking
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(l10n.verifyEmailCheck),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        SizedBox(
                          height: 48.0,
                          child: OutlinedButton(
                            onPressed: sending ? null : cubit.resend,
                            child: Text(l10n.verifyEmailResend),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        SizedBox(
                          height: 48.0,
                          child: TextButton(
                            onPressed:
                                context.read<AuthenticationBloc>().logout,
                            child: Text(l10n.logOut),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
