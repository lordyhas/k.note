import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/auth/widgets/auth_error_text.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/widgets/user_avatar.dart';
import 'package:knote/ui/settings/bloc/profile_cubit.dart';

/// The user's profile: their name (editable), email, sign-in method and
/// when they joined.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.firestore});
  static const routeName = "profile";

  /// Tests pass one backed by a fake Firestore.
  final FirestoreService Function(User user)? firestore;

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthenticationBloc>();
    return BlocProvider(
      create: (_) => ProfileCubit(
        context.read<AuthRepository>(),
        user: authBloc.state.user,
        onUserUpdated: authBloc.updateUser,
        firestore: firestore,
      ),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  late final _name =
      TextEditingController(text: context.read<ProfileCubit>().state.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);
    final methods = context.read<AuthRepository>().signInMethods;
    final joined = user.creationDate;

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ProfileStatus.saved) {
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.profileTitle),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: UserAvatar(user: user, size: 96)),
                  const SizedBox(height: 24),
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      final cubit = context.read<ProfileCubit>();
                      final String? error;
                      if (state.status == ProfileStatus.failure) {
                        error = state.error == AuthError.unknown
                            ? l10n.profileSaveFailed
                            : authErrorText(l10n, state.error);
                      } else if (state.name.isNotEmpty && !state.isNameValid) {
                        error = l10n.profileNameInvalid;
                      } else {
                        error = null;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            key: const Key('__profile_name__'),
                            controller: _name,
                            onChanged: cubit.nameChanged,
                            onSubmitted: (_) => cubit.save(),
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            maxLength: ProfileCubit.maxNameLength,
                            enabled: state.status != ProfileStatus.saving,
                            decoration: InputDecoration(
                              labelText: l10n.profileName,
                              hintText: l10n.profileNameHint,
                              prefixIcon: const Icon(Icons.badge_outlined),
                              errorText: error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            key: const Key('__profile_save__'),
                            onPressed: state.canSave ? cubit.save : null,
                            child: state.status == ProfileStatus.saving
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(l10n.save),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.mail_outline, color: colors.text),
                          title: Text(l10n.emailLabel),
                          subtitle: SelectableText(user.email),
                        ),
                        if (methods.isNotEmpty)
                          ListTile(
                            leading: Icon(Icons.login, color: colors.text),
                            title: Text(l10n.profileSignInMethod),
                            subtitle: Text(methods
                                .map((method) => switch (method) {
                                      'google.com' => 'Google',
                                      'password' => l10n.profileEmailPassword,
                                      _ => method,
                                    })
                                .join(', ')),
                          ),
                        if (joined != null)
                          ListTile(
                            leading:
                                Icon(Icons.event_outlined, color: colors.text),
                            title: Text(l10n.profileMemberSince),
                            subtitle: Text(DateFormat.yMMMMd(l10n.localeName)
                                .format(joined)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
